# 键位绑定, ctrl-x 这种按键写法需要 fish 4.0 及以上.

set -l fish_major (string match -r '^\d+' -- $version)
if test -n "$fish_major"; and test "$fish_major" -ge 4
    fish_hybrid_key_bindings

    # 删除预设的 ctrl-p, ctrl-n, ctrl-l 绑定.
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
end
