function tmp --description 'create and enter ~/tmp/<name>'
    set -l target_path "$HOME/tmp/"
    if test (count $argv) -gt 0
        set target_path "$HOME/tmp/$(basename $argv[1])"
    end
    command mkdir -p $target_path; or return
    cd $target_path
    ls
end
