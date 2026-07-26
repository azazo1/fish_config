function pd --description "pick a directory"
    set -l args $argv
    if [ (count $args) -lt 1 ]
        set args "."
    end
    set -l target (command fd $args -t d | command fzf)
    if not [ $status -eq 0 ]
        echo "pd: user cancelled."
        return 1
    else if [ -z "$target" ]
        echo "pd: target path is empty"
        return 1
    else
        cd $target && command pwd
    end
end
