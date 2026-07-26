function mktmp --description 'create temp directory in system temp directory, remove dir when shell quit'
    set -l tmp_path (command mktemp -d -t mktmp)
    if [ (count $argv) -ge 1 ]
        mkdir $tmp_path/$argv[1]
        command fish -C "cd $tmp_path/$argv[1]"
    else
        command fish -C "cd $tmp_path"
    end
    pushd $tmp_path
    for item in (command fd . $tmp_path -d 1)
        set -l item_size (command du -h -d 0 $item | awk '{print $1}')
        set item_disp (command fd -d 1 --color=always '^'$(basename $item)'$') # --full-path "^$(string trim -r -c '/' $item)\$")
        echo - $item_disp (set_color yellow)$item_size(set_color normal)
    end
    popd
    set -l tmp_size (command du -h -d 0 $tmp_path | cut -f 1)
    if command rm -rf $tmp_path
        echo (set_color green)Trashed(set_color normal) (dirname $tmp_path)/(set_color blue)(basename $tmp_path)(set_color normal)/ (set_color yellow)$tmp_size(set_color normal)
    else
        echo (set_color red)Not Trash(set_color normal) (dirname $tmp_path)/(set_color blue)(basename $tmp_path)(set_color normal)/ (set_color yellow)$tmp_size(set_color normal)
    end
end
