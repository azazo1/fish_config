fish_add_path --path "$HOME/.local/bin"
fish_add_path --path "$HOME/scripts"

if status is-interactive
    # Commands to run in interactive sessions can go here
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

    function load_dotenv --description "load .env file of current dir"
        set -l env_file ".env.fish"
        if test (count $argv) -ge 1
            set env_file $argv[1]
        end
        # First shell out to source the file in an isolated fashion. This is to
        # ensure "atomicity" where either all settings as sourced or none at all.
        if ! fish --private --no-config --command="source $env_file"
            echo "dotenv: Error sourcing '$env_file' file, bailing." >&2
            return 1
        end

        echo "dotenv: Sourcing '$env_file'" >&2
        source $env_file
    end

    load_dotenv "$__fish_config_dir/.env.fish"

    function dugit --description "disk usage of new files in git staged"
        set -l files (git diff --name-only --diff-filter=ARMC) (git diff --cached --name-only --diff-filter=ARMC)
        set files (echo $files | sort | uniq)
        if [ -z "$files" ]
            echo dugit: No file to analyze.
            return 1
        end
        command du -c -h -d 0 (string split ' ' $files)
    end

    function setup-nerd-font
        set -l font_filename "JetBrainsMonoNLNerdFontMono-Regular.ttf"
        mkdir -p $HOME/tmp && pushd $HOME/tmp || begin; echo "failed to create tmp directory"; exit 1; end;
        curl -LO -C - "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
        unzip JetBrainsMono.zip $font_filename
        echo "Copying font file $font_filename to /usr/share/fonts/myfonts"
        sudo cp $font_filename /usr/share/fonts/myfonts && cd /usr/share/fonts/myfonts && sudo mkfontscale && sudo mkfontdir && sudo fc-cache
        echo "Font $font_filename prepared"
        popd
    end

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            z -- "$cwd"
        end
        command rm -f -- "$tmp"
    end
    alias yazi 'y'

    function pf --description "pick a file"
        set -l args $argv
        if [ (count $args) -lt 1 ]
            echo -e "Usage: pf <file_search_pattern>"
            return 1
        end
        set -l target (command fd $args -t f | command fzf)
        if not [ $status -eq 0 ]
            echo "pf: user cancelled."
            return 1
        else if [ -z "$target" ]
            echo "pf: target path is empty"
            return 1
        else
            open $target
        end
    end

    function pd --description "pick a directory"
        set -l args $argv
        if [ (count $args) -lt 1 ]
            set args "."
        end
        set -l target (command fd $args -t d | command fzf)
        if not [ $status -eq 0 ]
            echo "pd: user cancelled."
            return 1
        else if [ -z "$target" ]
            echo "pd: target path is empty"
            return 1
        else
            cd $target && command pwd
        end
    end

    function tmp --description 'create temp directory'
        set -l target_path
        if [ (count $argv) -gt 0 ]
            set target_path "$HOME/tmp/$(basename $argv[1])"
        else
            set target_path "$HOME/tmp/"
        end
        command mkdir -p $target_path
        cd $target_path
        ls
    end
    complete -c tmp -a '(fd . --max-depth 1 -t d ~/tmp -x basename)' -f

    function mktmp --description 'create temp directory in system temp directory, remove dir when shell quit'
        set -l tmp_path (command mktemp -d -t mktmp)
        if [ (count $argv) -ge 1 ]
            mkdir $tmp_path/$argv[1]
            command fish -C "cd $tmp_path/$argv[1]"
        else
            command fish -C "cd $tmp_path"
        end
        pushd $tmp_path
        for item in (command fd . $tmp_path -d 1)
            set -l item_size (command du -h -d 0 $item | awk '{print $1}')
            set item_disp (command fd -d 1 --color=always '^'$(basename $item)'$') # --full-path "^$(string trim -r -c '/' $item)\$")
            echo '-' $item_disp (set_color yellow)$item_size(set_color normal)
        end
        popd
        set -l tmp_size (command du -h -d 0 $tmp_path | cut -f 1)
        if command rm -rf $tmp_path
            echo (set_color green)Trashed(set_color normal) (dirname $tmp_path)/(set_color blue)(basename $tmp_path)(set_color normal)/ (set_color yellow)$tmp_size(set_color normal)
        else
            echo (set_color red)Not Trash(set_color normal) (dirname $tmp_path)/(set_color blue)(basename $tmp_path)(set_color normal)/ (set_color yellow)$tmp_size(set_color normal)
        end
    end

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
