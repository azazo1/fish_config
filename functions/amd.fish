function amd --description '进入 Python REPL 并把设备探索 agent 提示词复制到剪贴板'
    set -l startup $__fish_config_dir/python/amd_startup.py
    if not test -f $startup
        echo "amd: 未找到 $startup" >&2
        return 1
    end
    echo "amd: 启动 Python REPL (startup: $startup)"
    PYTHONSTARTUP=$startup python3
end
