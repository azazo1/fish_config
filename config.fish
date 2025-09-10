if status is-interactive
    # Commands to run in interactive sessions can go here
    alias update "source ~/.config/fish/config.fish"
    alias config "vim ~/.config/fish/config.fish"
    alias nconfig "nvim ~/.config/fish/config.fish"
    alias mp "multipass"
    alias activate "source ./.venv/bin/activate.fish"
    alias rg '/usr/bin/rg -g "!*.html"'
    alias rghtml '/usr/bin/rg -g "*.html"'
    alias mountd "sudo mount -r UUID='00460A96460A8C9A' /mnt/d"
    alias mountc "sudo mount -r UUID='978E7B4F0DDA02C8' /mnt/c"
    alias umountd "sudo umount /mnt/d"
    alias umountc "sudo umount /mnt/c"
    alias dockert 'docker run -v tmpapp:/app --rm -it'
    alias ll 'ls -lha'
    alias lzd 'lazydocker'
    fish_hybrid_key_bindings
    # Delete every ctrl-m ctrl-p ctrl-n key bindings.
    bind -e --preset -M insert ctrl-p ctrl-n
    bind -e --preset -M visual ctrl-p ctrl-n
    bind -e --preset ctrl-l
    bind -e --preset -M visual ctrl-l
    bind -e --preset -M insert ctrl-l

    bind --user -M insert ctrl-p up-or-search
    bind --user -M visual ctrl-p up-or-search
    bind --user -M insert ctrl-n down-or-search
    bind --user -M visual ctrl-n down-or-search
    bind --user -s -M insert alt-l accept-autosuggestion

    # --- apps ---

    # starship {
    starship init fish | source
    # }

    # zoxide {
    zoxide init fish | source
    alias cd "z"
    # }

    # uv {
    echo 'uv generate-shell-completion fish | source' > ~/.config/fish/completions/uv.fish
    echo 'uvx --generate-shell-completion fish | source' > ~/.config/fish/completions/uvx.fish
    # }

    # nvim {
    set -gx PATH "/opt/nvim-linux-x86_64/bin:$PATH"
    # }

    # x-cmd {
    test ! -e "$HOME/.x-cmd.root/local/data/fish/rc.fish" || source "$HOME/.x-cmd.root/local/data/fish/rc.fish" # boot up x-cmd.
    # }
end

set -gx UV_DEFAULT_INDEX "https://pypi.tuna.tsinghua.edu.cn/simple"

function setproxy
    set -gx HTTPS_PROXY localhost:7890
    set -gx HTTP_PROXY localhost:7890
end

function unsetproxy
    set -e HTTPS_PROXY HTTP_PROXY
end

# --- apps ---

# rust {
# source "$HOME/.cargo/env" # shell 语法不兼容, 无法加载
# }

# uv
# source "$HOME/.local/bin/env" # shell 语法不兼容, 无法加载
# }

# bun {
set -gx BUN_INSTALL "$HOME/.bun"
set -gx PATH "$BUN_INSTALL/bin:$PATH"
# }

# cmake {
set -gx PATH "~/portables/cmake-4.1.0-rc4-linux-x86_64/bin:$PATH"
# }

# go {
set -gx GOPATH "$HOME/.go"
set -gx GOROOT "$HOME/.local/go"
set -gx PATH "$GOROOT/bin:$GOPATH/bin:$PATH"
# }
