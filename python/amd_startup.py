# ~/.config/fish/python/amd_startup.py
"""amd 的 Python REPL 启动脚本.

由 amd.fish 通过 PYTHONSTARTUP 加载. 职责:
  1. 在 REPL 里定义 run / sh / osc_copy  (给 agent 用, 输出走剪贴板)
  2. 定义 ls / cat / cd / ...             (给用户用, 输出直接可见)
  3. 读取同目录的 amd_prompt.txt, 填充 cwd 和 skills
  4. 通过 OSC 52 把提示词复制到系统剪贴板

仅交互式 REPL 会触发 (PYTHONSTARTUP 语义), 不影响 python3 script.py.
"""
from __future__ import annotations

import base64
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

_HERE = Path(__file__).resolve().parent if "__file__" in globals() \
    else Path.home() / ".config" / "fish" / "python"

_PROMPT_FILE = _HERE / "amd_prompt.txt"
_SKILLS_DIR = Path.home() / ".dsh" / "skills"
_SHELL = os.environ.get("SHELL") or "/bin/sh"

# ---------------------------------------------------------------------------
# 平台检测 & 只读沙箱
# ---------------------------------------------------------------------------

_IS_MACOS = sys.platform == "darwin"
_IS_LINUX = sys.platform.startswith("linux")

_BWRAP = shutil.which("bwrap")
_SANDBOX_EXEC = shutil.which("sandbox-exec")

_SEATBELT_RO_PROFILE = """(version 1)
(allow default)
(deny file-write*)
(allow file-write*
    (subpath "/dev")
    (subpath "/tmp")
    (subpath "/private/tmp")
    (subpath "/private/var/tmp")
    (subpath "/private/var/folders"))
"""


def sandbox_available():
    """当前平台是否具备只读沙箱能力."""
    if _IS_MACOS:
        return _SANDBOX_EXEC is not None
    if _IS_LINUX:
        return _BWRAP is not None
    return False


def sandbox_kind():
    """返回人类可读的沙箱后端描述."""
    if _IS_MACOS:
        return ("seatbelt (sandbox-exec)" if _SANDBOX_EXEC
                else "unavailable (sandbox-exec missing)")
    if _IS_LINUX:
        return ("bwrap (bubblewrap)" if _BWRAP
                else "unavailable (bwrap missing)")
    return "unsupported platform: %s" % sys.platform


def _wrap_sandbox(argv):
    """把完整命令 argv (list) 包进只读沙箱, 返回新的 argv."""
    if _IS_MACOS:
        if not _SANDBOX_EXEC:
            raise RuntimeError(
                "macOS 只读沙箱需要 sandbox-exec, 但未找到. "
                "请安装 Xcode Command Line Tools, 或改用 sandbox=False."
            )
        return [_SANDBOX_EXEC, "-p", _SEATBELT_RO_PROFILE, *argv]
    if _IS_LINUX:
        if not _BWRAP:
            raise RuntimeError(
                "Linux 只读沙箱需要 bwrap (bubblewrap), 但未找到. "
                "请安装 bubblewrap, 或改用 sandbox=False."
            )
        return [
            _BWRAP,
            "--ro-bind", "/", "/",
            "--dev", "/dev",
            "--proc", "/proc",
            "--tmpfs", "/tmp",
            "--tmpfs", "/run",
            "--unshare-pid",
            "--die-with-parent",
            "--",
            *argv,
        ]
    raise RuntimeError("当前平台不支持沙箱: %s" % sys.platform)


__all__ = [
    # agent 用
    "run", "sh", "osc_copy", "build_prompt",
    "sandbox_available", "sandbox_kind",
    # 用户用
    "term", "ls", "cd", "pwd", "cat", "grep", "find", "which",
    "head", "tail", "wc", "tree", "echo", "mkdir", "touch",
    "rm", "cp", "mv",
]

# ---------------------------------------------------------------------------
# agent 用: 输出走剪贴板
# ---------------------------------------------------------------------------

def osc_copy(text) -> None:
    """通过 OSC 52 把 text 复制到系统剪贴板 (str 或 bytes)."""
    if isinstance(text, str):
        data = text.encode("utf-8")
    elif isinstance(text, (bytes, bytearray)):
        data = bytes(text)
    else:
        data = str(text).encode("utf-8")
    payload = base64.b64encode(data).decode("ascii")
    seq = "\x1b]52;c;%s\x07" % payload

    try:
        with open("/dev/tty", "w", encoding="ascii") as tty:
            tty.write(seq)
            tty.flush()
        return
    except OSError:
        pass
    sys.stderr.write(seq)
    sys.stderr.flush()


