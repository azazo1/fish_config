function sound-play --description '播放音频文件或标准输入, 支持 --reverse'
    # 用法:
    #   sound-play hello.mp3              播放音频文件
    #   sound-play a.mp3 b.mp3            依次播放多个文件
    #   sound-play -                      从标准输入读音频
    #   sound-play hello.mp3 --reverse    倒放
    #   tts "你好" -o - | sound-play -    与 tts 管道串联
    argparse --name=sound-play 'h/help' 'r/reverse' -- $argv
    or return

    if set -q _flag_help
        printf '%s\n' \
            '用法: sound-play [选项] <音频文件...|->' \
            '' \
            '选项:' \
            '  -r, --reverse   把音频倒过来再播放' \
            '  -h, --help      显示本帮助' \
            '' \
            '说明:' \
            '  不给出输入时从标准输入读取, - 也表示标准输入.' \
            '  文件直接交给 afplay, 标准输入经 ffmpeg 解码.' \
            '' \
            '示例:' \
            '  sound-play hello.mp3' \
            '  sound-play hello.mp3 --reverse' \
            '  tts "你好" -o - | sound-play -' \
            '  tts "你好" -o - | sound-play - --reverse'
        return 0
    end

    set -l do_reverse 0
    if set -q _flag_reverse
        set do_reverse 1
    end

    set -l inputs $argv
    if test (count $inputs) -eq 0
        set inputs -
    end

    set -l has_stdin 0
    for input in $inputs
        if test "$input" = -
            set has_stdin 1
        end
    end

    # 文件直接播时只需要 afplay, 标准输入或倒放才需要 ffmpeg
    set -l need afplay
    if test $do_reverse -eq 1; or test $has_stdin -eq 1
        set -a need ffmpeg
    end
    __require_cmds sound-play $need; or return

    set -l tmpdir
    if test $do_reverse -eq 1; or test $has_stdin -eq 1
        set tmpdir (command mktemp -d -t sound-play); or return
    end

    set -l index 0
    for input in $inputs
        set index (math $index + 1)
        set -l audio $input

        if test "$input" = -
            # 标准输入没有扩展名可依赖, 统一用 ffmpeg 解成 wav
            if command test -t 0
                echo 'sound-play: 需要从标准输入读取音频, 但标准输入是终端' >&2
                command rm -rf -- $tmpdir
                return 1
            end
            set -l raw $tmpdir/stdin-$index.bin
            command cat > $raw
            set audio $tmpdir/stdin-$index.wav
            ffmpeg -hide_banner -loglevel error -y -i $raw -f wav -- $audio
            if test $status -ne 0
                echo 'sound-play: ffmpeg 无法解码标准输入中的音频' >&2
                command rm -rf -- $tmpdir
                return 1
            end
        else if not test -f "$input"
            echo "sound-play: 找不到音频文件: $input" >&2
            test -n "$tmpdir"; and command rm -rf -- $tmpdir
            return 1
        end

        if test $do_reverse -eq 1
            set -l rev $tmpdir/reversed-$index.wav
            ffmpeg -hide_banner -loglevel error -y -i $audio -af areverse -f wav -- $rev
            if test $status -ne 0
                echo "sound-play: ffmpeg 反向音频失败: $input" >&2
                command rm -rf -- $tmpdir
                return 1
            end
            set audio $rev
        end

        afplay $audio
        set -l play_status $status
        if test $play_status -ne 0
            echo "sound-play: 播放失败: $input" >&2
            test -n "$tmpdir"; and command rm -rf -- $tmpdir
            return $play_status
        end
    end

    test -n "$tmpdir"; and command rm -rf -- $tmpdir
    return 0
end
