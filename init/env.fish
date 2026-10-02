# 通用环境变量与基础 PATH, 不调用任何外部命令.

set -gx NO_PROXY "127.0.0.1,.local,localhost,.tsinghua.edu.cn,.acodev.top,.wakatime.com"
set -gx UV_DEFAULT_INDEX "https://pypi.tuna.tsinghua.edu.cn/simple"
# set -gx UV_LINK_MODE symlink # 使用软链接时, 清理 uv 缓存可能破坏项目环境.
set -gx FISH_DOTENV_FILE "$__fish_config_dir/.env.fish"

# 越晚加入的路径优先级越高, fish_add_path 会自动跳过不存在的目录.
fish_add_path --path -p -m "$HOME/.local/bin"
fish_add_path --path -p -m "$HOME/scripts"
