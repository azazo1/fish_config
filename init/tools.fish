# 依赖完整 PATH 的工具配置, 每一项都先确认工具存在.

# Go {
if command -q go
    fish_add_path --path -p -m (go env GOPATH)/bin
end
# }

# bun {
if test -d "$HOME/.bun"
    set -gx BUN_INSTALL "$HOME/.bun"
    fish_add_path --path -p -m $BUN_INSTALL/bin
end
# }

# sccache 未安装时设置 RUSTC_WRAPPER 会导致 cargo 无法编译.
if command -q sccache
    set -gx RUSTC_WRAPPER sccache
end

if command -q nvim
    set -gx EDITOR nvim
end
