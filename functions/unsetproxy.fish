function unsetproxy --description 'unset HTTP(S)_PROXY'
    set -e HTTPS_PROXY
    set -e HTTP_PROXY
    echo "Proxy unset" >&2
end
