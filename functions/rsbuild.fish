function rsbuild --description 'link cargo target directory to the external build volume'
    __require_cmds rsbuild cargo jq; or return

    set -l metadata (command cargo metadata --no-deps --format-version 1)
    if test $status -ne 0
        echo "rsbuild: not in a rust project" >&2
        return 1
    end
    set -l project_root (printf '%s' "$metadata" | command jq -r '.workspace_root')
    set -l raw_target_path (printf '%s' "$metadata" | command jq -r '.target_directory')
    set -l project_name (basename $project_root)
    set -l build_mount /Volumes/build
    set -l target_path "$build_mount/rs/target/$project_name"

    if not test -d "$build_mount"
        echo "rsbuild: External build volume '$build_mount' not found." >&2
        return 1
    end
    if test -L "$raw_target_path"; and test (readlink "$raw_target_path") = "$target_path"
        echo "Target is already symlinked to $target_path"
        return 0
    end
    if not mkdir -p "$target_path"
        echo "rsbuild: failed to create external target directory" >&2
        return 1
    end

    # 只把命令放到提示符上, 由用户确认后回车执行.
    commandline -r "command cargo clean; and command ln -s \"$target_path\" \"$raw_target_path\""
    echo "Command injected to your prompt. Press [Enter] to execute."
end
