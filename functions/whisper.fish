function whisper --description 'deprecated, use qwen3-asr instead'
    echo (set_color yellow)use "`qwen3-asr -i <file> -srt` instead"(set_color normal) >&2
    return 1
end
