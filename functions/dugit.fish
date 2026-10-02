function dugit --description 'disk usage of added or modified files in git'
    __require_cmds dugit git; or return
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "dugit: Not inside a git repository." >&2
        return 1
    end

    # 按行处理, 保证含空格的文件名不会被拆开.
    set -l files (begin
            git diff --name-only --diff-filter=ARMC
            git diff --cached --name-only --diff-filter=ARMC
        end | sort -u)
    if not set -q files[1]
        echo "dugit: No file to analyze." >&2
        return 1
    end
    command du -c -h -d 0 -- $files
end
