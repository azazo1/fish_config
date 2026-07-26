set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
set -gx HOMEBREW_CORE_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

fish_add_path --path "$HOME/.local/bin"
fish_add_path --path "$HOME/scripts"
fish_add_path --path (brew --prefix)/sbin
fish_add_path --path (brew --prefix)/bin
fish_add_path --path (brew --prefix util-linux)/bin
fish_add_path --path (brew --prefix util-linux)/sbin
fish_add_path --path (python3 -m site --user-base)/bin
fish_add_path --path (brew --prefix e2fsprogs)/bin
fish_add_path --path (brew --prefix e2fsprogs)/sbin
fish_add_path --path (go env GOPATH)/bin

set -gx ANDROID_HOME $HOME/Library/Android/sdk
set -gx ANDROID_SDK_ROOT $ANDROID_HOME
fish_add_path --path $ANDROID_HOME/platform-tools
fish_add_path --path $ANDROID_HOME/emulator
fish_add_path --path $ANDROID_HOME/cmdline-tools/latest/bin
fish_add_path --path $ANDROID_HOME/build-tools/36.0.0

set -gx JAVA_HOME /opt/homebrew/opt/openjdk
set -gx CLASSPATH $JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:.
fish_add_path --path $JAVA_HOME/bin

set -gx FISH_DOTENV_FILE "$__fish_config_dir/.env.fish"
set -gx RUSTC_WRAPPER sccache

set -gx NO_PROXY ".local,localhost,.tsinghua.edu.cn,.acodev.top,.wakatime.com"

set -gx COPYFILE_DISABLE 1 # 禁止 tar 打包 ._* 这类的文件

