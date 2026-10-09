# 双平台共用别名, 平台专属别名放在 platform.fish 中.
# 别名只在调用时才会解析目标命令, 只有会遮蔽已有命令的别名需要前置检查.

# 配置 {
alias update ". $__fish_config_dir/config.fish"
alias config "nvim $__fish_config_dir/config.fish"
alias vconfig "code $__fish_config_dir"
alias configv "code $__fish_config_dir"
alias configd "cd $__fish_config_dir"
alias kittyconfig 'nvim ~/.config/kitty/kitty.conf'
alias sshconfig 'nvim ~/.ssh/config'
alias ad 'nvim ~/.dsh/AGENTS.md'
alias ac 'nvim ~/.codex/AGENTS.md'
# }

# lazygit {
alias lg lazygit
alias lgc 'command lazygit -p ~/.config/fish'
alias lgd 'command lazygit -p ~/.dsh'
alias lgdsh 'command lazygit -p ~/.dsh'
alias lga 'command lazygit -p ~/.config/codex'
alias lgn 'lazygit -p ~/pjs/mynote'
alias lgnote 'lazygit -p ~/pjs/mynote'
# }

# docker {
alias dk docker
alias dkt 'docker run --rm -it'
alias dockert 'docker run --rm -it'
alias ldk lazydocker
alias lzd lazydocker
alias up 'docker compose up'
alias down 'docker compose down'
# }

# 文件与搜索 {
alias ll 'ls -alh'
alias l ls
alias sl ls
alias rp realpath
alias d dust
alias sizeof 'du -d 0 -h'
alias fdh 'fd -HI'
alias rgs 'command rg -S --max-columns 1000'
alias rgl 'command rg -S'
alias pg 'ps aux | command rg '
alias gdd gdu-diff
if command -q trash
    alias del trash
end
if command -q yazi
    alias yazi y
end
# }

# 开发 {
alias g git
alias j just
alias jr 'just run'
alias kg cargo
alias kgr 'cargo run --'
alias uvpy 'uv run python'
alias activate '. ./.venv/bin/activate.fish'
alias cc claude
alias ht 'howlto --'
alias dsho dsh-open
# }

# 其他 {
alias clr clear
alias bl bili
alias scpy scrcpy
alias sshcode codessh
alias comd diary-commit
alias mynote 'code ~/pjs/mynote'
alias splay sound-play
alias sp sound-play
# }
