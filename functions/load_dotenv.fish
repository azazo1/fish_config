function load_dotenv --description "load .env file of current dir"
    set -l env_file ".env.fish"
    if test (count $argv) -ge 1
        set env_file $argv[1]
    end
    # First shell out to source the file in an isolated fashion. This is to
    # ensure "atomicity" where either all settings as sourced or none at all.
    if ! fish --private --no-config --command="source $env_file"
        echo "dotenv: Error sourcing '$env_file' file, bailing." >&2
        return 1
    end

    echo "dotenv: Sourcing '$env_file'" >&2
    source $env_file
end
