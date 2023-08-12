local spacer = require 'spacer'.get()
local xq = require('xqueue')

spacer:space({
    name = 'street',
    format = {
        { name = 'id', type = 'unsigned' },
        { name = 'name', type = 'string' },
        { name = 'type', type = 'unsigned' },
    },
    indexes = {
        { name = 'primary', type = 'tree', sequence = true, parts = { 'id' } },
        { name = 'name', type = 'tree', parts = { { 'name', 'string', collation = 'unicode_ci' }, { 'type' } } },
        { name = 'type', type = 'tree', unique = false, parts = { 'type' } },
    }
})

spacer:space({
    name = 'ad',
    format = {
        { name = 'id', type = 'unsigned' },
        { name = 'ext_id', type = 'unsigned' },
        { name = 'c_time', type = 'datetime' },
        { name = 'u_time', type = 'datetime' },
        { name = 'nq_status', type = 'string' }, -- notification queue status
        { name = 'url', type = 'string' },
        { name = 'street_id', type = 'unsigned', foreign_key = { space = 'street', field = 'id' }, is_nullable = true },
        { name = 'house', type = 'string', is_nullable = true },
        { name = 'loc_lat', type = 'double', is_nullable = true },
        { name = 'loc_long', type = 'double', is_nullable = true },
        { name = 'price', type = 'decimal', is_nullable = true },
        { name = 'price_m2', type = 'decimal', is_nullable = true },
        { name = 'rooms', type = 'integer', is_nullable = true },
        { name = 'floor', type = 'integer', is_nullable = true },
        { name = 'floors', type = 'integer', is_nullable = true },
        { name = 'year', type = 'integer', is_nullable = true },
        { name = 'photos', type = 'any', is_nullable = true },
        { name = 'm2_main', type = 'number', is_nullable = true },
        { name = 'm2_living', type = 'number', is_nullable = true },
        { name = 'm2_kitchen', type = 'number', is_nullable = true },
        { name = 'bathroom', type = 'string', is_nullable = true },
        { name = 'profile', type = 'unsigned' },
    },
    indexes = {
        { name = 'primary', type = 'tree', sequence = true, parts = { 'id' } },
        { name = 'xq', type = 'tree', unique = false, parts = { 'nq_status', 'id' } },
        { name = 'ext', type = 'tree', parts = { 'ext_id' } },
        { name = 'profile', type = 'tree', unique = false, parts = { 'profile' } },
        { name = 'location', type = 'tree', unique = false, parts = { 'loc_lat', 'loc_long' }, },
        { name = 'street_id', type = 'tree', unique = false, parts = { 'street_id' }, },
        { name = 'house', type = 'tree', unique = false, parts = { { 'house', 'string', collation = 'unicode_ci' } }, },
        { name = 'price', type = 'tree', unique = false, parts = { 'price' }, },
        { name = 'price_m2', type = 'tree', unique = false, parts = { 'price_m2' }, },
        { name = 'rooms', type = 'tree', unique = false, parts = { 'rooms' }, },
        { name = 'floor', type = 'tree', unique = false, parts = { 'floor' }, },
        { name = 'floors', type = 'tree', unique = false, parts = { 'floors' }, },
        { name = 'year', type = 'tree', unique = false, parts = { 'year' }, },
        { name = 'm2_main', type = 'tree', unique = false, parts = { 'm2_main' }, },
    }
})

spacer:space({
    name = 'subscription',
    format = {
        { name = 'id', type = 'unsigned' },
        { name = 'tg_id', type = 'number', is_nullable = true },
        { name = 'c_time', type = 'datetime' },
        { name = 'street_id', type = 'unsigned', foreign_key = { space = 'street', field = 'id' }, is_nullable = true },
        { name = 'house', type = 'string', is_nullable = true },
        { name = 'price_from', type = 'decimal', is_nullable = true },
        { name = 'price_to', type = 'decimal', is_nullable = true },
        { name = 'price_m2_from', type = 'decimal', is_nullable = true },
        { name = 'price_m2_to', type = 'decimal', is_nullable = true },
        { name = 'rooms_from', type = 'integer', is_nullable = true },
        { name = 'rooms_to', type = 'integer', is_nullable = true },
        { name = 'floor_from', type = 'integer', is_nullable = true },
        { name = 'floor_to', type = 'integer', is_nullable = true },
        { name = 'year_from', type = 'integer', is_nullable = true },
        { name = 'year_to', type = 'integer', is_nullable = true },
        { name = 'm2_main_from', type = 'number', is_nullable = true },
        { name = 'm2_main_to', type = 'number', is_nullable = true },
    },
    indexes = {
        { name = 'primary', type = 'tree', sequence = true, parts = { 'id' } },
        { name = 'tg_id', type = 'tree', unique = false, parts = { 'tg_id' }, },
        { name = 'street_id', type = 'tree', unique = false, parts = { 'street_id' }, },
        { name = 'house', type = 'tree', unique = false, parts = { { 'house', 'string', collation = 'unicode_ci' } }, },
        { name = 'price', type = 'tree', unique = false, parts = { 'price_from' }, },
        { name = 'price_m2', type = 'tree', unique = false, parts = { 'price_m2_from' }, },
        { name = 'rooms', type = 'tree', unique = false, parts = { 'rooms_from' }, },
        { name = 'floor', type = 'tree', unique = false, parts = { 'floor_from' }, },
        { name = 'year', type = 'tree', unique = false, parts = { 'year_from' }, },
        { name = 'm2_main', type = 'tree', unique = false, parts = { 'm2_main_from' }, },
        { name = 'uniq', type = 'tree', parts = { 'tg_id', 'street_id', 'house', 'price_from', 'price_to',
                                                  'price_m2_from', 'price_m2_to', 'rooms_from', 'rooms_to',
                                                  'floor_from', 'floor_to', 'year_from', 'year_to',
                                                  'm2_main_from', 'm2_main_to' }, },
    }
})

function make_queue()
    if box.space.ad ~= nil then
        xq(
                box.space.ad,
                {
                    fields = {
                        status = 'nq_status',
                    },
                    features = {
                        id = function()
                            return box.sequence.ad_seq:next()
                        end,
                        buried = true,
                        delayed = false,
                        keep = true,
                        ttl = false,
                        ttr = false,
                    },
                }
        )
    end
end

make_queue()
