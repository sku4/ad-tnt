local utf8 = require 'utf8'
local digest = require 'digest'
local json = require 'json'

local ad = {}

function ad.clean(profile_id, time_to, limit, after)
    local cnt_all = 0
    local cnt_deleted = 0
    local last_tup = box.NULL
    local profile = box.space.ad.index.profile

    for _, tup in profile:pairs(profile_id, { after = after }):take_n(limit) do
        last_tup = tup
        cnt_all = cnt_all + 1
        if tup.u_time < time_to then
            box.space.ad:delete(tup.id)
            cnt_deleted = cnt_deleted + 1
        end
    end

    local pos = ""
    if cnt_all == limit and last_tup ~= box.NULL then
        pos = profile:tuple_pos(last_tup)
    end

    return { status = 200, code = "ok", cnt = cnt_deleted, after = pos }
end

local priority_index = {
    street_id = 9,
    house = 8,
    year = 7,
    price = 6,
    price_m2 = 5,
    m2_main = 4,
    rooms = 3,
    floor = 2,
    floors = 1,
}

local function cond_number(value1, value2)
    if value2 ~= box.NULL and value1 ~= value2 then
        return false
    end

    return true
end

local function cond_string_as_number(value1, value2)
    if value2 ~= box.NULL then
        if value1 == box.NULL then
            return false
        end

        local v1, _ = utf8.lower(value1):gsub("%D+", "")
        local v2, _ = utf8.lower(value2):gsub("%D+", "")
        if v1 ~= v2 then
            return false
        end
    end

    return true
end

local function cond_interval(value1, value2_from, value2_to)
    if value1 == box.NULL then
        return true
    end

    if (value2_from ~= box.NULL and value1 < value2_from) or
            (value2_to ~= box.NULL and value1 > value2_to) then
        return false
    end

    return true
end

local function cond_array(value1, value2_arr)
    if value1 == box.NULL or value2_arr == box.NULL then
        return true
    end

    for _, value2 in pairs(value2_arr) do
        if value1 == value2 then
            return true
        end
    end

    return false
end

local function check_hash(tup)
    if tup.street_id ~= box.NULL and tup.house ~= box.NULL and
            tup.price ~= box.NULL and tup.price > 0 and
            tup.m2_main ~= box.NULL and tup.m2_main > 0 then
        local house, _ = utf8.lower(tup.house):gsub("[%p%s]+", "")
        local key = {
            street_id = tup.street_id,
            house = house,
            price = tup.price,
            rooms = tup.rooms,
            floor = tup.floor,
            m2_main = round_float(tup.m2_main, 1),
            m2_living = round_float(tup.m2_living, 1),
            m2_kitchen = round_float(tup.m2_kitchen, 1),
        }

        return true, digest.crc32(json.encode(key))
    end

    return false, ""
end

function ad.filter(match, limit, after, force)
    local ads = {}
    local ads_dup_set = {}

    local index_name, index_value, index_field = get_priority_index(match, priority_index)
    if index_name == box.NULL then
        return { status = 500, code = "index not found" }
    end

    local iter = get_iterator(index_field)
    local index = box.space.ad.index[index_name]

    local cnt_all = 0
    local last_tup = box.NULL
    for _, tup in index:pairs(index_value, { iterator = iter, after = after }):take_n(limit) do
        last_tup = tup
        cnt_all = cnt_all + 1

        if not cond_number(tup.street_id, match["street_id"]) or
                not cond_string_as_number(tup.house, match["house"]) or
                not cond_interval(tup.price, match["price_from"], match["price_to"]) or
                not cond_interval(tup.price_m2, match["price_m2_from"], match["price_m2_to"]) or
                not cond_interval(tup.rooms, match["rooms_from"], match["rooms_to"]) or
                not cond_interval(tup.floor, match["floor_from"], match["floor_to"]) or
                not cond_interval(tup.floors, match["floors_from"], match["floors_to"]) or
                not cond_interval(tup.year, match["year_from"], match["year_to"]) or
                not cond_interval(tup.m2_main, match["m2_main_from"], match["m2_main_to"]) or
                not cond_array(tup.profile, match["profiles"]) then
            goto continue
        end

        if tup.loc_lat ~= box.NULL and tup.loc_long ~= box.NULL then
            local is_dup, hash = check_hash(tup)
            if is_dup then
                if ads_dup_set[hash] ~= box.NULL then
                    table.insert(ads_dup_set[hash].ids, tup.id)
                else
                    ads_dup_set[hash] = {
                        ids = {tup.id},
                        la = tup.loc_lat,
                        lo = tup.loc_long,
                    }
                end
            else
                table.insert(ads, {
                    id = tup.id,
                    la = tup.loc_lat,
                    lo = tup.loc_long,
                })
            end
        end
        :: continue ::
    end

    for _, ad_dup in pairs(ads_dup_set) do
        if #ad_dup.ids == 1 then
            ad_dup['id'] = ad_dup['ids'][1]
            ad_dup['ids'] = nil
        end

        table.insert(ads, ad_dup)
    end

    local pos = ""
    if cnt_all == limit and last_tup ~= box.NULL then
        pos = index:tuple_pos(last_tup)
    end

    if force == true and #ads == 0 and pos ~= "" then
        return ad.filter(match, limit, pos, force)
    end

    return { status = 200, code = "ok", ads = ads, after = pos }
end

return ad
