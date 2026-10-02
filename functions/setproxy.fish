function setproxy --description 'set HTTP(S)_PROXY without scheme: setproxy [host:port]'
    set -l proxy_base localhost:7890
    if test (count $argv) -ge 1
        set proxy_base $argv[1]
    end
    set -gx HTTPS_PROXY $proxy_base
    set -gx HTTP_PROXY $proxy_base
    echo "Proxy on $proxy_base set" >&2
end
