# AI 自动生成补全
# 目标工具版本: dsh 0.1.7-rc.1 (本机 bun 全局安装, Node 26)
# 参考来源:
# - https://github.com/deepseek-ai/deepseek-harness/blob/dsh-v0.1.7-rc.1/apps/cli/src/args.ts
# - https://github.com/deepseek-ai/deepseek-harness/blob/dsh-v0.1.7-rc.1/apps/cli/src/profile-boot.ts
# - https://github.com/deepseek-ai/deepseek-harness/blob/dsh-v0.1.7-rc.1/packages/boot/app-boot/src/profile.ts
# - https://github.com/deepseek-ai/deepseek-harness/blob/dsh-v0.1.7-rc.1/packages/bundle/web-app/src/startup.ts
# - https://github.com/deepseek-ai/deepseek-harness/blob/dsh-v0.1.7-rc.1/packages/bundle/headless/src/startup.ts
# - 本机 dsh --help 与本机 pnpm 12.3.4 的 pnpm --help
#
# 覆盖范围: launcher 选项, profile 名, --from-default-profile 的模板名,
# shipped 应用 (web, headless, acp, sdk, sdk-minimal) 的参数, 以及 dsh plugin 转发的 pnpm 常用子命令.
# 限制:
# - 非 shipped profile (例如 tui) 的应用参数由 profile 内的插件自行解析, 无法静态建模,
#   这类 profile 只补 -h/--help, 其余参数交给 fish 的默认行为.
# - dsh plugin 之后是原样转发给 pnpm 的参数, 这里只补常用子命令和常用通用选项,
#   不覆盖 pnpm 的全部子命令, 选项以及选项取值.

# 打印 Harness home, 与 dsh 的 DSH_HOME 约定一致.
function __dsh_home
    if test -n "$DSH_HOME"
        printf '%s\n' "$DSH_HOME"
    else
        printf '%s\n' ~/.dsh
    end
end

# 打印 shipped profile 模板名及其说明, 供 --profile 与 --from-default-profile 使用.
function __dsh_templates
    printf '%s\t%s\n' web 'shipped 模板: 浏览器 UI'
    printf '%s\t%s\n' headless 'shipped 模板: 一次性任务后退出'
    printf '%s\t%s\n' sdk 'shipped 模板: SDK JSON-RPC stdio'
    printf '%s\t%s\n' sdk-minimal 'shipped 模板: 最小 SDK 树'
    printf '%s\t%s\n' acp 'shipped 模板: ACP stdio'
end

# 是否已经出现单独的 --, 它之后的 token 一律按位置参数处理.
function __dsh_past_double_dash
    contains -- -- (commandline -opc)
end

# 是否已经给出 launcher 的 dump 选项, 它们不接受应用参数.
function __dsh_dump_flag_seen
    for word in (commandline -opc)
        switch $word
            case --dump-config --dump-config-schema --dump-default-config
                return 0
        end
    end
    return 1
end

