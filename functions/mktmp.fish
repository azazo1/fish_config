function mktmp --description 'create a temporary directory, trash it after the child shell exits'
    __require_cmds mktmp fd trash; or return

    set -l tmp_path (command mktemp -d -t mktmp); or return
    if test (count $argv) -ge 1
        mkdir $tmp_path/$argv[1]
        command fish -C "cd $(string escape -- $tmp_path/$argv[1])"
    else
        command fish -C "cd $(string escape -- $tmp_path)"
    end

    pushd $tmp_path
    for item in (command fd . $tmp_path -d 1)
        set -l item_size (command du -h -d 0 $item | awk '{print $1}')
        set -l item_disp (command fd -d 1 --color=always '^'(basename $item)'$')
        echo - $item_disp (set_color yellow)$item_size(set_color normal)
    end
    popd

    set -l tmp_size (command du -h -d 0 $tmp_path | cut -f 1)
    set -l tmp_disp (dirname $tmp_path)/(set_color blue)(basename $tmp_path)(set_color normal)/
    if command trash $tmp_path
        echo (set_color green)Trashed(set_color normal) $tmp_disp (set_color yellow)$tmp_size(set_color normal)
    else
        echo (set_color red)Not Trash(set_color normal) $tmp_disp (set_color yellow)$tmp_size(set_color normal)
    end
end
