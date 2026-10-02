function launchctl-restart --description "restart a launchd agent, arg is a label like com.example.app[.plist] or its path"
    if test (count $argv) -lt 1
        echo "launchctl-restart: argument required." >&2
        return 1
    end
    __require_cmds launchctl-restart launchctl; or return

    set -l domain (basename (string replace --regex '(.+)\.plist$' '$1' -- $argv[1]))
    echo "launchctl-restart: bootouting $domain..."
    command launchctl bootout gui/(id -u)/$domain
    echo "launchctl-restart: bootstrapping $domain..."
    command launchctl bootstrap gui/(id -u) "$domain.plist"
    sleep 2s
    command launchctl list | head -n 1
    command launchctl list | string match -e -- $domain
end
