# 交互式 shell 的工具初始化, 每一项都先确认工具存在.

if command -q starship
    starship init fish | source
end

if command -q zoxide
    zoxide init fish | source
    alias cd z
end

if command -q howlto
    command howlto --init | source
end

# VS Code 终端不支持 CSI u 键盘协议, 每条命令执行前关闭它.
# 事件处理函数不会被自动加载, 只能在这里直接定义.
if set -q VSCODE_INJECTION; or test "$TERM_PROGRAM" = vscode
    function __prevent_csi_u --on-event fish_preexec
        printf '\e[>0u'
    end
end
