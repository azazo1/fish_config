function nox --description 'remove x permission for all text file in folder'
    __require_cmds nox fd file; or return

    set -l target_path (pwd)
    if test (count $argv) -ge 1
        set target_path $argv[1]
    end
    echo target_path: $target_path
    for fp in (command fd . -HI -t x $target_path)
        if string match -q '*text*' -- (command file --brief $fp)
            command chmod -x $fp
            echo $fp
        end
    end
end
