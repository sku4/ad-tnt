package = 'ctx'
version = 'scm-1'
source  = {
    url    = 'git+https://github.com/moonlibs/ctx.git',
    branch = 'master',
}
description = {
    summary  = "Package for context request and logs",
    homepage = 'https://github.com/moonlibs/ctx.git',
    license  = 'BSD',
}
dependencies = {
    'lua >= 5.1',
    'base58 >= 0',
    'obj >= 0'
}
build = {
    type = 'builtin',
    modules = {
        ['ctx'] = 'ctx.lua';
        ['ctx.log'] = 'ctx/log.lua';
        ['urandom'] = 'urandom.lua';
    }
}

-- vim: syntax=lua
