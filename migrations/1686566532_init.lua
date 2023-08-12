---
--- Migration "1686566532_init"
--- Date: 1686566532 - 06/12/23 10:42:12
---

return {
    up = function()
        -- streets
        box.schema.space.create('street', { if_not_exists = true, engine = 'memtx' })
        box.space.street:format({
            { name = 'id', type = 'unsigned' },
            { name = 'name', type = 'string' },
            { name = 'type', type = 'unsigned' },
        })
        box.space.street:create_index('primary', {
            parts = { 'id' },
            type = 'tree',
            sequence = true,
            if_not_exists = true
        })
        box.space.street:create_index('name', {
            parts = { { 'name', 'string', collation = 'unicode_ci' }, { 'type' } },
            type = 'tree',
            if_not_exists = true
        })
        box.space.street:create_index('type', {
            parts = { 'type' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space._spacer_models:replace({ 'street' })
        -- ads
        box.schema.space.create('ad', { if_not_exists = true, engine = 'memtx' })
        box.space.ad:format({
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
        })
        box.space.ad:create_index('primary', {
            parts = { 'id' },
            type = 'tree',
            sequence = true,
            if_not_exists = true
        })
        box.space.ad:create_index('xq', {
            parts = { 'nq_status', 'id' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.ad:create_index('ext', {
            parts = { 'ext_id' },
            type = 'tree',
            if_not_exists = true
        })
        box.space.ad:create_index('profile', {
            parts = { 'profile' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.ad:create_index('location', {
            parts = { 'loc_lat', 'loc_long' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space._spacer_models:replace({ 'ad' })
        -- subscription
        box.schema.space.create('subscription', { if_not_exists = true, engine = 'memtx' })
        box.space.subscription:format({
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
        })
        box.space.subscription:create_index('primary', {
            parts = { 'id' },
            type = 'tree',
            sequence = true,
            if_not_exists = true
        })
        box.space.subscription:create_index('tg_id', {
            parts = { 'tg_id' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.subscription:create_index('street_id', {
            parts = { 'street_id' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.subscription:create_index('house', {
            parts = { { 'house', 'string', collation = 'unicode_ci' } },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.subscription:create_index('price', {
            parts = { { 'price_from' } },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.subscription:create_index('price_m2', {
            parts = { { 'price_m2_from' } },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.subscription:create_index('rooms', {
            parts = { 'rooms_from' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.subscription:create_index('floor', {
            parts = { 'floor_from' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.subscription:create_index('year', {
            parts = { 'year_from' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.subscription:create_index('m2_main', {
            parts = { 'm2_main_from' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.subscription:create_index('uniq', {
            parts = { 'tg_id', 'street_id', 'house', 'price_from', 'price_to',
                      'price_m2_from', 'price_m2_to', 'rooms_from', 'rooms_to',
                      'floor_from', 'floor_to', 'year_from', 'year_to',
                      'm2_main_from', 'm2_main_to'},
            type = 'tree',
            if_not_exists = true
        })
        box.space._spacer_models:replace({ 'subscription' })
    end,

    down = function()
        box.space.ad:drop()
        box.space._spacer_models:delete({ 'ad' })
        box.space.subscription:drop()
        box.space._spacer_models:delete({ 'subscription' })
        box.space.street:drop()
        box.space._spacer_models:delete({ 'street' })
    end,
}
