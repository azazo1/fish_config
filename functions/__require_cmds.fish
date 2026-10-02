function __require_cmds --description 'check required commands: __require_cmds <caller> <cmd>...'
    set -l caller $argv[1]
    set -e argv[1]
    set -l missing
    for cmd in $argv
        command -q $cmd; or set -a missing $cmd
    end
    if set -q missing[1]
        printf '%s: 缺少依赖命令: %s\n' $caller (string join ', ' -- $missing) >&2
        return 127
    end
end
