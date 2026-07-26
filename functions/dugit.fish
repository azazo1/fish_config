function dugit --description "disk usage of new files in git staged"
    set -l files (git diff --name-only --diff-filter=ARMC) (git diff --cached --name-only --diff-filter=ARMC)
    set files (echo $files | sort | uniq)
    if [ -z "$files" ]
        echo dugit: No file to analyze.
        return 1
    end
    command du -c -h -d 0 (string split ' ' $files)
end