# 打印可选 profile: shipped 模板加 $DSH_HOME/profiles 下已存在的目录.
# desktop 由 Electron 应用独占, 会被 launcher 拒绝, 因此不作为候选.
function __dsh_profiles
    __dsh_templates
    set -l templates web headless sdk sdk-minimal acp
    set -l profiles_dir (__dsh_home)/profiles
    for dir in $profiles_dir/*
        test -d $dir
        or continue
        set -l name (basename $dir)
        if contains -- $name $templates
            continue
        end
        if contains -- $name node_modules desktop
            continue
        end
        printf '%s\t%s\n' $name '已安装的 profile'
    end
end

# 打印当前命令行将要启动的 profile 名; 尚未决定时不输出.
function __dsh_profile
    set -l words (commandline -opc)
    set -e words[1]
    set -l index 1
    set -l positional_seen 0
    while test $index -le (count $words)
        set -l word $words[$index]
        switch $word
            case --profile
                set index (math $index + 1)
                if test $index -le (count $words)
                    printf '%s\n' $words[$index]
                end
                return 0
            case '--profile=*'
                printf '%s\n' (string replace -- '--profile=' '' $word)
                return 0
            case --from-default-profile --patch
                set index (math $index + 1)
            case '--from-default-profile=*' '--patch=*'
            case --dump-config --dump-config-schema --dump-default-config -V --version -h --help
            case --
                # -- 之后 launcher 不再解析选项, 也不会再出现 profile.
                return 1
            case '-*'
                return 1
            case plugin
                if test $positional_seen = 0
                    set positional_seen 1
                end
            case '*'
                if test $positional_seen = 0
                    printf '%s\n' $word
                end
                return 0
        end
        set index (math $index + 1)
    end
    return 1
end

# 当前命令行是否走 dsh plugin, 即首个位置参数为 plugin.
function __dsh_is_plugin
    set -l words (commandline -opc)
    test (count $words) -ge 2
    and test "$words[2]" = plugin
end

# 是否已经给出 --profile.
function __dsh_profile_flag_seen
    for word in (commandline -opc)
        if string match -q -- '--profile' $word
            return 0
        end
        if string match -q -- '--profile=*' $word
            return 0
        end
    end
    return 1
end

# 当前光标处是否在补 --profile 的值.
function __dsh_awaiting_profile
    set -l words (commandline -opc)
    if test (count $words) -lt 2
        return 1
    end
    test "$words[-1]" = --profile
end

# --profile 既可以在尚未给出时补其名字, 也可以在补它的值时列候选.
function __dsh_may_profile_flag
    if __dsh_awaiting_profile
        return 0
    end
    not __dsh_profile_flag_seen
end

# 当前光标处是否在补一个需要取值的 launcher 选项的值.
function __dsh_awaiting_value
    set -l words (commandline -opc)
    if test (count $words) -lt 2
        return 1
    end
    switch $words[-1]
        case --profile --from-default-profile --patch
            return 0
    end
    return 1
end

# launcher 只解析自己的选项, 遇到第一个不属于它的 token 就把余下参数交给应用.
# 这里判断应用参数是否已经开始.
function __dsh_app_started
    set -l words (commandline -opc)
    set -e words[1]
    set -l index 1
    set -l profile_decided 0
    while test $index -le (count $words)
        set -l word $words[$index]
        switch $word
            case --profile
                set profile_decided 1
                set index (math $index + 1)
            case '--profile=*'
                set profile_decided 1
            case --from-default-profile --patch
                set index (math $index + 1)
            case '--from-default-profile=*' '--patch=*'
            case --dump-config --dump-config-schema --dump-default-config -V --version
            case --
                if test $index -lt (count $words)
                    return 0
                end
            case '-*'
                if test $profile_decided = 1
                    return 0
                end
            case '*'
                if test $profile_decided = 1
                    return 0
                end
                set profile_decided 1
        end
        set index (math $index + 1)
    end
    return 1
end

# plugin 模式下是否已经给出 pnpm 子命令.
function __dsh_pnpm_verb_seen
    set -l words (commandline -opc)
    set -e words[1..2]
    set -l index 1
    while test $index -le (count $words)
        set -l word $words[$index]
        switch $word
            case --profile
                set index (math $index + 1)
            case '--profile=*'
            case '-*'
            case '*'
                return 0
        end
        set index (math $index + 1)
    end
    return 1
end

# 打印选中 profile 的 package.json 依赖名, 供 remove 类子命令使用. 只读取依赖名, 不读其他内容.
function __dsh_plugin_packages
    set -l profile (__dsh_profile)
    if test -z "$profile"
        return 1
    end
    set -l manifest (__dsh_home)/profiles/$profile/package.json
    if not test -f $manifest
        return 1
    end
    if not type -q node
        return 1
    end
    node -e '
        const fs = require("fs")
        try {
            const manifest = JSON.parse(fs.readFileSync(process.argv[1], "utf8"))
            const names = new Set()
            for (const field of ["dependencies", "devDependencies"]) {
                for (const name of Object.keys(manifest[field] || {})) names.add(name)
            }
            process.stdout.write([...names].sort().join("\n"))
        } catch {}
    ' $manifest
end

# 当前命令行将要启动的 profile 是否为给定名字.
function __dsh_in_profile
    set -l profile (__dsh_profile)
    test -n "$profile"
    and test "$profile" = "$argv[1]"
end

# 当前 profile 是否属于没有自有选项的 acp 与 sdk 类.
function __dsh_profile_is_bare
    set -l profile (__dsh_profile)
    contains -- "$profile" acp sdk sdk-minimal
end

# 当前 profile 是否是 shipped 模板之外的自定义 profile.
function __dsh_profile_is_custom
    set -l profile (__dsh_profile)
    test -n "$profile"
    and not contains -- $profile web headless acp sdk sdk-minimal
end

# 是否已经确定要启动的 profile.
function __dsh_profile_decided
    set -l profile (__dsh_profile)
    test -n "$profile"
end

# --profile 可用的上下文: launcher 层还没把参数交给应用, 或者处于 dsh plugin 模式.
function __dsh_profile_flag_context
    if __dsh_past_double_dash
        return 1
    end
    if __dsh_is_plugin
        return 0
    end
    not __dsh_app_started
end

set -l launcher_base 'not __dsh_app_started; and not __dsh_is_plugin'
set -l launcher_cond "$launcher_base; and not __dsh_past_double_dash"
set -l plugin_cond '__dsh_is_plugin; and not __dsh_past_double_dash'
set -l plain_cond '__fish_use_subcommand; and not __dsh_awaiting_value'

# launcher 选项.
complete -c dsh -f -n "$launcher_cond" -s V -l version -d '输出版本号并退出'
complete -c dsh -f -n "__dsh_may_profile_flag; and __dsh_profile_flag_context" -l profile -r -a '(__dsh_profiles)' -d '启动该 profile, dsh plugin 模式下指定要管理的 profile'
complete -c dsh -f -n "$launcher_cond" -l from-default-profile -r -a '(__dsh_templates)' -d '用 shipped 模板初始化一个新 profile'
complete -c dsh -n "$launcher_cond" -l patch -r -F -d '在 profile 层之后追加 patch 覆盖层, 可重复'
complete -c dsh -f -n "$launcher_cond" -l dump-config -d '打印合成后的 profile 树并退出'
complete -c dsh -f -n "$launcher_cond" -l dump-config-schema -d '打印 profile 配置和 patch 的 JSON Schema 并退出'
complete -c dsh -f -n "$launcher_cond" -l dump-default-config -d '只打印 bundle 层, 不含用户层与 --patch, 然后退出'
complete -c dsh -f -n "$plain_cond; and not __dsh_is_plugin" -s h -l help -d '显示 launcher 帮助, 有 profile 时 -h 交给应用'
# launcher 层没有文件位置参数, 唯一的顶层位置参数是 profile 名或 plugin.
# profile 一旦确定, 位置参数的补全交给该 profile 的规则, 自定义 profile 保持 fish 的默认文件补全.
complete -c dsh -f -n "$launcher_base; and not __dsh_profile_decided"

# 顶层位置参数: profile 名与 plugin 子命令.
complete -c dsh -f -n "$plain_cond; and not __dsh_profile_flag_seen; and not __dsh_is_plugin; and not __dsh_dump_flag_seen; and not __dsh_past_double_dash" -a '(__dsh_profiles)'
complete -c dsh -f -n "$plain_cond; and not __dsh_profile_flag_seen; and not __dsh_dump_flag_seen; and not __dsh_past_double_dash" -a plugin -d '管理 profile 的插件, 余下参数转发给 pnpm'

# dsh plugin 转发的 pnpm 子命令.

set -l pnpm_verbs \
    add install i install-test it update up upgrade \
    remove rm un uni uninstall why list ls ll la \
    outdated audit run exec dlx create rebuild rb \
    prune link ln unlink dislink import dedupe fetch \
    pack publish patch patch-commit patch-remove licenses \
    sbom config c root bin store setup doctor clean \
    purge ci ic clean-install deploy view info show v \
    search s se find whoami ping ignored-builds \
    approve-builds help
complete -c dsh -f -n '__dsh_is_plugin; and not __dsh_pnpm_verb_seen; and not __dsh_awaiting_value' -a "$pnpm_verbs" -d 'pnpm 子命令'
complete -c dsh -f -n '__dsh_is_plugin; and __fish_seen_subcommand_from remove rm un uni uninstall' -a '(__dsh_plugin_packages)' -d '该 profile 的已安装依赖'

# dsh plugin 之后是原样转发给 pnpm 的参数, 这里补 pnpm 的通用 rc 选项和常用子命令选项,
# 其余子命令, 选项和取值由 pnpm 自己解析. 说明里标注该选项在哪些子命令上有效.
complete -c dsh -f -n "$plugin_cond" -s C -l dir -r -a '(__fish_complete_directories)' -d 'pnpm: 切换工作目录'
complete -c dsh -f -n "$plugin_cond" -s r -l recursive -d 'pnpm: 对 workspace 内所有项目生效'
complete -c dsh -f -n "$plugin_cond" -s w -l workspace-root -d 'pnpm: 只作用于 workspace 根项目'
complete -c dsh -f -n "$plugin_cond" -s F -l filter -r -d 'pnpm: 筛选 workspace 项目, 可重复'
complete -c dsh -f -n "$plugin_cond" -l filter-prod -r -d 'pnpm: 同 --filter, 但只跟随生产依赖'
complete -c dsh -f -n "$plugin_cond" -l registry -r -d 'pnpm: 指定 registry URL'
complete -c dsh -f -n "$plugin_cond" -l reporter -r -a 'default append-only ndjson silent' -d 'pnpm: 输出格式'
complete -c dsh -f -n "$plugin_cond" -l loglevel -r -a 'silent error warn info debug' -d 'pnpm: 日志等级'
complete -c dsh -f -n "$plugin_cond" -s P -l prod -d 'pnpm install, update: 只处理 production 依赖'
complete -c dsh -f -n "$plugin_cond" -s D -l dev -d 'pnpm install, update: 只处理 devDependencies'
complete -c dsh -f -n "$plugin_cond" -l save-prod -d 'pnpm add, remove: 记为 production 依赖'
complete -c dsh -f -n "$plugin_cond" -l save-dev -d 'pnpm add, remove: 记为 devDependencies'
complete -c dsh -f -n "$plugin_cond" -s O -l save-optional -d 'pnpm add, remove: 记为 optionalDependencies'
complete -c dsh -f -n "$plugin_cond" -s E -l save-exact -d 'pnpm add, update: 写入精确版本'
complete -c dsh -f -n "$plugin_cond" -l save-peer -d 'pnpm add: 记为 peerDependencies'
complete -c dsh -f -n "$plugin_cond" -l no-save-peer -d 'pnpm add: 不记为 peerDependencies'
complete -c dsh -f -n "$plugin_cond" -l no-save -d 'pnpm update: 不写入 package.json'
complete -c dsh -f -n "$plugin_cond" -l optional -d 'pnpm install, add, update: 包含 optionalDependencies'
complete -c dsh -f -n "$plugin_cond" -l no-optional -d 'pnpm install: 不装 optionalDependencies'
complete -c dsh -f -n "$plugin_cond" -l frozen-lockfile -d 'pnpm install, ci: 不更新 lockfile'
complete -c dsh -f -n "$plugin_cond" -l lockfile-only -d 'pnpm install, add, update, remove: 只更新 lockfile'
complete -c dsh -f -n "$plugin_cond" -l force -d 'pnpm install, add: 强制重新安装'
complete -c dsh -f -n "$plugin_cond" -l ignore-scripts -d 'pnpm install, add, update: 跳过生命周期脚本'
complete -c dsh -f -n "$plugin_cond" -l offline -d 'pnpm install: 只用本地 store, 缺包即失败'
complete -c dsh -f -n "$plugin_cond" -l prefer-offline -d 'pnpm install: 优先使用本地缓存'
complete -c dsh -f -n "$plugin_cond" -l dry-run -d 'pnpm install: 只显示将要发生的变更'
complete -c dsh -f -n "$plugin_cond" -s h -l help -d 'pnpm: 显示 pnpm 帮助'

# web profile 的应用参数, 它不接受位置参数.
set -l web_base 'not __dsh_is_plugin; and not __dsh_dump_flag_seen; and __dsh_in_profile web'
set -l web_cond "$web_base; and not __dsh_past_double_dash"
complete -c dsh -f -n "$web_base"
complete -c dsh -f -n "$web_cond" -l host -r -d '绑定地址, 当前不支持 0.0.0.0'
complete -c dsh -f -n "$web_cond" -l port -r -d '监听端口, 0 表示由系统分配'
complete -c dsh -f -n "$web_cond" -l trusted-host -r -d '额外受信任的 authority, 可重复或连续给出'
complete -c dsh -f -n "$web_cond" -l no-open -d '不自动打开默认浏览器'
complete -c dsh -f -n "$web_cond" -s h -l help -d '显示 web 应用帮助'

# headless profile 的应用参数, 位置参数是任务文本.
set -l headless_base 'not __dsh_is_plugin; and not __dsh_dump_flag_seen; and __dsh_in_profile headless'
set -l headless_cond "$headless_base; and not __dsh_past_double_dash"
complete -c dsh -f -n "$headless_base"
complete -c dsh -f -n "$headless_cond" -l json -d '向 stdout 输出逐行 JSON 运行事件'
complete -c dsh -f -n "$headless_cond" -l session-id -r -d '接管指定 id 的已持久化 Session'
complete -c dsh -f -n "$headless_cond" -s h -l help -d '显示 headless 应用帮助'

# acp 与 sdk 类 profile 没有自己的选项, 也不接受位置参数.
set -l bare_base 'not __dsh_is_plugin; and not __dsh_dump_flag_seen; and __dsh_profile_is_bare'
set -l bare_cond "$bare_base; and not __dsh_past_double_dash"
complete -c dsh -f -n "$bare_base"
complete -c dsh -f -n "$bare_cond" -s h -l help -d '显示应用帮助'

# 其他自定义 profile 的应用参数无法静态建模, 只补通用的 -h/--help.
set -l custom_cond 'not __dsh_is_plugin; and not __dsh_past_double_dash; and not __dsh_dump_flag_seen; and __dsh_profile_is_custom'
complete -c dsh -n "$custom_cond" -s h -l help -d '应用帮助, 具体参数取决于该 profile 的插件'
