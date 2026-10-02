function y --description 'yazi, cd into the last directory on exit'
    __require_cmds y yazi; or return

    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
        cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end
