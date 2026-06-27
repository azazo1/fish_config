# AI 自动生成补全
# 目标工具版本: sqlite3 3.43.2 2023-10-10 13:08:14 1b37c146ee9ebb7acd0160c0ab1fd11017a419fa8a3187386ed8cb32b709aapl
# 目标 shell: fish 4.6.0
# 参考来源: sqlite3 -help, sqlite3 :memory: ".help", sqlite3 :memory: ".help -all", fish complete --help, https://fishshell.com/docs/current/completions.html

function __fish_sqlite3_before_double_dash
    set -l tokens (commandline -pxc)
    contains -- -- $tokens; and return 1
    __fish_seen_argument -o A; and return 1
    return 0
end

function __fish_sqlite3_dot_commands
    printf "%s\t%s\n" \
        ".archive" "Manage SQL archives" \
        ".auth" "Show authorizer callbacks" \
        ".backup" "Backup DB to file" \
        ".bail" "Stop after hitting an error" \
        ".cd" "Change working directory" \
        ".changes" "Show number of rows changed" \
        ".check" "Fail if output does not match glob" \
        ".clone" "Clone data into a new database" \
        ".connection" "Open or close auxiliary connection" \
        ".databases" "List attached databases" \
        ".dbconfig" "List or change db config options" \
        ".dbinfo" "Show database status information" \
        ".dump" "Render database content as SQL" \
        ".echo" "Turn command echo on or off" \
        ".eqp" "Enable or disable query plan output" \
        ".excel" "Display next output in spreadsheet" \
        ".exit" "Exit sqlite3 with status code" \
        ".expert" "Suggest indexes for queries" \
        ".explain" "Change EXPLAIN formatting mode" \
        ".filectrl" "Run sqlite3_file_control operations" \
        ".fullschema" "Show schema and sqlite_stat content" \
        ".headers" "Turn display of headers on or off" \
        ".help" "Show help text" \
        ".hex-rekey" "Change encryption key using hex" \
        ".import" "Import data from file into table" \
        ".indexes" "Show indexes" \
        ".limit" "Display or change SQLITE_LIMIT value" \
        ".lint" "Report potential schema issues" \
        ".log" "Turn logging on or off" \
        ".mode" "Set output mode" \
        ".nonce" "Suspend safe mode for one command" \
        ".nullvalue" "Set text for NULL values" \
        ".once" "Output next command only to file" \
        ".open" "Close and reopen database" \
        ".output" "Send output to file or stdout" \
        ".parameter" "Manage SQL parameter bindings" \
        ".print" "Print literal string" \
        ".progress" "Invoke progress handler" \
        ".prompt" "Replace prompts" \
        ".quit" "Exit sqlite3" \
        ".read" "Read input from file" \
        ".recover" "Recover data from corrupt database" \
        ".rekey" "Change encryption key" \
        ".restore" "Restore database content" \
        ".save" "Write database to file" \
        ".scanstats" "Turn statement scan status metrics on or off" \
        ".schema" "Show CREATE statements" \
        ".separator" "Change column and row separators" \
        ".session" "Create or control sessions" \
        ".sha3sum" "Compute SHA3 hash of database content" \
        ".shell" "Run command in system shell" \
        ".show" "Show current settings" \
        ".stats" "Show or toggle stats" \
        ".system" "Run command in system shell" \
        ".tables" "List tables" \
        ".text-rekey" "Change encryption key using text" \
        ".timeout" "Set busy timeout" \
        ".timer" "Turn SQL timer on or off" \
        ".trace" "Trace SQL statements" \
        ".version" "Show version information" \
        ".vfsinfo" "Show VFS information" \
        ".vfslist" "List VFSes" \
        ".vfsname" "Show VFS stack name" \
        ".width" "Set column widths"
end

function __fish_sqlite3_archive_options
    printf "%s\t%s\n" \
        "-c" "Create a new archive" \
        "--create" "Create a new archive" \
        "-u" "Add or update files with changed mtime" \
        "--update" "Add or update files with changed mtime" \
        "-i" "Insert files even if unchanged" \
        "--insert" "Insert files even if unchanged" \
        "-r" "Remove files from archive" \
        "--remove" "Remove files from archive" \
        "-t" "List archive contents" \
        "--list" "List archive contents" \
        "-x" "Extract files from archive" \
        "--extract" "Extract files from archive" \
        "-v" "Print each filename as processed" \
        "--verbose" "Print each filename as processed" \
        "-f" "Use archive file" \
        "--file" "Use archive file" \
        "-a" "Open file using apndvfs VFS" \
        "--append" "Open file using apndvfs VFS" \
        "-C" "Read or extract files from directory" \
        "--directory" "Read or extract files from directory" \
        "-g" "Use glob matching for names" \
        "--glob" "Use glob matching for names" \
        "-n" "Show SQL without executing" \
        "--dryrun" "Show SQL without executing"
end

complete -c sqlite3 -e

complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o A -r -a '(__fish_sqlite3_archive_options)' -d 'Run .archive ARGS and exit'
complete -c sqlite3 -n '__fish_seen_argument -o A' -a '(__fish_sqlite3_archive_options)' -d 'SQLite archive option'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o append -d 'Append the database to the end of the file'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o ascii -d 'Set output mode to ascii'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o bail -d 'Stop after hitting an error'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o batch -d 'Force batch I/O'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o box -d 'Set output mode to box'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o column -d 'Set output mode to column'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o cmd -x -a '(__fish_sqlite3_dot_commands)' -d 'Run command before reading stdin'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o csv -d 'Set output mode to csv'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o deserialize -d 'Open database using sqlite3_deserialize'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o echo -d 'Print inputs before execution'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o header -d 'Turn headers on'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o noheader -d 'Turn headers off'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o help -d 'Show help'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o hexkey -x -d 'Use hexadecimal encryption key'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o html -d 'Set output mode to HTML'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o init -r -F -d 'Read and process named file'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o interactive -d 'Force interactive I/O'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o json -d 'Set output mode to json'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o key -x -d 'Use raw encryption key'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o line -d 'Set output mode to line'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o list -d 'Set output mode to list'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o lookaside -r -d 'Use N entries of SIZE bytes for lookaside memory'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o markdown -d 'Set output mode to markdown'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o maxsize -x -d 'Maximum size for deserialized database'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o memtrace -d 'Trace memory allocations'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o newline -x -d 'Set output row separator'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o nofollow -d 'Refuse to open symbolic links'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o nonce -x -d 'Set safe-mode escape nonce'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o nullvalue -x -d 'Set text string for NULL values'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o pagecache -r -d 'Use N slots of SIZE bytes for page cache memory'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o pcachetrace -d 'Trace page cache operations'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o quote -d 'Set output mode to quote'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o readonly -d 'Open database read-only'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o safe -d 'Enable safe mode'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o separator -x -d 'Set output column separator'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o stats -d 'Print memory stats before each finalize'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o table -d 'Set output mode to table'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o tabs -d 'Set output mode to tabs'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o textkey -x -d 'Use text to hash into encryption key'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o unsafe-testing -d 'Allow unsafe commands and modes for testing'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o version -d 'Show SQLite version'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o vfs -x -d 'Use NAME as default VFS'
complete -c sqlite3 -n __fish_sqlite3_before_double_dash -o zip -d 'Open file as ZIP archive'

complete -c sqlite3 -a ':memory:' -d 'Open an in-memory database'
