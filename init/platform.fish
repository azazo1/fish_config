# macOS 专属: Homebrew, Android SDK, JDK, 系统工具别名.

set -gx COPYFILE_DISABLE 1 # 禁止 tar 打包 ._* 这类文件
set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
set -gx HOMEBREW_CORE_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

# Homebrew {
# 直接按安装位置定位前缀, 避免启动时多次执行 brew --prefix, 也不要求 brew 已在 PATH 中.
set -l brew_prefix
for candidate in /opt/homebrew /usr/local
    if test -x "$candidate/bin/brew"
        set brew_prefix $candidate
        break
    end
end

if test -n "$brew_prefix"
    fish_add_path --path -p -m "$brew_prefix/sbin"
    fish_add_path --path -p -m "$brew_prefix/bin"
    # keg-only 的 GNU 工具, 未安装时目录不存在, 会被自动跳过.
    for formula in util-linux e2fsprogs
        fish_add_path --path -p -m "$brew_prefix/opt/$formula/bin"
        fish_add_path --path -p -m "$brew_prefix/opt/$formula/sbin"
    end
end
# }

# Python 用户目录 {
# 未安装 Xcode CLT 时 /usr/bin/python3 只是会弹安装窗口的占位程序, 需要先确认.
if command -q python3; and begin
        test (command -s python3) != /usr/bin/python3
        or xcode-select -p >/dev/null 2>&1
    end
    fish_add_path --path -p -m (python3 -m site --user-base)/bin
end
# }

# Android SDK {
if test -d "$HOME/Library/Android/sdk"
    set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
    set -gx ANDROID_SDK_ROOT $ANDROID_HOME
    fish_add_path --path -p -m $ANDROID_HOME/platform-tools
    fish_add_path --path -p -m $ANDROID_HOME/emulator
    fish_add_path --path -p -m $ANDROID_HOME/cmdline-tools/latest/bin
    fish_add_path --path -p -m $ANDROID_HOME/build-tools/36.0.0
end
# }

# JDK {
if test -n "$brew_prefix"; and test -d "$brew_prefix/opt/openjdk"
    set -gx JAVA_HOME "$brew_prefix/opt/openjdk"
    set -gx CLASSPATH $JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:.
    fish_add_path --path -p -m $JAVA_HOME/bin
end
# }

if status is-interactive
    set -gx LANG zh_CN.UTF-8
    set -gx LC_ALL zh_CN.UTF-8

    alias brwe brew
    alias pbc pbcopy
    alias pbp pbpaste
    alias pfc pfcopy
    alias pfp pfpaste
    alias finder 'open -a finder '
    alias cxa 'open -a ChatGPT .'
    alias cxapp 'codex app'
    alias rsdir rsbuild
    alias wsl 'ssh wsl'
    if command -q 7zz
        alias 7z 7zz
    end

    # 本地代理端口可用时才自动启用, 避免在没有代理的机器上断网.
    if command -q nc; and nc -z -w 1 localhost 7890 >/dev/null 2>&1
        setproxyp
    end
end
