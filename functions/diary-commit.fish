# ~/.config/fish/functions/diary-commit.fish

function diary-commit
    # 直接对指定仓库执行 commit，只提交 diary/ 目录
    # -C 表示在指定路径执行 git，不改变当前 shell 目录
    git -C ~/pjs/mynote add ~/pjs/mynote/diary/
    git -C ~/pjs/mynote commit -m "diary" -- diary/
    git -C ~/pjs/mynote push
    # 如果提交失败（比如没有更改），会返回非零，但不会中断函数
    # 你也可以添加 or return 来提前退出，但建议保留以便看到错误提示
end

