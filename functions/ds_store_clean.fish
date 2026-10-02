function ds_store_clean --description 'clean .DS_Store files under current directory, trash them by default'
    argparse r/remove h/help -- $argv
    or return 1
    if set -ql _flag_help
        echo "ds_store_clean [-h] [-r]"
        echo "  -r, --remove  remove instead of trash"
        return
    end
    __require_cmds ds_store_clean fd; or return

    if set -ql _flag_remove
        for file in (command fd -HI '^\.DS_Store$' -t f)
            echo removing $file ...
            command rm -- $file
        end
    else
        __require_cmds ds_store_clean trash; or return
        for file in (command fd -HI '^\.DS_Store$' -t f)
            echo trashing $file ...
            command trash $file
        end
    end
end
