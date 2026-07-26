function setup-nerd-font
    set -l font_filename "JetBrainsMonoNLNerdFontMono-Regular.ttf"
    mkdir -p $HOME/tmp && pushd $HOME/tmp || begin
        echo "failed to create tmp directory"
        exit 1
    end

    curl -LO -C - "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
    unzip JetBrainsMono.zip $font_filename
    echo "Copying font file $font_filename to /usr/share/fonts/myfonts"
    sudo cp $font_filename /usr/share/fonts/myfonts && cd /usr/share/fonts/myfonts && sudo mkfontscale && sudo mkfontdir && sudo fc-cache
    echo "Font $font_filename prepared"
    popd
end
