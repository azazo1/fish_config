function tmp --description 'create temp directory'
    set -l target_path
    if [ (count $argv) -gt 0 ]
        set target_path "$HOME/tmp/$(basename $argv[1])"
    else
        set target_path "$HOME/tmp/"
    end
    command mkdir -p $target_path
    cd $target_path
    ls
end
