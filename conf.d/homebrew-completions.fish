set -l homebrew_completions /opt/homebrew/share/fish/vendor_completions.d

if test -d $homebrew_completions
    if not contains -- $homebrew_completions $fish_complete_path
        set -ga fish_complete_path $homebrew_completions
    end
end