def _run_shell(cmd, sandbox=False):
    argv = [_SHELL, "-c", cmd]
    if sandbox:
        argv = _wrap_sandbox(argv)
    p = subprocess.run(
        argv,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return p.returncode, p.stdout.decode("utf-8", errors="replace")


def sh(cmd, sandbox=False):
    """执行 shell 命令, 返回 stdout+stderr 文本 (不写剪贴板).

    sandbox=True 时在只读沙箱里执行 (Linux: bwrap, macOS: sandbox-exec).
    """
    return _run_shell(cmd, sandbox=sandbox)[1]


def run(cmd, sandbox=False):
    """执行 shell 命令, 把 stdout+stderr 通过 OSC 52 复制到剪贴板.

    sandbox=True 时在只读沙箱里执行:
      - Linux: bwrap (bubblewrap), 根文件系统 --ro-bind / / 只读
      - macOS: sandbox-exec + seatbelt, deny file-write*

    复制内容用 <paste>...</paste> 包裹, 与 fish 版 amd 的约定一致.
    返回 (returncode, text).
    """
    rc, text = _run_shell(cmd, sandbox=sandbox)
    osc_copy("<paste>\n%s\n</paste>" % text)
    print("[amd] returncode=%d, copied %d bytes to clipboard (%s)"
          % (rc, len(text), "sandbox" if sandbox else "direct"))
    return rc, text

# ---------------------------------------------------------------------------
# 用户用: 输出直接可见 (继承 tty)
# ---------------------------------------------------------------------------

def _term(cmd):
    """在终端里直接执行 shell 命令, 继承 tty, 返回 returncode."""
    try:
        return subprocess.run([_SHELL, "-c", cmd]).returncode
    except FileNotFoundError:
        print("[amd] 找不到 shell: %s" % _SHELL, file=sys.stderr)
        return 127


def _join(name, args):
    return " ".join([name] + [shlex.quote(str(a)) for a in args])


def term(cmd):
    """term("任意 shell 命令") — 在终端里直接执行, 输出可见."""
    return _term(cmd)


def ls(*args):
    """ls [args] — 直接在终端列出目录."""
    return _term(_join("ls", args))


def cat(*args):
    """cat file... — 直接在终端打印文件."""
    return _term(_join("cat", args))


def grep(*args):
    return _term(_join("grep", args))


def find(*args):
    return _term(_join("find", args))


def which(cmd):
    return _term(_join("which", [cmd]))


def head(*args):
    return _term(_join("head", args))


def tail(*args):
    return _term(_join("tail", args))


def wc(*args):
    return _term(_join("wc", args))


def tree(*args):
    return _term(_join("tree", args))


def echo(*args):
    return _term(_join("echo", args))


def mkdir(*args):
    return _term(_join("mkdir", args))


def touch(*args):
    return _term(_join("touch", args))


def rm(*args):
    return _term(_join("rm", args))


def cp(*args):
    return _term(_join("cp", args))


def mv(*args):
    return _term(_join("mv", args))


def pwd():
    """打印当前 Python 进程的工作目录 (与 run() 一致)."""
    print(os.getcwd())


def cd(path="~"):
    """cd [path] — 改变 Python 进程的工作目录, 影响 run()/pwd()/ls().

    这是真的 os.chdir, 不是起子 shell, 所以之后 run() 也在新目录里跑.
    """
    p = os.path.expanduser(str(path))
    try:
        os.chdir(p)
    except OSError as e:
        print("[amd] cd 失败: %s" % e, file=sys.stderr)
        return
    print(os.getcwd())

# ---------------------------------------------------------------------------
# 提示词构建
# ---------------------------------------------------------------------------

_FM_RE = re.compile(r"^(name|description):[ \t]*(.*)$")


def _read_frontmatter(md):
    out = {}
    in_fm = False
    for line in md.read_text(encoding="utf-8", errors="replace").splitlines():
        if not in_fm:
            if line.strip() == "---":
                in_fm = True
            continue
        if line.strip() == "---":
            break
        m = _FM_RE.match(line)
        if m and m.group(1) not in out:
            out[m.group(1)] = m.group(2)
        if "name" in out and "description" in out:
            break
    return out


def _discover_skills(skills_dir):
    lines = []
    if not skills_dir.is_dir():
        return lines
    for sdir in sorted(skills_dir.iterdir()):
        if not sdir.is_dir():
            continue
        smd = sdir / "SKILL.md"
        if not smd.is_file():
            continue
        try:
            fm = _read_frontmatter(smd)
        except OSError:
            continue
        name = fm.get("name") or sdir.name
        desc = fm.get("description", "")
        lines.append("- %s: %s" % (name, desc) if desc else "- %s" % name)
    return lines


def build_prompt(cwd=None):
    """构建提示词文本. 不复制, 只返回字符串, 便于本地检查."""
    cwd = str(Path(cwd) if cwd is not None else Path.cwd())
    tpl = _PROMPT_FILE.read_text(encoding="utf-8")
    skills = "\n".join(_discover_skills(_SKILLS_DIR))
    return tpl.replace("@@CWD@@", cwd).replace("@@SKILLS@@", skills)


def _bootstrap():
    try:
        text = build_prompt()
    except OSError as e:
        print("[amd] 无法构建提示词: %s" % e, file=sys.stderr)
        return
    osc_copy(text)
    print("[amd] Python REPL ready. 提示词已复制到剪贴板.")
    print("[amd] platform=%s | sandbox=%s" % (sys.platform, sandbox_kind()))
    print("[amd] agent 用:  run(cmd, sandbox=False)  sh(cmd, sandbox=False)"
          "  osc_copy(text)  sandbox_available()")
    print("[amd] 用户用:    ls(*a)  cat(*f)  cd(path)  pwd()  grep(*a)"
          "  find(*a)  which(c)  head/tail/wc(*a)  tree(*a)  term(cmd)")


if __name__ == "__main__":
    _bootstrap()

