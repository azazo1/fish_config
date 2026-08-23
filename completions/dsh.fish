# AI 自动生成补全
# 目标工具版本: 0.1.1-rc.2
# 参考来源:
# - https://github.com/deepseek-ai/deepseek-harness/blob/master/apps/cli/src/args.ts
# - https://github.com/deepseek-ai/deepseek-harness/blob/master/apps/cli/reference/README.md
# 覆盖 launcher 选项, web 应用参数和常用 pnpm 动词. 未列出的 pnpm 参数保持透传.

# Return installed profile directory names without reading profile contents.
function __dsh_profiles
    set -l dsh_home $DSH_HOME
    if test -z "$dsh_home"
        set dsh_home ~/.dsh
    end
    for profile_dir in "$dsh_home"/profiles/*
        if test -d "$profile_dir"; and test (basename "$profile_dir") != node_modules
            basename "$profile_dir"
        end
    end
end

# Return direct package names for the profile selected by --profile.
function __dsh_plugin_packages
    set -l words (commandline -opc)
    set -l profile
    set -l profile_next 0
    for word in $words
        if test $profile_next = 1
            set profile $word
            set profile_next 0
        else if test "$word" = --profile
            set profile_next 1
        else if string match -q -- '--profile=*' "$word"
            set profile (string split -m 1 = "$word")[2]
        end
    end
    if test -z "$profile"
        return
    end

    set -l dsh_home $DSH_HOME
    if test -z "$dsh_home"
        set dsh_home ~/.dsh
    end
    set -l profile_dir "$dsh_home/profiles/$profile"
    if not test -d "$profile_dir"
        return
    end

    node -e '
        const fs = require("fs")
        try {
            const packageJson = JSON.parse(fs.readFileSync(process.argv[1], "utf8"))
            const names = new Set()
            for (const name of Object.keys(packageJson.dependencies || {})) names.add(name)
            process.stdout.write([...names].sort().join("\\n"))
        } catch {}
    ' "$profile_dir/package.json"
end

# Launcher options for the default profile mode.
complete -c dsh -f -n '__fish_use_subcommand; and not __fish_seen_argument --' -s V -l version -d '输出版本并退出'
complete -c dsh -f -n '__fish_use_subcommand; and not __fish_seen_argument --' -l profile -r -a '(__dsh_profiles)' -d '选择要启动的 profile'
complete -c dsh -n '__fish_use_subcommand; and not __fish_seen_argument --' -l patch -r -F -d '追加 patch-list overlay, 可重复'
complete -c dsh -f -n '__fish_use_subcommand; and not __fish_seen_argument --' -l dump-config -d '输出组合后的 profile 树并退出'
complete -c dsh -f -n '__fish_use_subcommand; and not __fish_seen_argument --' -l dump-default-config -d '只输出 bundle 层并退出'
complete -c dsh -f -n '__fish_use_subcommand; and not __fish_seen_argument --' -s h -l help -d '显示 launcher 帮助'

# Top-level commands.
complete -c dsh -f -n '__fish_use_subcommand; and not __fish_seen_argument --' -a web -d '启动 web profile'
complete -c dsh -f -n '__fish_use_subcommand; and not __fish_seen_argument --' -a plugin -d '管理 profile 的插件'

# web launcher options.
complete -c dsh -n '__fish_seen_subcommand_from web; and not __fish_seen_argument --' -l patch -r -F -d '追加 patch-list overlay, 可重复'
complete -c dsh -f -n '__fish_seen_subcommand_from web; and not __fish_seen_argument --' -l dump-config -d '输出 web profile 配置并退出'
complete -c dsh -f -n '__fish_seen_subcommand_from web; and not __fish_seen_argument --' -l dump-default-config -d '只输出 web bundle 层并退出'

# Web app arguments. Values are intentionally not completed as files.
complete -c dsh -f -n '__fish_seen_subcommand_from web; and not __fish_seen_argument --' -l host -x -d '绑定地址, 当前不支持 0.0.0.0'
complete -c dsh -f -n '__fish_seen_subcommand_from web; and not __fish_seen_argument --' -l port -x -d '监听端口'
complete -c dsh -f -n '__fish_seen_subcommand_from web; and not __fish_seen_argument --' -l trusted-host -x -d '添加受信任的 host, 可重复'
complete -c dsh -f -n '__fish_seen_subcommand_from web; and not __fish_seen_argument --' -l no-open -d '不自动打开默认浏览器'
complete -c dsh -f -n '__fish_seen_subcommand_from web; and not __fish_seen_argument --' -s h -l help -d '显示 web 应用帮助'

# plugin launcher option.
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -l profile -r -a '(__dsh_profiles)' -d '指定要管理的 profile'
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -s h -l help -d '显示 plugin 帮助'

# Common pnpm verbs forwarded by dsh plugin.
set -l dsh_pnpm_commands add install i remove rm un uninstall update up why list ls la ll run exec dlx create link unlink rebuild outdated audit pack publish prune root bin init config store recursive help
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from add install i remove rm un uninstall update up why list ls la ll run exec dlx create link unlink rebuild outdated audit pack publish prune root bin init config store recursive help; and not __fish_seen_argument --' -a "$dsh_pnpm_commands"
complete -c dsh -f -n '__fish_seen_subcommand_from remove rm un uninstall; and not __fish_seen_argument --' -a '(__dsh_plugin_packages)' -d '已安装的 profile 依赖'

# Common pnpm options after a forwarded command. Keep them lightweight because
# the exact option set depends on the selected pnpm subcommand.
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -s h -l help -d '显示 pnpm 帮助'
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -l dir -r -a '(__fish_complete_directories)' -d '切换项目目录'
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -l recursive -d '递归处理 workspace'
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -l global -d '使用全局安装目录'
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -l offline -d '只使用本地缓存'
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -l ignore-scripts -d '跳过生命周期脚本'
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -l filter -r -d '限制 workspace 包范围'
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -l registry -r -d '指定 registry URL'
complete -c dsh -f -n '__fish_seen_subcommand_from plugin; and not __fish_seen_argument --' -l reporter -x -a 'append-only default ndjson silent' -d '设置 pnpm 输出格式'
