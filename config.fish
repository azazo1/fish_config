set -gx PATH "$HOME/.local/bin:$PATH"
set -gx PATH "$HOME/scripts:$PATH"
if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    zoxide init fish | source

    alias ll 'ls -alh'
    alias update '. ~/.config/fish/config.fish'
    alias config 'nvim ~/.config/fish/config.fish'
    alias mynote 'code ~/pjs/mynote'
    alias pg 'ps aux | command rg '
    alias finder 'open -a finder '
    alias configkitty 'nvim ~/.config/kitty/kitty.conf'
    alias lg 'lazygit'
    alias dockert 'docker run --rm -it'
    alias activate '. ./.venv/bin/activate'
    alias rg "command rg -S --max-columns 1000"
    alias rgl "command rg -S"
    alias cd 'z'
    alias sizeof 'du -d 0'
    alias tmp 'cd ~/tmp/'

    function setproxy
        set -gx HTTPS_PROXY 'localhost:7890'
        set -gx HTTP_PROXY 'localhost:7890'
        echo "Proxy on localhost:7890 set"
    end

    function unsetproxy
        set -e HTTPS_PROXY
        set -e HTTP_PROXY
        echo "Proxy unset"
    end
    set -gx NO_PROXY "localhost,.tsinghua.edu.cn,.acodev.top,.wakatime.com,$NO_PROXY"

    # 直接启用代理
    setproxy

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

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            z -- "$cwd"
        end
        command rm -f -- "$tmp"
    end
    alias yazi 'y'

    function rm --description "sort rm args"
        set -l opts
        set -l files
        set -l after_double_dash 0

        for arg in $argv
            if test $after_double_dash -eq 1
                # 进入 -- 模式，后面都当文件
                set files $files $arg
            else if test "$arg" = "--"
                set after_double_dash 1
                # 把 -- 本身也传给 rm（保持一致）
                set files $files "--"
            else if string match -qr '^-' -- $arg
                set opts $opts $arg
            else
                set files $files $arg
            end
        end

        command rm $opts $files
    end

    function launchctl-restart --description "restart a service, arg is a domain like com.example.application1[.plist] or it's path"
        if test -z "$argv"
            echo "launchctl-restart: argument required."
            return 1
        end
        set -l domain (basename (string replace --regex '(.+)\.plist$' '$1' $argv[1]))
        echo "launchctl-restart: bootouting $domain..."
        command launchctl bootout gui/(id -u)/$domain
        echo "launchctl-restart: bootstrapping $domain..."
        command launchctl bootstrap gui/(id -u) "$domain.plist"
        sleep 2s
        command launchctl list | head -n 1
        command launchctl list | command rg $domain
    end
end

set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
set -gx HOMEBREW_CORE_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

test ! -e "$HOME/.x-cmd.root/local/data/fish/rc.fish" || source "$HOME/.x-cmd.root/local/data/fish/rc.fish" # boot up x-cmd.
set -gx UV_DEFAULT_INDEX 'https://pypi.tuna.tsinghua.edu.cn/simple'

# bun {{{
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
# }}}

# set editor of this shell
if test -f "$(which nvim)"
    set -gx EDITOR 'nvim'
end
