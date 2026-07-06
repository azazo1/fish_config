function __codessh_usage
    printf '%s\n' \
        'codessh - open VS Code Remote SSH from the terminal' \
        '' \
        'Usage:' \
        '  codessh [options] [host] [remote-folder]' \
        '' \
        'Examples:' \
        '  codessh win' \
        '  codessh win D:/pjs/fpga/zynq/pwm_led' \
        '  codessh --dry-run win D:/pjs/fpga/zynq/pwm_led' \
        '  codessh --mode uri win D:/pjs/fpga/zynq/pwm_led' \
        '' \
        'Options:' \
        '  -n, --new-window       Open in a new VS Code window.' \
        '  -r, --reuse-window     Reuse the last active VS Code window.' \
        '      --code <command>   Use another VS Code command, for example code-insiders.' \
        '      --mode <mode>      auto, remote, or uri. Default: auto.' \
        '      --dry-run          Print the command without launching VS Code.' \
        '  -h, --help             Show this help.' \
        '' \
        'Notes:' \
        '  auto uses the documented CLI form only when code --help lists --remote:' \
        '    code --remote ssh-remote+HOST [REMOTE_FOLDER]' \
        '' \
        '  Otherwise auto uses the raw --remote switch for an empty SSH window:' \
        '    code --new-window -- --remote ssh-remote+HOST' \
        '' \
        '  Remote folders use the raw editor argument form:' \
        '    code -- --folder-uri vscode-remote://ssh-remote+HOST/REMOTE_FOLDER' \
        '' \
        '  When no remote folder is provided, codessh opens an empty Remote SSH window.'
end

function __codessh_die
    printf 'codessh: %s\n' "$argv" >&2
    return 2
end

function __codessh_print_cmd
    string escape -- $argv | string join ' '
    printf '\n'
end

function __codessh_prompt_value -a label
    if not isatty stdin
        return 1
    end

    read -l -P "$label" value
    printf '%s' "$value"
end

function __codessh_escape_uri_path -a path
    set -l escaped "$path"
    set escaped (string replace -a '%' '%25' -- "$escaped")
    set escaped (string replace -a ' ' '%20' -- "$escaped")
    set escaped (string replace -a '#' '%23' -- "$escaped")
    set escaped (string replace -a '?' '%3F' -- "$escaped")
    printf '%s' "$escaped"
end

function __codessh_folder_uri_for -a authority path
    set -l escaped (__codessh_escape_uri_path "$path")

    if string match -q '/*' -- "$escaped"
        printf 'vscode-remote://%s%s' "$authority" "$escaped"
    else
        printf 'vscode-remote://%s/%s' "$authority" "$escaped"
    end
end

function codessh --description 'Open VS Code Remote SSH from fish'
    set -l code_bin code
    set -l mode auto
    set -l dry_run 0
    set -l window_args

    if set -q CODE_BIN
        set code_bin "$CODE_BIN"
    end

    if set -q CODESSH_MODE
        set mode "$CODESSH_MODE"
    end

    while test (count $argv) -gt 0
        switch $argv[1]
            case -h --help
                __codessh_usage
                return 0
            case -n --new-window
                set -a window_args --new-window
                set -e argv[1]
            case -r --reuse-window
                set -a window_args --reuse-window
                set -e argv[1]
            case --code
                set -e argv[1]
                if test (count $argv) -eq 0
                    __codessh_die '--code requires a command'
                    return 2
                end
                set code_bin "$argv[1]"
                set -e argv[1]
            case --mode
                set -e argv[1]
                if test (count $argv) -eq 0
                    __codessh_die '--mode requires auto, remote, or uri'
                    return 2
                end
                set mode "$argv[1]"
                switch "$mode"
                    case auto remote uri
                    case '*'
                        __codessh_die '--mode must be auto, remote, or uri'
                        return 2
                end
                set -e argv[1]
            case --dry-run
                set dry_run 1
                set -e argv[1]
            case --
                set -e argv[1]
                break
            case '-*'
                __codessh_die "unknown option: $argv[1]"
                return 2
            case '*'
                break
        end
    end

    set -l positional $argv
    set -l host ''
    set -l remote_path ''

    switch (count $positional)
        case 0
        case 1
            set host "$positional[1]"
        case 2
            set host "$positional[1]"
            set remote_path "$positional[2]"
        case '*'
            __codessh_die 'expected at most two positional arguments: host and remote-folder'
            return 2
    end

    if test -z "$host"
        set host (__codessh_prompt_value 'SSH host: ')
        or begin
            __codessh_die 'missing SSH host'
            return 2
        end

        if test -z "$host"
            __codessh_die 'missing SSH host'
            return 2
        end

        set remote_path (__codessh_prompt_value 'Remote folder, leave blank for empty window: ')
        or set remote_path ''
    end

    set -l authority "ssh-remote+$host"
    set -l effective_window_args $window_args

    if test -z "$remote_path"; and test (count $effective_window_args) -eq 0
        set effective_window_args --new-window
    end

    set -l remote_cmd "$code_bin" $effective_window_args --remote "$authority"

    if test -n "$remote_path"
        set -a remote_cmd "$remote_path"
    end

    set -l uri_cmd

    if test -n "$remote_path"
        set uri_cmd "$code_bin" $effective_window_args -- --folder-uri (__codessh_folder_uri_for "$authority" "$remote_path")
    else
        set uri_cmd "$code_bin" $effective_window_args -- --remote "$authority"
    end

    set -l supports_remote_option 0
    if command "$code_bin" --help 2>/dev/null | string match -q '*--remote*'
        set supports_remote_option 1
    end

    switch "$mode"
        case remote
            if test "$dry_run" = 1
                __codessh_print_cmd $remote_cmd
            else
                command $remote_cmd
            end
        case uri
            if test "$dry_run" = 1
                __codessh_print_cmd $uri_cmd
            else
                command $uri_cmd
            end
        case auto
            if test "$dry_run" = 1
                if test "$supports_remote_option" = 1
                    __codessh_print_cmd $remote_cmd
                    printf '%s\n' 'codessh: fallback if the first command fails:' >&2
                    __codessh_print_cmd $uri_cmd
                else
                    __codessh_print_cmd $uri_cmd
                end
                return 0
            end

            if test "$supports_remote_option" = 0
                command $uri_cmd
                return $status
            end

            command $remote_cmd
            set -l first_status $status
            if test "$first_status" = 0
                return 0
            end

            printf 'codessh: documented --remote form failed with status %s, retrying URI/raw editor argument form\n' "$first_status" >&2
            command $uri_cmd
            return $status
    end
end
