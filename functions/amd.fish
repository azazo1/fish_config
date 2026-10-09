# ~/.config/fish/functions/ama.fish
function amd --description '生成设备探索 agent 提示词并复制到系统剪贴板'
    set -l cwd (pwd)

    set -l prompt \
        '你是一个可以操作当前设备的 agent.' \
        '' \
        '# 如何获取命令输出' \
        '' \
        '你的 stdout 无法被直接读取. 要读取命令输出, 请用 OSC 52' \
        '转义序列把它复制到系统剪贴板, 然后从剪贴板读取.' \
        '' \
        '先定义 helper (只需一次):' \
        '' \
        '    function osc-copy' \
        '        set -l p (base64 | tr -d "\n\r")' \
        '        printf "\e]52;c;%s\a" $p > /dev/tty' \
        '    end' \
        '' \
        '之后所有需要读取输出的命令都写成:' \
        '' \
        '    begin' \
        '        <你的命令>' \
        '    end 2>&1 | osc-copy' \
        '' \
        '# 示例' \
        '' \
        '    begin' \
        '        pwd' \
        '        ls -la' \
        '        uname -a' \
        '    end 2>&1 | osc-copy' \
        '' \
        '# 任务' \
        '' \
        "当前工作目录: $cwd" \
        '利用上述方式探索当前设备中的内容, 定位并解决问题.'

    set -l text (string join "\n" $prompt)

    # 把提示词本身也通过 OSC 52 复制到系统剪贴板
    set -l payload (printf '%s' "$text" | base64 | tr -d '\n\r')
    printf '\e]52;c;%s\a' $payload > /dev/tty

    echo "Agent 提示词已复制到剪贴板 (cwd: $cwd)"
end
