# AI 自动生成补全
# 目标工具版本: qwen3-asr 0.1.0
# 参考来源: qwen3-asr --help, qwen3-asr --version, fish complete --help

function __fish_qwen3_asr_needs_value
    set -l token (commandline --current-token)
    string match -q -- '--*=*' $token
    and return 1

    set -l previous (commandline --current-token --tokens-expanded | string split0)[-1]
    contains -- $previous \
        -i --input-file \
        -c --context \
        -l --language \
        --dashscope-api-key \
        -j --num-threads \
        -d --vad-segment-threshold \
        -t --tmp-dir
end

function __fish_qwen3_asr_options_allowed
    not __fish_seen_argument --
    and not __fish_qwen3_asr_needs_value
end

complete -c qwen3-asr -f -n '__fish_qwen3_asr_options_allowed' -s h -l help -d '打印帮助'
complete -c qwen3-asr -f
complete -c qwen3-asr -f -n '__fish_qwen3_asr_options_allowed' -s V -l version -d '打印版本'
complete -c qwen3-asr -f -n '__fish_qwen3_asr_options_allowed' -s s -l silence -d '减少输出'
complete -c qwen3-asr -f -n '__fish_qwen3_asr_options_allowed' -l save-srt -d '保存 SRT 字幕'

complete -c qwen3-asr -n '__fish_qwen3_asr_options_allowed' -s i -l input-file -r -F -d '输入音频文件'
complete -c qwen3-asr -f -n '__fish_qwen3_asr_options_allowed' -s c -l context -r -d '识别上下文提示'
complete -c qwen3-asr -f -n '__fish_qwen3_asr_options_allowed' -s l -l language -x -a 'zh en Chinese English' -d '单一音频语言'
complete -c qwen3-asr -f -n '__fish_qwen3_asr_options_allowed' -l dashscope-api-key -r -d 'DashScope API key'
complete -c qwen3-asr -f -n '__fish_qwen3_asr_options_allowed' -s j -l num-threads -r -d '并行线程数'
complete -c qwen3-asr -f -n '__fish_qwen3_asr_options_allowed' -s d -l vad-segment-threshold -r -d 'VAD 分段阈值'
complete -c qwen3-asr -f -n '__fish_qwen3_asr_options_allowed' -s t -l tmp-dir -x -a '(__fish_complete_directories)' -d '临时目录'
