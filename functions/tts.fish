function tts --description 'macOS 文本转语音, 直接播放或导出 mp3'
    # 用法:
    #   tts "你好"                          直接朗读
    #   tts "你好" -o hello.mp3             导出 mp3
    #   tts "你好" -o -                     把 mp3 写到标准输出
    #   tts "你好" -v Tingting -r 200       指定语音和语速
    #   tts -l                              列出可用语音
    argparse --name=tts 'h/help' 'l/list' 'o/output=' 'v/voice=' 'r/rate=' -- $argv
    or return

    if set -q _flag_help
        printf '%s\n' \
            '用法: tts [选项] <文本...>' \
            '' \
            '选项:' \
            '  -o, --output <file>   导出 mp3, 传 - 表示写到标准输出' \
            '  -v, --voice <name>    指定语音, 如 Tingting, 缺省跟随系统' \
            '  -r, --rate <wpm>      语速, 单位词每分钟, 缺省约 175' \
            '  -l, --list            列出系统可用语音' \
            '  -h, --help            显示本帮助' \
            '' \
            '示例:' \
            '  tts "你好"' \
            '  tts "你好" -o hello.mp3' \
            '  tts "你好" -o - | sound-play -' \
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

    # 不带 -o: 直接交给 say 播放, 不落任何临时文件
    if not set -q _flag_output
        say $say_args -- $text
        return $status
    end

    # 带 -o 时都要先合成音频再用 ffmpeg 编码
    __require_cmds tts ffmpeg; or return

    set -l to_stdout 0
    if test "$_flag_output" = -
        set to_stdout 1
        # 二进制直接打到终端没有意义, 也会污染会话
        if command test -t 1
            echo 'tts: 输出到标准输出时请重定向到文件或接入管道, 不要直接输出到终端' >&2
            return 1
        end
    end

    set -l tmpdir (command mktemp -d -t tts); or return
    set -l aiff $tmpdir/speech.aiff

    say $say_args -o $aiff -- $text
    if test $status -ne 0
        command rm -rf -- $tmpdir
        echo "tts: say 生成音频失败, 退出码 $status" >&2
        return 1
    end

    # 标准输出: 让 ffmpeg 把 mp3 直接写进管道
    if test $to_stdout -eq 1
        ffmpeg -hide_banner -loglevel error -y -i $aiff -codec:a libmp3lame -qscale:a 2 -f mp3 pipe:1
        set -l pipe_status $status
        command rm -rf -- $tmpdir
        return $pipe_status
    end

    set -l out $_flag_output
    string match -qi '*.mp3' -- $out; or set out "$out.mp3"

    ffmpeg -hide_banner -loglevel error -y -i $aiff -codec:a libmp3lame -qscale:a 2 -- $out
    set -l ff_status $status
    command rm -rf -- $tmpdir
    if test $ff_status -ne 0
        echo "tts: ffmpeg 转换 mp3 失败, 退出码 $ff_status" >&2
        return $ff_status
    end

    echo "已生成: "(path resolve -- $out)
    return 0
end
