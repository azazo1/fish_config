function rm --description 'BSD rm wrapper, move options before file arguments'
    set -l opts
    set -l files
    set -l after_double_dash 0

    for arg in $argv
        if test $after_double_dash -eq 1
            # -- 之后的参数全部视为文件.
            set -a files $arg
        else if test "$arg" = --
            set after_double_dash 1
            set -a files --
        else if string match -qr '^-' -- $arg
            set -a opts $arg
        else
            set -a files $arg
        end
    end

    command rm $opts $files
end
