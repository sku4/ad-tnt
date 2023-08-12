local utf8 = require 'utf8'

local subscription = {}
local priority_index = {
    street_id = 8,
    house = 7,
    year = 6,
    price = 5,
    price_m2 = 4,
    m2_main = 3,
    rooms = 2,
    floor = 1,
}

local function cond_number(value1, value2)
    if (value1 == box.NULL and value2 ~= box.NULL) or
            (value1 ~= box.NULL and value1 ~= value2) then
        return false
    end

    return true
end

local function cond_string(value1, value2)
    if value1 == box.NULL and value2 ~= box.NULL then
        return false
    elseif value1 ~= box.NULL then
        if value2 == box.NULL or utf8.lower(value1) ~= utf8.lower(value2) then
            return false
        end
    end

    return true
end

local function cond_string_as_number(value1, value2)
    if value1 == box.NULL and value2 ~= box.NULL then
        return false
    elseif value1 ~= box.NULL then
        if value2 == box.NULL then
            return false
        else
            local v1, _ = utf8.lower(value1):gsub("%D+", "")
            local v2, _ = utf8.lower(value2):gsub("%D+", "")
            if v1 ~= v2 then
                return false
            end
        end
    end

    return true
end

local function cond_interval(value1, value2_from, value2_to)
    if value1 == -1 then
        return true
    end
    if value1 == box.NULL and (value2_from ~= box.NULL or value2_to ~= box.NULL) then
        return false
    elseif value1 ~= box.NULL then
        if (value2_from == box.NULL and value2_to == box.NULL) or
                (value2_from ~= box.NULL and value1 < value2_from) or
                (value2_to ~= box.NULL and value1 > value2_to) then
            return false
        end
    end

    return true
end

function subscription.filter(match, limit, after, force)
    local tg_ids = {}
    local tg_ids_set = {}

    local index_name, index_value, index_field = get_priority_index(match, priority_index)
    if index_name == box.NULL then
        return { status = 500, code = "index not found" }
    end
    local iter = get_iterator(index_field)
    local index = box.space.subscription.index[index_name]

    local cnt_all = 0
    local last_tup = box.NULL
    for _, tup in index:pairs(index_value, { iterator = iter, after = after }):take_n(limit) do
        last_tup = tup
        cnt_all = cnt_all + 1

        if not cond_number(match["street_id"], tup.street_id) or
                not cond_string_as_number(match["house"], tup.house) or
                not cond_interval(match["price"], tup.price_from, tup.price_to) or
                not cond_interval(match["price_m2"], tup.price_m2_from, tup.price_m2_to) or
                not cond_interval(match["rooms"], tup.rooms_from, tup.rooms_to) or
                not cond_interval(match["floor"], tup.floor_from, tup.floor_to) or
                not cond_interval(match["year"], tup.year_from, tup.year_to) or
                not cond_interval(match["m2_main"], tup.m2_main_from, tup.m2_main_to) then
            goto continue
        end

        if tup.tg_id ~= box.NULL then
            tg_ids_set[tup.tg_id] = true
        end
        :: continue ::
    end

    for tg_id, _ in pairs(tg_ids_set) do
        table.insert(tg_ids, tg_id)
    end

    local pos = ""
    if cnt_all == limit and last_tup ~= box.NULL then
        pos = index:tuple_pos(last_tup)
    end

    if force == true and #tg_ids == 0 and pos ~= "" then
        return subscription.filter(match, limit, pos, force)
    end

    return { status = 200, code = "ok", tg_ids = tg_ids, after = pos }
end

function subscription.get_by_tg_id(tg_id, limit, after)
    local subscriptions = {}
    local index = box.space.subscription.index.tg_id

    local cnt = 0
    local last_tup = box.NULL
    for _, tup in index:pairs(tg_id, { iterator = 'EQ', after = after }):take_n(limit) do
        last_tup = tup
        cnt = cnt + 1
        table.insert(subscriptions, tup:tomap({ names_only = true }))
    end

    local pos = ""
    if cnt == limit and last_tup ~= box.NULL then
        pos = index:tuple_pos(last_tup)
    end

    local cnt_all = index:count(tg_id)

    return { status = 200, code = "ok", subscriptions = subscriptions, after = pos, all = cnt_all }
end

return subscription
