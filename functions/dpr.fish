function dpr --description "dump repo to agent"
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Error: Not inside a git repository." >&2
        return 1
    end

    set -l repo_name (basename (git rev-parse --show-toplevel))
    echo "<repository name=\"$repo_name\">"
    echo "<file_tree>"
    git ls-tree -r --name-only HEAD
    echo "</file_tree>"
    echo ""

    # 利用 Git 空树对比：全 C 语言执行，瞬间输出所有文件
    # -U100000: 上下文行数拉满（输出完整文件而不是片段）
    # --diff-filter=d: 排除已删除文件
    # Git 会自动识别并跳过 binary 文件（显示 Binary files differ）
    # 并且跳过 *.lock 文件
    git diff --no-color -U100000 4b825dc642cb6eb9a060e54bf8d69288fbee4904 HEAD -- . ':(exclude)*.lock'
    
    echo "</repository>"
end
