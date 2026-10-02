function diary-commit --description 'commit and push ~/pjs/mynote/diary'
    __require_cmds diary-commit git; or return
    set -l repo ~/pjs/mynote
    if not test -d $repo/diary
        echo "diary-commit: $repo/diary not found." >&2
        return 1
    end

    # -C 在指定仓库执行 git, 不改变当前 shell 目录, 只提交 diary/ 目录.
    git -C $repo add $repo/diary/
    git -C $repo commit -m diary -- diary/
    # 没有新改动时 commit 会失败, 仍继续 push 以推送之前未推送的提交.
    git -C $repo push
end
