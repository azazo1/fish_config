function dpd --description 'dump dir to agent'
    __require_cmds dpd rg; or return
    command rg --pretty --color never .
end

