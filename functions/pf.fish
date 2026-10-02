function pf --description 'pick a file and open it'
    if test (count $argv) -lt 1
        echo "Usage: pf <file_search_pattern>" >&2
        return 1
    end
    __require_cmds pf fd fzf; or return

    # macOS 使用 open, Linux 桌面使用 xdg-open.
    set -l opener open
    if command -q xdg-open
        set opener xdg-open
    end
    __require_cmds pf $opener; or return

    set -l target (command fd $argv -t f | command fzf)
    if test $status -ne 0
        echo "pf: user cancelled." >&2
        return 1
    else if test -z "$target"
        echo "pf: target path is empty" >&2
        return 1
    end
    command $opener $target
end
