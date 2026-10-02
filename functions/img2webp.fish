function img2webp --description '使用 mogrify 批量转换图片为 WebP'
    argparse 'q/quality=' -- $argv
    or return
    __require_cmds img2webp magick; or return

    set -l q_val 75
    if set -q _flag_q
        set q_val $_flag_q
    end

    set -l targets $argv
    if test (count $targets) -eq 0
        set targets *.{png,jpg,jpeg,bmp,gif,PNG,JPG,JPEG,BMP,GIF}
    end

    if not set -q targets[1]; or not test -f "$targets[1]"
        echo "未发现可转换的文件." >&2
        return 1
    end

    echo "正在批量转换 (Quality: $q_val)..."
    magick mogrify -format webp -quality $q_val $targets
    echo "转换任务已通过 mogrify 批量完成."
end
