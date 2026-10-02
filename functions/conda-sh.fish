function conda-sh --description 'enter conda shell (sub shell)'
    __require_cmds conda-sh conda; or return

    set -l suffix_command 'echo ""'
    if test (count $argv) -ge 1
        set suffix_command 'conda activate '$argv[1]
    end
    command fish -C 'eval "$(conda "shell.$(basename "$SHELL")" hook); echo \'Conda shell created.\'; '$suffix_command'"'
end
