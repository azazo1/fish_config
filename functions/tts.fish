function tts --description 'macOS 文本转语音, 支持直接播放或导出 mp3'
    # 用法:
    #   tts "你好"                          直接朗读
    #   tts "你好" -o hello.mp3             导出 mp3
    #   tts "你好" --reverse                倒放朗读
    #   tts "你好" --reverse -o hello.mp3   导出倒放的 mp3
    #   tts "你好" -v Tingting -r 200       指定语音和语速
    #   tts -l                              列出可用语音
    argparse --name=tts 'h/help' 'l/list' 'o/output=' 'v/voice=' 'r/rate=' 'reverse' -- $argv
    or return

    if set -q _flag_help
        printf '%s\n' \
            '用法: tts [选项] <文本...>' \
            '' \
            '选项:' \
            '  -o, --output <file>   导出 mp3 文件, 缺省后缀 .mp3 自动补全' \
            '  -v, --voice <name>    指定语音, 如 Tingting, 缺省跟随系统' \
            '  -r, --rate <wpm>      语速, 单位词每分钟, 缺省约 175' \
            '      --reverse         把音频倒过来, 播放和导出都生效' \
            '  -l, --list            列出系统可用语音' \
            '  -h, --help            显示本帮助' \
            '' \
            '示例:' \
            '  tts "你好"' \
            '  tts "你好" -o hello.mp3' \
            '  tts "你好" --reverse' \
            '  tts "你好" --reverse -o hello.mp3' \
            '  tts "你好" -v Tingting -r 200 -o hello.mp3'
        return 0
    end

    if set -q _flag_list
        say -v '?'
        return 0
    end

    if test (count $argv) -eq 0
        echo "tts: 缺少要朗读的文本, 用 tts -h 查看用法" >&2
        return 1
    end

    set -l text (string join ' ' -- $argv)

    set -l say_args
    if set -q _flag_voice
        set -a say_args -v $_flag_voice
    end
    if set -q _flag_rate
        set -a say_args -r $_flag_rate
    end

    set -l do_reverse 0
    if set -q _flag_reverse
        set do_reverse 1
    end

    # 播放且不倒放: 直接交给 say, 不落任何临时文件
    if test $do_reverse -eq 0; and not set -q _flag_output
        say $say_args -- $text
        return $status
    end

    # 剩余路径 (倒放播放, 普通导出, 倒放导出) 都要先合成音频
    set -l need ffmpeg
    if test $do_reverse -eq 1; and not set -q _flag_output
        set -a need afplay
    end
    __require_cmds tts $need; or return

    set -l tmpdir (command mktemp -d -t tts); or return
    set -l audio $tmpdir/speech.aiff

    say $say_args -o $audio -- $text
    set -l say_status $status
    if test $say_status -ne 0
        command rm -rf -- $tmpdir
        echo "tts: say 生成音频失败, 退出码 $say_status" >&2
        return $say_status
    end

    # 倒放: 用 ffmpeg 把整段音频反向
    if test $do_reverse -eq 1
        set -l reversed $tmpdir/reversed.aiff
        ffmpeg -hide_banner -loglevel error -y -i $audio -af areverse -- $reversed
        set -l rev_status $status
        if test $rev_status -ne 0
            command rm -rf -- $tmpdir
            echo "tts: ffmpeg 反向音频失败, 退出码 $rev_status" >&2
            return $rev_status
        end
        set audio $reversed
    end

    # 倒放播放
    if not set -q _flag_output
        afplay $audio
        set -l play_status $status
        command rm -rf -- $tmpdir
        return $play_status
    end

    # 导出 mp3
    set -l out $_flag_output
    string match -qi '*.mp3' -- $out; or set out "$out.mp3"

    ffmpeg -hide_banner -loglevel error -y -i $audio -codec:a libmp3lame -qscale:a 2 -- $out
    set -l ff_status $status
    command rm -rf -- $tmpdir
    if test $ff_status -ne 0
        echo "tts: ffmpeg 转换 mp3 失败, 退出码 $ff_status" >&2
        return $ff_status
    end

    echo "已生成: "(path resolve -- $out)
    return 0
end
