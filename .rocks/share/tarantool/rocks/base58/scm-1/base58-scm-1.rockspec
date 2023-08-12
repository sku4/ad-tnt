package = 'base58'
version = 'scm-1'

source  = {
    url    = 'git+https://github.com/moonlibs/base58.git';
    branch = 'master';
}

description = {
    summary  = "Lua base58 on FFI";
    detailed = "Lua base58 on FFI";
    homepage = 'https://github.com/moonlibs/base58';
    license  = 'Artistic';
    maintainer = "Mons Anderson <mons@cpan.org>";
}

dependencies = {
    'lua ~> 5.1';
}

build = {
    type = 'builtin',
    modules = {
        ['base58'] = 'base58.lua';
        ['libbase58'] = {
            sources = {
                "libbase58.c",
            };
        }
    }
}
