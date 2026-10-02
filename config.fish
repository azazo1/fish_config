# fish 配置入口, macos 和 main(linux) 两个分支共用同一份.
#
# 加载顺序:
#   conf.d/*.fish         fish 自动加载, 放第三方工具注入 (rustup, uv, ...)
#   init/env.fish         通用环境变量与基础 PATH
#   init/platform.fish    平台专属配置, 两个分支内容不同
#   init/tools.fish       依赖完整 PATH 的工具配置
#   ---- 以下仅交互式 ----
#   init/interactive.fish starship, zoxide 等初始化
#   init/aliases.fish     通用别名
#   init/key-bindings.fish
#   load_dotenv           最后加载 .env.fish, 本机私有配置可覆盖前面所有设置
#
# 函数放在 functions/ 下按需自动加载, 补全放在 completions/ 下.

set -l init_dir "$__fish_config_dir/init"

source "$init_dir/env.fish"
if test -f "$init_dir/platform.fish"
    source "$init_dir/platform.fish"
end
source "$init_dir/tools.fish"

if status is-interactive
    source "$init_dir/interactive.fish"
    source "$init_dir/aliases.fish"
    source "$init_dir/key-bindings.fish"

    load_dotenv $FISH_DOTENV_FILE
end
