# AI 自动生成补全
# 目标工具版本: custom fish function, 2026-07-06
# 参考来源: codessh --help, fish 4.6.0 complete --help

function __fish_codessh_seen_double_dash
    set -l tokens (commandline -opc)
    contains -- -- $tokens[2..-1]
end

function __fish_codessh_current_is_option_value
    set -l current (commandline -ct)
    switch "$current"
        case '--code=*' '--mode=*'
            return 0
    end

    set -l tokens (commandline -opc)
    set -l previous "$tokens[-1]"
    switch "$previous"
        case --code --mode
            return 0
    end

    return 1
end

function __fish_codessh_completed_positionals
    set -l tokens (commandline -opc)
    set -e tokens[1]

    set -l skip_next 0
    set -l options_done 0
    set -l positionals

    for token in $tokens
        if test "$skip_next" = 1
            set skip_next 0
            continue
        end

        if test "$options_done" = 0
            switch "$token"
                case --
                    set options_done 1
                    continue
                case --code --mode
                    set skip_next 1
                    continue
                case '--code=*' '--mode=*'
                    continue
                case -h -n -r --help --new-window --reuse-window --dry-run
                    continue
                case '-*'
                    continue
            end
        end

        set -a positionals "$token"
    end

    if set -q positionals[1]
        printf '%s\n' $positionals
    end
end

function __fish_codessh_positional_count
    set -l positionals (__fish_codessh_completed_positionals)
    count $positionals
end

function __fish_codessh_option_context
    __fish_codessh_current_is_option_value; and return 0

    if not __fish_codessh_seen_double_dash
        set -l current (commandline -ct)
        string match -q -- '-*' "$current"; and return 0
    end

    return 1
end

function __fish_codessh_needs_host
    __fish_codessh_option_context; and return 1
    test (__fish_codessh_positional_count) -eq 0
end

function __fish_codessh_needs_remote_path
    __fish_codessh_option_context; and return 1
    test (__fish_codessh_positional_count) -eq 1
end

function __fish_codessh_emit_host -a host description
    test -n "$host"; or return 0
    printf '%s\t%s\n' "$host" "$description"
end

function __fish_codessh_complete_hosts
    set -l seen

    for host in $codessh_hosts
        contains -- "$host" $seen; and continue
        set -a seen "$host"
        __fish_codessh_emit_host "$host" 'codessh host'
    end

    if set -q CODESSH_HOSTS
        set -l env_hosts (string replace -ar '[,\t\n]+' ' ' -- "$CODESSH_HOSTS")
        for host in (string split -n -- ' ' "$env_hosts")
            contains -- "$host" $seen; and continue
            set -a seen "$host"
            __fish_codessh_emit_host "$host" 'CODESSH_HOSTS'
        end
    end

    if functions -q __fish_complete_user_at_hosts
        for host in (__fish_complete_user_at_hosts)
            set host (string split \t -- "$host")[1]
            contains -- "$host" $seen; and continue
            set -a seen "$host"
            __fish_codessh_emit_host "$host" 'SSH host'
        end
    end
end

function __fish_codessh_remote_host
    set -l positionals (__fish_codessh_completed_positionals)
    test (count $positionals) -ge 1; and printf '%s\n' "$positionals[1]"
end

function __fish_codessh_complete_remote_paths
    set -l host (__fish_codessh_remote_host)
    test -n "$host"; or return 0

    set -l current (commandline -ct)
    codessh --__complete-remote-paths "$host" "$current"
end

function __fish_codessh_modes
    printf '%s\t%s\n' auto 'Auto select launch form'
    printf '%s\t%s\n' remote 'Use documented --remote form'
    printf '%s\t%s\n' uri 'Use raw VS Code URI arguments'
end

function __fish_codessh_code_commands
    printf '%s\t%s\n' code 'VS Code CLI'
    printf '%s\t%s\n' code-insiders 'VS Code Insiders CLI'
end

complete -c codessh -e

complete -c codessh -f -n 'not __fish_codessh_seen_double_dash' -o h -l help -d '显示帮助'
complete -c codessh -f -n 'not __fish_codessh_seen_double_dash' -o n -l new-window -d '打开新窗口'
complete -c codessh -f -n 'not __fish_codessh_seen_double_dash' -o r -l reuse-window -d '复用活动窗口'
complete -c codessh -f -n 'not __fish_codessh_seen_double_dash' -l dry-run -d '只打印命令'
complete -c codessh -f -n 'not __fish_codessh_seen_double_dash' -l mode -x -a '(__fish_codessh_modes)' -d '启动模式'
complete -c codessh -f -n 'not __fish_codessh_seen_double_dash' -l code -x -a '(__fish_codessh_code_commands)' -d 'VS Code 命令'

complete -c codessh -f -n '__fish_codessh_needs_host' -a '(__fish_codessh_complete_hosts)' -d 'SSH host'
complete -c codessh -f -n '__fish_codessh_needs_remote_path' -a '(__fish_codessh_complete_remote_paths)' -d '远端目录'
