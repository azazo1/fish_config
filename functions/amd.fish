# ~/.config/fish/functions/amd.fish
function amd --description '生成设备探索 agent 提示词并复制到系统剪贴板'
    set -l cwd (pwd)

    function osc-copy --description '把 stdin 通过 OSC 52 复制到剪贴板'
        read -z -l data
        set -l data (string trim -r -c "\n" -- $data)
        set -l p (printf "<paste>\n%s\n</paste>" "$data" | base64 | tr -d "\n\r")
        printf "\e]52;c;%s\a" $p > /dev/tty
    end

    # 自动发现 ~/.dsh/skills 下的技能 (读取 SKILL.md frontmatter 的 name/description)
    set -l skills_dir ~/.dsh/skills
    set -l skill_lines
    if test -d $skills_dir
        for sdir in $skills_dir/*
            test -d $sdir; or continue
            set -l smd $sdir/SKILL.md
            test -f $smd; or continue
            set -l sname
            set -l sdesc
            set -l in_fm 0
            while read -l sline
                if test $in_fm -eq 0
                    if test "$sline" = "---"
                        set in_fm 1
                    end
                    continue
                end
                if test "$sline" = "---"
                    break
                end
                if test -z "$sname"
                    if string match -qr "^name:" -- $sline
                        set sname (string replace -r "^name:[[:space:]]*" "" -- $sline)
                    end
                end
                if test -z "$sdesc"
                    if string match -qr "^description:" -- $sline
                        set sdesc (string replace -r "^description:[[:space:]]*" "" -- $sline)
                    end
                end
            end < $smd
            if test -z "$sname"
                set sname (basename (string trim -r -c / -- $sdir))
            end
            if test -n "$sdesc"
                set -a skill_lines "- $sname: $sdesc"
            else
                set -a skill_lines "- $sname"
            end
        end
    end
    set -l prompt \
        "当前工作目录: $cwd" \
        '' \
        '# 如何获取命令输出' \
        '' \
        '你的 stdout 无法被直接读取. 要读取命令输出, 请用 OSC 52' \
        '转义序列把它复制到系统剪贴板, 然后从剪贴板读取.' \
        '' \
        'osc-copy 已经定义好, 直接用:' \
        '' \
        '' \
        '之后所有需要读取输出的命令都写成:' \
        '' \
        '    begin' \
        '        <你的命令>' \
        '    end 2>&1 | osc-copy' \
        '' \
        '# 示例' \
        '    begin' \
        '        pwd' \
        '        ls -la' \
        '        uname -a' \
        '    end 2>&1 | osc-copy' \
        '' \
        '# 要求' \
        '每次都只能发送一个代码块, 用户执行之后返回剪贴板内容给你.' \
        '输出命令块之前, 先用一句话简短叙述这一步的目的.' \
        '剪贴板内容会被 <paste>...</paste> 包裹, 中间就是命令输出.' \
        '' \
        '说明前用方括号标记本步性质, 例如 [只读] [写入] [执行].' \
        '# 编辑文件' \
        '优先局部替换, 不要整文件重写.' \
        '推荐 python3 -c 内联脚本做替换, 幂等可重跑.' \
        '脚本里用 chr(92) chr(10) chr(39) 生成反斜杠/换行/单引号,' \
        '避开 fish 单引号里的转义问题.' \
        '' \
        '# 可用技能 skills' \
        '' \
        '以下技能由 ~/.dsh/skills 自动发现, 任务匹配时读取 ~/.dsh/skills/<name>/SKILL.md 获取完整流程:' \
        '' \
        $skill_lines \
        '' \
        '# 任务' \
        '' \
        '利用上述方式探索当前设备中的内容, 定位并解决问题.' \
        '' \
        '# 用户要求' \
        ''

    set -l text (printf '%s\n' $prompt | string collect -N)

    set -l payload (printf '%s' "$text" | base64 | tr -d '\n\r')

    printf '\e]52;c;%s\a' $payload > /dev/tty

    echo "agent 提示词已复制到剪贴板 (cwd: $cwd)"
end
