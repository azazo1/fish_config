fish_add_path --path "$HOME/.local/bin"
fish_add_path --path "$HOME/scripts"

if status is-interactive
    # Commands to run in interactive sessions can go here
    alias d 'dust'
    alias ht 'howlto --'
    alias update ". $__fish_config_dir/config.fish"
    alias config "nvim $__fish_config_dir/config.fish"
    alias vconfig "code $__fish_config_dir/config.fish"
    alias activate "source ./.venv/bin/activate.fish"
    alias pg 'ps aux | command rg '
    alias rgl "command rg -S"
    alias dkt 'docker run -v tmpapp:/app --rm -it'
    alias ll 'ls -lha'
    alias l 'ls'
    alias sl 'ls'
    alias lzd 'lazydocker'
    alias dk 'docker'
    alias lg 'lazygit'
    alias kg 'cargo'
    alias lgnote 'lazygit -p ~/pjs/mynote'
    alias lgn 'lazygit -p ~/pjs/mynote'
    alias configd 'cd $__fish_config_dir'
    alias j 'just'
    alias pwsh "/mnt/c/'program files'/powershell/7/pwsh.exe"

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
    bind --user -s -M insert super-l accept-autosuggestion
    bind --user -s -M insert ctrl-j accept-autosuggestion

    load_dotenv "$__fish_config_dir/.env.fish"

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            z -- "$cwd"
        end
        command rm -f -- "$tmp"
    end
    alias yazi 'y'

    complete -c tmp -a '(fd . --max-depth 1 -t d ~/tmp -x basename)' -f

    set -g PROXY_BASE "localhost:7890"
    function setproxy
        set -gx HTTPS_PROXY $PROXY_BASE
        set -gx HTTP_PROXY $PROXY_BASE
        echo "Proxy on $PROXY_BASE set"
    end

    function setproxyp
        set -gx HTTPS_PROXY "http://$PROXY_BASE"
        set -gx HTTP_PROXY "http://$PROXY_BASE"
        echo "Proxy on http://$PROXY_BASE set"
    end

    function unsetproxy
        set -e HTTPS_PROXY
        set -e HTTP_PROXY
        echo "Proxy unset"
    end

    # --- apps ---

    # starship {
    starship init fish | source
    # }

    # zoxide {
    zoxide init fish | source
    alias cd "z"
    # }
end

set -gx UV_DEFAULT_INDEX "https://pypi.tuna.tsinghua.edu.cn/simple"
