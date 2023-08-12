function get_priority_index(match, priority_index)
    local max_priority = 0
    local max_index_name = "primary"
    local max_index_value = box.NULL
    local max_index_field = "primary"

    for field, value in pairs(match) do
        local field_clean, _ = field:gsub("_from", "")
        field_clean, _ = field_clean:gsub("_to", "")
        local priority = priority_index[field_clean]
        if priority ~= box.NULL and priority > max_priority and value ~= -1 then
            max_priority = priority
            max_index_name = field_clean
            max_index_value = value
            max_index_field = field
        end
    end

    return max_index_name, max_index_value, max_index_field
end

function get_iterator(index_field)
    local f, _ = string.find(index_field, "_from")
    if f ~= box.NULL then
        return 'GE' -- Key >= x
    end

    f, _ = string.find(index_field, "_to")
    if f ~= box.NULL then
        return 'LE' -- Key >= x
    end

    if index_field == "year" or
            index_field == "price" or
            index_field == "price_m2" or
            index_field == "rooms" or
            index_field == "floor" or
            index_field == "m2_main" then
        return 'LE' -- Key <= x
    elseif index_field == "primary" then
        return 'GE' -- Key >= x
    end

    return 'EQ'
end

function round_float(num, dec)
    if num == box.NULL then
        return 0
    end

    return tonumber(string.format("%." .. (dec or 0) .. "f", num))
end
