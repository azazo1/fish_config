function sizesof --description 'search files and get the sizes of them'
    if test (count $argv) -lt 1
        echo "sizesof requires an argument." >&2
        return 1
    end
    __require_cmds sizesof fd; or return

    set -l files (command fd -t f $argv)
    if not set -q files[1]
        echo "sizesof: No file matched." >&2
        return 1
    end
    command du -h -d 0 -- $files
end