if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    if env | rg -q vscode
        function prevent_csi_u --on-event fish_preexec
            printf '\e[>0u'
        end
    end

    zoxide init fish | source
    command howlto --init | source

    alias d 'dust'
    alias sshcode 'codessh'
    alias brwe 'brew'
    alias ht 'howlto --'
    alias pbc pbcopy
    alias pbp pbpaste
    alias pfc pfcopy
    alias pfp pfpaste
    alias ll 'ls -alh'
    alias sl ls
    alias l ls
    alias update ". $__fish_config_dir/config.fish"
    alias config "nvim $__fish_config_dir/config.fish"
    alias vconfig "code $__fish_config_dir"
    alias configv "code $__fish_config_dir"
    alias mynote 'code ~/pjs/mynote'
    alias pg 'ps aux | command rg '
    alias finder 'open -a finder '
    alias kittyconfig 'nvim ~/.config/kitty/kitty.conf'
    alias sshconfig 'nvim ~/.ssh/config'
    alias lg lazygit
    alias lgn 'lazygit -p ~/pjs/mynote'
    alias lgnote 'lazygit -p ~/pjs/mynote'
    alias dockert 'docker run --rm -it'
    alias dkt 'docker run --rm -it'
    alias dk docker
    alias ldk lazydocker
    alias activate '. ./.venv/bin/activate.fish'
    alias rgs "command rg -S --max-columns 1000"
    alias rgl "command rg -S"
    alias cd z
    alias sizeof 'du -d 0 -h'
    alias kg cargo
    alias del trash
    alias scpy scrcpy
    alias j just
    alias clr clear
    alias uvpy 'uv run python'
    alias fdh 'fd -HI'
    alias configd 'cd $__fish_config_dir'
    alias gdd gdu-diff
    alias cx codex
    # alias cxa 'codex app'
    alias cxa 'open -a ChatGPT .'
    alias cxapp 'codex app'
    alias up 'docker compose up'
    alias down 'docker compose down'
    alias 7z '7zz'

    function rsbuild --description 'set cargo build target directory'
        set -l metadata (command cargo metadata --no-deps --format-version 1)
        if test $status -ne 0
            echo "not in a rust project"
            return 1
        end
        set -l project_root (echo "$metadata" | command jq -r '.workspace_root')
        set -l raw_target_path (echo "$metadata" | command jq -r '.target_directory')
        set -l project_name (basename $project_root)
        set -l build_mount /Volumes/build
        set -l target_path "$build_mount/rs/target/$project_name"
        if not test -d "$build_mount"
            echo "Error: External build volume '$build_mount' not found."
            return 1
        end
        if test -L "$raw_target_path"; and test (readlink "$raw_target_path") = "$target_path"
            echo "Target is already symlinked to $target_path"
            return 0
        end
        if ! mkdir -p "$target_path"
            echo "failed to create external target directory"
            return 1
        end
        set -l cmd "command cargo clean; and command ln -s \"$target_path\" \"$raw_target_path\""
        commandline -r "$cmd"
        echo "Command injected to your prompt. Press [Enter] to execute."
    end
    alias rsdir rsbuild

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

    load_dotenv $FISH_DOTENV_FILE

    function dugit --description "disk usage of new files in git staged"
        set -l files (git diff --name-only --diff-filter=ARMC) (git diff --cached --name-only --diff-filter=ARMC)
        set files (echo $files | sort | uniq)
        if [ -z "$files" ]
            echo dugit: No file to analyze.
            return 1
        end
        command du -c -h -d 0 (string split ' ' $files)
    end

    function tinypw
        command tinypw $argv -c | tail +2
    end

    function sizesof --description "search files and get the sizes of them."
        if test (count $argv) -lt 1
            echo "sizesof requires an argument."
            return 1
        end
        set -l files (command fd -t f $argv)
        command du -h -d 0 $files
    end

    function get-nerd-font --description "download jetbrains nerd font"
        set -l store_path $argv[1]
        set -q $store_path; or set store_path (pwd)
        set -l font_filename "JetBrainsMonoNLNerdFontMono-Regular.ttf"
        if test ! -d $store_path
            echo "文件夹路径不存在: "$store_path
            return 1
        end
        cd $store_path
        curl -LO -C - "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
        unzip JetBrainsMono.zip $font_filename
    end

    function whisper --description 'generate audio subtitle'
        echo (set_color yellow)use "`qwen3-asr -i <file> -srt` instead"(set_color normal)
        return 1
        set -l input_file $argv[1]
        set -l input_file_noext (string replace -r '\.[^/]*$' '' $input_file)
        set -l output_file $input_file_noext
        echo "output file: $output_file.srt"
        command ffmpeg -i $input_file $input_file_noext.wav
        $HOME/portables/whisper.cpp/whisper.cpp-repo/build/bin/whisper-cli --model ~/portables/whisper.cpp/ggml-large-v3-turbo.bin --language auto --print-colors --print-progress --output-srt --file $input_file_noext.wav --output-file $output_file
    end

    function nox --description 'remove x permission for all text file in folder'
        set -l target_path (pwd)
        if [ (count $argv) -ge 1 ]
            set target_path $argv[1]
        end
        echo target_path: $target_path
        for fp in (command fd . -HI -t x $target_path)
            if command file --brief $fp | command rg -q text
                command chmod -x $fp
                echo $fp
            end
        end
    end

    function conda-sh --description 'enter conda shell (sub shell).'
        set -l suffix_command 'echo ""'
        if [ (count $argv) -ge 1 ]
            set suffix_command 'conda activate '$argv[1]
        end
        command fish -C 'eval "$(conda "shell.$(basename "$SHELL")" hook); echo \'Conda shell created.\'; '$suffix_command'"'
    end

    function ds_store_clean --description 'clear all the .DS_Store under specific directory, default is trashing them.'
        argparse r/remove h/help -- $argv # remove instead of trash
        or return 1
        if set -ql _flag_help
            echo "clean_ds_store [-hr]"
            return
        end
        if set -ql _flag_remove
            for file in (command fd -HI '.DS_Store$' -t f)
                echo removing $file ...
                command rm $file # test it first
            end
        else
            for file in (command fd -HI '.DS_Store' -t f)
                echo trashing $file ...
                command trash $file # test it first
            end
        end
    end

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
            echo - $item_disp (set_color yellow)$item_size(set_color normal)
        end
        popd
        set -l tmp_size (command du -h -d 0 $tmp_path | cut -f 1)
        if command trash $tmp_path
            echo (set_color green)Trashed(set_color normal) (dirname $tmp_path)/(set_color blue)(basename $tmp_path)(set_color normal)/ (set_color yellow)$tmp_size(set_color normal)
        else
            echo (set_color red)Not Trash(set_color normal) (dirname $tmp_path)/(set_color blue)(basename $tmp_path)(set_color normal)/ (set_color yellow)$tmp_size(set_color normal)
        end
    end

    function setproxy
        set -l proxy_base "localhost:7890"
        if [ (count $argv) -ge 1 ]
            set proxy_base $argv[1]
        end
        set -gx HTTPS_PROXY $proxy_base
        set -gx HTTP_PROXY $proxy_base
        echo "Proxy on $proxy_base set"
    end

    function setproxyp
        set -l proxy_base "localhost:7890"
        if [ (count $argv) -ge 1 ]
            set proxy_base $argv[1]
        end
        set -gx HTTPS_PROXY http://$proxy_base
        set -gx HTTP_PROXY http://$proxy_base
        echo "Proxy on http://$proxy_base set"
    end

    function unsetproxy
        set -e HTTPS_PROXY
        set -e HTTP_PROXY
        echo "Proxy unset"
    end

    # 直接启用代理
    setproxyp

    function img2webp --description '使用 mogrify 批量转换图片为 WebP'
        argparse 'q/quality=' -- $argv
        or return

        set -l q_val 75
        if set -q _flag_q
            set q_val $_flag_q
        end

        set -l targets $argv
        if test (count $targets) -eq 0
            set targets *.{png,jpg,jpeg,bmp,gif,PNG,JPG,JPEG,BMP,GIF}
        end

        if not set -q targets[1]; or not test -f "$targets[1]"
            echo "未发现可转换的文件. "
            return 1
        end

        echo "正在批量转换 (Quality: $q_val)..."

        magick mogrify -format webp -quality $q_val $targets

        echo "转换任务已通过 mogrify 批量完成."
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
    bind --user -s -M insert super-l accept-autosuggestion
    bind --user -s -M insert ctrl-j accept-autosuggestion

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            z -- "$cwd"
        end
        command rm -f -- "$tmp"
    end
    alias yazi y

    function rm --description "sort rm args"
        set -l opts
        set -l files
        set -l after_double_dash 0

        for arg in $argv
            if test $after_double_dash -eq 1
                # 进入 -- 模式，后面都当文件
                set files $files $arg
            else if test "$arg" = --
                set after_double_dash 1
                # 把 -- 本身也传给 rm（保持一致）
                set files $files --
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

    # command fzf --fish | source
end

test ! -e "$HOME/.x-cmd.root/local/data/fish/rc.fish" || source "$HOME/.x-cmd.root/local/data/fish/rc.fish" # boot up x-cmd.
set -gx UV_DEFAULT_INDEX 'https://pypi.tuna.tsinghua.edu.cn/simple'
# set -gx UV_LINK_MODE 'symlink' # 如果使用软连接的话, 清除 uv 的缓存可能会导致项目环境被破坏.

# bun {{{
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path --path $BUN_INSTALL/bin
# }}}

# set editor of this shell
if test -f "$(which nvim)"
    set -gx EDITOR nvim
end
