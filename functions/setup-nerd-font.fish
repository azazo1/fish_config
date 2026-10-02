function setup-nerd-font --description 'download jetbrains nerd font and install it to /usr/share/fonts/myfonts'
    __require_cmds setup-nerd-font curl unzip sudo mkfontscale mkfontdir fc-cache; or return

    set -l font_filename JetBrainsMonoNLNerdFontMono-Regular.ttf
    set -l font_dir /usr/share/fonts/myfonts
    mkdir -p $HOME/tmp; and pushd $HOME/tmp
    or begin
        echo "setup-nerd-font: failed to enter ~/tmp" >&2
        return 1
    end

    curl -LO -C - "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
    and unzip -o JetBrainsMono.zip $font_filename
    or begin
        popd
        return 1
    end

    echo "Copying font file $font_filename to $font_dir"
    sudo mkdir -p $font_dir
    and sudo cp $font_filename $font_dir/
    and pushd $font_dir
    and sudo mkfontscale; and sudo mkfontdir; and sudo fc-cache
    and popd
    and echo "Font $font_filename prepared"
    popd
end
