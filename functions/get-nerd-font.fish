function get-nerd-font --description 'download jetbrains nerd font: get-nerd-font [store_dir]'
    __require_cmds get-nerd-font curl unzip; or return

    set -l store_path (pwd)
    if test (count $argv) -ge 1
        set store_path $argv[1]
    end
    if not test -d "$store_path"
        echo "文件夹路径不存在: $store_path" >&2
        return 1
    end

    set -l font_filename JetBrainsMonoNLNerdFontMono-Regular.ttf
    builtin cd $store_path; or return
    curl -LO -C - "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
    and unzip JetBrainsMono.zip $font_filename
end
