function dpg --description 'dump git diff to agent'
    set -lx GIT_PAGER cat
    if test (count $argv) -ge 1
        git diff $argv[1]
    else
        echo "=== staged ==="
        git diff --cached
        echo "=== unstaged ==="
        git diff
    end
end

