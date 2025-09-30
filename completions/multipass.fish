# Completions for the multipass command (一级子命令及说明)
# Global options
complete -c multipass -s h -l help -d "Show help on commandline options"
complete -c multipass -s v -l verbose -d "Increase logging verbosity (e.g., -vvvv)" -r
# --- Available commands with descriptions ---
# alias         Create an alias
complete -c multipass -n '__fish_use_subcommand' -f -a alias -d "Create an alias"
# aliases       List available aliases
complete -c multipass -n '__fish_use_subcommand' -f -a aliases -d "List available aliases"
# authenticate  Authenticate client
complete -c multipass -n '__fish_use_subcommand' -f -a authenticate -d "Authenticate client"
# clone         Clone an instance
complete -c multipass -n '__fish_use_subcommand' -f -a clone -d "Clone an instance"
# delete        Delete instances and snapshots
complete -c multipass -n '__fish_use_subcommand' -f -a delete -d "Delete instances and snapshots"
# exec          Run a command on an instance
complete -c multipass -n '__fish_use_subcommand' -f -a exec -d "Run a command on an instance"
# find          Display available images to create instances from
complete -c multipass -n '__fish_use_subcommand' -f -a find -d "Display available images"
# get           Get a configuration setting
complete -c multipass -n '__fish_use_subcommand' -f -a get -d "Get a configuration setting"
# help          Display help about a command
complete -c multipass -n '__fish_use_subcommand' -f -a help -d "Display help about a command"
# info          Display information about instances or snapshots
complete -c multipass -n '__fish_use_subcommand' -f -a info -d "Display info about instances/snapshots"
# launch        Create and start an Ubuntu instance
complete -c multipass -n '__fish_use_subcommand' -f -a launch -d "Create and start an Ubuntu instance"
# list          List all available instances or snapshots
complete -c multipass -n '__fish_use_subcommand' -f -a list -d "List all instances or snapshots"
# mount         Mount a local directory in the instance
complete -c multipass -n '__fish_use_subcommand' -f -a mount -d "Mount a local directory in instance"
# networks      List available network interfaces
complete -c multipass -n '__fish_use_subcommand' -f -a networks -d "List available network interfaces"
# prefer        Switch the current alias context
complete -c multipass -n '__fish_use_subcommand' -f -a prefer -d "Switch current alias context"
# purge         Purge all deleted instances permanently
complete -c multipass -n '__fish_use_subcommand' -f -a purge -d "Purge all deleted instances permanently"
# recover       Recover deleted instances
complete -c multipass -n '__fish_use_subcommand' -f -a recover -d "Recover deleted instances"
# restart       Restart instances
complete -c multipass -n '__fish_use_subcommand' -f -a restart -d "Restart instances"
# restore       Restore an instance from a snapshot
complete -c multipass -n '__fish_use_subcommand' -f -a restore -d "Restore an instance from a snapshot"
# set           Set a configuration setting
complete -c multipass -n '__fish_use_subcommand' -f -a set -d "Set a configuration setting"
# shell         Open a shell on an instance
complete -c multipass -n '__fish_use_subcommand' -f -a shell -d "Open a shell on an instance"
# snapshot      Take a snapshot of an instance
complete -c multipass -n '__fish_use_subcommand' -f -a snapshot -d "Take a snapshot of an instance"
# start         Start instances
complete -c multipass -n '__fish_use_subcommand' -f -a start -d "Start instances"
# stop          Stop running instances
complete -c multipass -n '__fish_use_subcommand' -f -a stop -d "Stop running instances"
# suspend       Suspend running instances
complete -c multipass -n '__fish_use_subcommand' -f -a suspend -d "Suspend running instances"
# transfer      Transfer files between the host and instances
complete -c multipass -n '__fish_use_subcommand' -f -a transfer -d "Transfer files between host and instances"
# umount        Unmount a directory from an instance
complete -c multipass -n '__fish_use_subcommand' -f -a umount -d "Unmount a directory from an instance"
# unalias       Remove aliases
complete -c multipass -n '__fish_use_subcommand' -f -a unalias -d "Remove aliases"
# version       Show version details
complete -c multipass -n '__fish_use_subcommand' -f -a version -d "Show version details"
