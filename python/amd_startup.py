# ~/.config/fish/python/amd_startup.py
"""amd 的 Python REPL 启动脚本.

由 amd.fish 通过 PYTHONSTARTUP 加载. 职责:
  1. 在 REPL 里定义 run / sh / osc_copy
  2. 读取同目录的 amd_prompt.txt, 填充 cwd 和 skills
  3. 通过 OSC 52 把提示词复制到系统剪贴板

仅交互式 REPL 会触发 (PYTHONSTARTUP 语义), 不影响 python3 script.py.
"""
from __future__ import annotations

import base64
import os
import re
import subprocess
import sys
from pathlib import Path

_HERE = Path(__file__).resolve().parent if "__file__" in globals() \
    else Path.home() / ".config" / "fish" / "python"

_PROMPT_FILE = _HERE / "amd_prompt.txt"
_SKILLS_DIR = Path.home() / ".dsh" / "skills"
_SHELL = os.environ.get("SHELL") or "/bin/sh"

__all__ = ["run", "sh", "osc_copy", "build_prompt"]


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
    except OSError:
        sys.stdout.write(seq)
        sys.stdout.flush()


def _run_shell(cmd):
    p = subprocess.run(
        [_SHELL, "-c", cmd],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return p.returncode, p.stdout.decode("utf-8", errors="replace")


def sh(cmd):
    """执行 shell 命令, 返回 stdout+stderr 文本 (不写剪贴板)."""
    return _run_shell(cmd)[1]


def run(cmd):
    """执行 shell 命令, 把 stdout+stderr 通过 OSC 52 复制到剪贴板.

    复制内容用 <paste>...</paste> 包裹, 与 fish 版 amd 的约定一致.
    返回 (returncode, text).
    """
    rc, text = _run_shell(cmd)
    osc_copy("<paste>\n%s\n</paste>" % text)
    print("[amd] returncode=%d, copied %d bytes to clipboard" % (rc, len(text)))
    return rc, text


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
    print("[amd] 已定义: run(cmd), sh(cmd), osc_copy(text), build_prompt()")


if __name__ == "__main__":
    _bootstrap()

