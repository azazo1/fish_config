function tinypw --description 'tinypw without the header line'
    __require_cmds tinypw tinypw; or return
    command tinypw $argv -c | tail -n +2
end
