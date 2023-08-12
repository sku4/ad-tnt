---
--- Migration "1690021104_map"
--- Date: 1690021104 - 07/22/23 13:18:24
---

return {
    up = function()
        box.space.ad:create_index('street_id', {
            parts = { 'street_id' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.ad:create_index('house', {
            parts = { { 'house', 'string', collation = 'unicode_ci' } },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.ad:create_index('price', {
            parts = { { 'price' } },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.ad:create_index('price_m2', {
            parts = { { 'price_m2' } },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.ad:create_index('rooms', {
            parts = { 'rooms' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.ad:create_index('floor', {
            parts = { 'floor' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.ad:create_index('floors', {
            parts = { 'floors' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.ad:create_index('year', {
            parts = { 'year' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space.ad:create_index('m2_main', {
            parts = { 'm2_main' },
            type = 'tree',
            unique = false,
            if_not_exists = true
        })
        box.space._spacer_models:replace({"ad"})
    end,

    down = function()
        box.space.ad.index.street_id:drop()
        box.space.ad.index.house:drop()
        box.space.ad.index.price:drop()
        box.space.ad.index.price_m2:drop()
        box.space.ad.index.rooms:drop()
        box.space.ad.index.floor:drop()
        box.space.ad.index.floors:drop()
        box.space.ad.index.year:drop()
        box.space.ad.index.m2_main:drop()
        box.space._spacer_models:replace({"ad"})
    end,
}
