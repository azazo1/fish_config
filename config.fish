set -gx PATH "$HOME/.local/bin:$PATH"
set -gx PATH "$HOME/scripts:$PATH"
if status is-interactive
    # Commands to run in interactive sessions can go here
    alias ll 'ls -alh'
    alias update '. ~/.config/fish/config.fish'
    alias config 'nvim ~/.config/fish/config.fish'
    alias mynote 'code ~/pjs/mynote'
    alias psrg 'ps aux | rg '
    alias finder 'open -a finder '
    alias configkitty 'nvim ~/.config/kitty/kitty.conf'
    alias lg 'lazygit'
    alias dockert 'docker run --rm -it'

    starship init fish | source
    zoxide init fish | source
    alias cd 'z'

    function setproxy
        set -gx HTTPS_PROXY 'localhost:7890'
        set -gx HTTP_PROXY 'localhost:7890'
    end

    function unsetproxy
        set -e HTTPS_PROXY
        set -e HTTP_PROXY
    end

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

end
set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
test ! -e "$HOME/.x-cmd.root/local/data/fish/rc.fish" || source "$HOME/.x-cmd.root/local/data/fish/rc.fish" # boot up x-cmd.
set -gx UV_DEFAULT_INDEX 'https://pypi.tuna.tsinghua.edu.cn/simple'
