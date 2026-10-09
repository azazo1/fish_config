function amd --description '进入 Python REPL 并把设备探索 agent 提示词复制到剪贴板'
    __require_cmds amd python3 uname; or return

    set -l startup $__fish_config_dir/python/amd_startup.py
    if not test -f $startup
        echo "amd: 未找到 $startup" >&2
        return 1
    end

    # 检测平台, 决定 run(cmd, sandbox=True) 用哪个只读沙箱后端.
    # 沙箱后端缺失只警告不阻断, 因为 sandbox=False 依然可用.
    set -l platform unknown
    switch (command uname -s)
        case Darwin
            set platform macos
            if not command -sq sandbox-exec
                echo "amd: 警告: 未找到 sandbox-exec, run(sandbox=True) 不可用" >&2
            end
        case Linux
            set platform linux
            if not command -sq bwrap
                echo "amd: 警告: 未找到 bwrap, run(sandbox=True) 不可用" >&2
            end
    end

    echo "amd: 启动 Python REPL (startup: $startup, platform: $platform)"
    PYTHONSTARTUP=$startup python3
end
