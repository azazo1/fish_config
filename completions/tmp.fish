complete -c tmp -f
if command -q fd
    complete -c tmp -a '(command fd . --max-depth 1 -t d ~/tmp -x basename)'
end
