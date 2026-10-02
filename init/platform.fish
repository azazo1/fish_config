# Linux 专属: WSL 互操作等.

if status is-interactive
    # WSL 中调用 Windows 侧的 PowerShell 7.
    if set -q WSL_DISTRO_NAME; and test -x "/mnt/c/Program Files/PowerShell/7/pwsh.exe"
        alias pwsh "'/mnt/c/Program Files/PowerShell/7/pwsh.exe'"
    end
end
