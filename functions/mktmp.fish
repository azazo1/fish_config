function mktmp --description 'create a temporary directory and remove it after the child shell exits'
    if test (count $argv) -gt 1
        printf '%s\n' 'mktmp: 最多只能指定一个子目录名' >&2
        return 2
    end

    set -l dir_name
    if test (count $argv) -eq 1
        set dir_name $argv[1]

        # 仅接受单层目录名, 防止参数逃逸到临时目录之外.
        if test -z "$dir_name"; or test "$dir_name" = .; or test "$dir_name" = ..; or string match -q '*/*' -- "$dir_name"
            printf '%s\n' 'mktmp: 子目录名不能为空, ., .., 或包含 /' >&2
            return 2
        end
    end

    # Linux 默认使用 /tmp, 仅在 TMPDIR 为可用的绝对路径时才采用它.
    set -l tmp_root /tmp
    if set -q TMPDIR; and test -n "$TMPDIR"; and string match -rq '^/' -- "$TMPDIR"; and test -d "$TMPDIR"; and test -w "$TMPDIR"
        set -l candidate (string replace -r '/+$' '' -- "$TMPDIR")
        if test -n "$candidate"
            set tmp_root $candidate
        end
    end

    set -l tmp_path (command mktemp -d "$tmp_root/mktmp.XXXXXXXXXX")
    set -l mktemp_status $status
    if test $mktemp_status -ne 0; or test (count $tmp_path) -ne 1
        printf '%s\n' 'mktmp: 创建临时目录失败' >&2
        return 1
    end

    if not test -d "$tmp_path"
        printf '%s\n' 'mktmp: mktemp 未返回有效目录' >&2
        return 1
    end

    set -l tmp_name (string replace -r '^.*/' '' -- "$tmp_path")
    if test "$tmp_path" != "$tmp_root/$tmp_name"; or not string match -rq '^mktmp\.[A-Za-z0-9]+$' -- "$tmp_name"
        printf '%s\n' 'mktmp: mktemp 返回了非预期路径, 已拒绝继续' >&2
        return 1
    end

    if not command chmod 700 -- "$tmp_path"
        command rm -rf --one-file-system --preserve-root=all -- "$tmp_path"
        printf '%s\n' 'mktmp: 无法限制临时目录权限' >&2
        return 1
    end

    # 保存创建时的设备号和 inode, 清理前用于检测路径替换.
    set -l tmp_identity (command stat -c '%d:%i' -- "$tmp_path" 2>/dev/null)
    if test $status -ne 0; or test -z "$tmp_identity"
        command rm -rf --one-file-system --preserve-root=all -- "$tmp_path"
        printf '%s\n' 'mktmp: 无法记录临时目录标识' >&2
        return 1
    end

    set -l work_path $tmp_path
    if test -n "$dir_name"
        set work_path "$tmp_path/$dir_name"
        if not command mkdir -- "$work_path"
            command rm -rf --one-file-system --preserve-root=all -- "$tmp_path"
            printf '%s\n' 'mktmp: 创建子目录失败' >&2
            return 1
        end
    end

    # 工作目录通过环境变量传入, 不拼接到 fish 命令字符串中.
    command env __MKTMP_WORK_PATH="$work_path" fish -C 'builtin cd -- "$__MKTMP_WORK_PATH"; or exit 1; set -e __MKTMP_WORK_PATH'
    set -l shell_status $status

    if not test -e "$tmp_path"; and not test -L "$tmp_path"
        printf '%s\n' 'mktmp: 临时目录已被移除'
        return $shell_status
    end

    set -l current_identity (command stat -c '%d:%i' -- "$tmp_path" 2>/dev/null)
    if test $status -ne 0; or test "$current_identity" != "$tmp_identity"
        printf '%s\n' "mktmp: 目录路径已被替换, 拒绝删除: $tmp_path" >&2
        return 1
    end

    command find "$tmp_path" -mindepth 1 -maxdepth 1 -print0 2>/dev/null |
        while read --null item
            set -l item_name (string replace -- "$tmp_path/" '' "$item")
            set item_name (string escape -- "$item_name")

            set -l suffix
            if test -d "$item"
                set suffix /
            end

            set -l item_size (command du -sh -- "$item" 2>/dev/null | command awk '{print $1}')
            if test -z "$item_size"
                set item_size '?'
            end

            printf '%s%s%s%s%s %s%s%s\n' '- ' (set_color blue) "$item_name" "$suffix" (set_color normal) (set_color yellow) "$item_size" (set_color normal)
        end

    set -l tmp_size (command du -sh -- "$tmp_path" 2>/dev/null | command awk '{print $1}')
    if test -z "$tmp_size"
        set tmp_size '?'
    end

    # 删除前再校验一次, 尽量缩小路径竞态窗口.
    set current_identity (command stat -c '%d:%i' -- "$tmp_path" 2>/dev/null)
    if test $status -ne 0; or test "$current_identity" != "$tmp_identity"
        printf '%s\n' "mktmp: 目录路径已被替换, 拒绝删除: $tmp_path" >&2
        return 1
    end

    if command rm -rf --one-file-system --preserve-root=all -- "$tmp_path"
        printf '%sTrashed%s %s%s/%s %s%s%s\n' (set_color green) (set_color normal) (set_color blue) "$tmp_path" (set_color normal) (set_color yellow) "$tmp_size" (set_color normal)
    else
        printf '%sNot trashed%s %s%s/%s %s%s%s\n' (set_color red) (set_color normal) (set_color blue) "$tmp_path" (set_color normal) (set_color yellow) "$tmp_size" (set_color normal) >&2
        return 1
    end

    return $shell_status
end
