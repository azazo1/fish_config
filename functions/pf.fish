function pf --description "pick a file"
    set -l args $argv
    if [ (count $args) -lt 1 ]
        echo -e "Usage: pf <file_search_pattern>"
        return 1
    end
    set -l target (command fd $args -t f | command fzf)
    if not [ $status -eq 0 ]
        echo "pf: user cancelled."
        return 1
    else if [ -z "$target" ]
        echo "pf: target path is empty"
        return 1
    else
        open $target
    end
end
