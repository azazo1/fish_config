function setproxyp --description 'set HTTP(S)_PROXY with http scheme: setproxyp [host:port]'
    set -l proxy_base localhost:7890
    if test (count $argv) -ge 1
        set proxy_base $argv[1]
    end
    set -gx HTTPS_PROXY http://$proxy_base
    set -gx HTTP_PROXY http://$proxy_base
    echo "Proxy on http://$proxy_base set" >&2
end
