function load_dotenv --description 'load .env.fish of current dir, or the given file'
    set -l env_file .env.fish
    if test (count $argv) -ge 1
        set env_file $argv[1]
    end
    if not test -f "$env_file"
        return 0
    end

    # 先在隔离的子 shell 中试运行, 保证要么全部生效, 要么完全不生效.
    if not fish --private --no-config --command="source $(string escape -- $env_file)"
        echo "dotenv: Error sourcing '$env_file' file, bailing." >&2
        return 1
    end

    echo "dotenv: Sourcing '$env_file'" >&2
    source $env_file
end
