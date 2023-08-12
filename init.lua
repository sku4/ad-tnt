require('strict').on()

local fio = require('fio')
local log   = require 'log'

local source = debug.getinfo(1, "S").source:sub(2)
local init_lua = fio.readlink(source)
local app_root = fio.dirname(fio.abspath(init_lua or source))

local instance_name = assert(
        os.getenv('TT_INSTANCE_NAME'), "TT_INSTANCE_NAME required"
)
local instance_port = assert(
        os.getenv('TT_INSTANCE_PORT'), "TT_INSTANCE_PORT required"
)
-- replicaset
local replication = assert(
        os.getenv('TT_REPLICATION'), "TT_REPLICATION required"
)
local replication_t={}
for w in string.gmatch(replication, "[^,]+") do
    table.insert(replication_t, w)
end
log.info("Replication: %s", replication)

local instance_ro = os.getenv('TT_INSTANCE_RO')
local read_only = not (instance_ro == nil or instance_ro == '')
local data_dir = instance_name
if not fio.stat(data_dir) then
    fio.mktree(data_dir)
end
log.info("RO: %s", read_only)

box.cfg {
    listen = instance_port,
    memtx_dir = data_dir,
    vinyl_dir = data_dir,
    wal_dir = data_dir,
    pid_file  = data_dir .. '/' .. instance_name .. ".pid",
    memtx_memory = 512 * 1024 * 1024,
    vinyl_memory = 256 * 1024 * 1024,
    vinyl_cache = 256 * 1024 * 1024,
    -- replicaset
    read_only = read_only,
    replication = replication_t,
}

box.spacer = require 'spacer'.new {
    migrations = fio.pathjoin(app_root, 'migrations'),
}

if not box.info.ro then
    box.schema.user.grant(
            'guest', 'super', nil, nil,
            { if_not_exists = true }
    )

    log.info("Run migrations")
    box.spacer:migrate_up()
end

app = require('app')
app.start()
