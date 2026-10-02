function pd --description 'pick a directory and cd into it'
    __require_cmds pd fd fzf; or return

    set -l args $argv
    if test (count $args) -lt 1
        set args .
    end
    set -l target (command fd $args -t d | command fzf)
    if test $status -ne 0
        echo "pd: user cancelled." >&2
        return 1
    else if test -z "$target"
        echo "pd: target path is empty" >&2
        return 1
    end
    cd $target; and command pwd
end
