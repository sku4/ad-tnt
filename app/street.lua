local street = {}

-- Получение типов улиц
function street.get_types()
    local types = {}
    -- in_start обозначает расположение названия типа относительно названия улицы
    -- например Меньковский тракт - тип располагается вконце
    table.insert(types, { id = 0, short = '', any = { }, in_start = true })
    table.insert(types, { id = 1, short = 'ул', any = { 'улица', 'ул' }, in_start = true })
    table.insert(types, { id = 2, short = 'пер', any = { 'переулок', 'пер' }, in_start = true })
    table.insert(types, { id = 3, short = 'просп', any = { 'проспект', 'пр', 'пр-кт', 'просп' }, in_start = true })
    table.insert(types, { id = 4, short = 'пр-д', any = { 'проезд', 'п-д', 'пр-д' }, in_start = false })
    table.insert(types, { id = 5, short = 'б-р', any = { 'бульвар', 'б-р', 'бул', 'бульв' }, in_start = true })
    table.insert(types, { id = 6, short = 'тракт', any = { 'тракт', 'тр' }, in_start = false })
    table.insert(types, { id = 7, short = 'пл', any = { 'площадь', 'пл' }, in_start = true })

    return { status = 200, code = "ok", types = types }
end

-- Получение id улицы по названию, если улица не найдена она будет добавлена
function street.get_id(name)
    local resp = street.get_types()
    local types = resp.types
    local utf8 = require 'utf8'

    local words = {}
    for w in string.gmatch(name, "%S+") do
        table.insert(words, w)
    end

    local check_words = {}
    if #words > 1 then
        table.insert(check_words, utf8.lower(words[1]))
        table.insert(check_words, utf8.lower(words[#words]))
    elseif #words > 0 then
        table.insert(check_words, utf8.lower(words[1]))
    end

    local street_type = 0
    for cwk, cwv in pairs(check_words) do
        local found = false
        for _, tv in pairs(types) do
            for _, av in pairs(tv.any) do
                if cwv == av or cwv == av .. "." then
                    found = true
                    break
                end
            end
            if found then
                street_type = tv.id
                break
            end
        end
        if found then
            if cwk == 1 then
                table.remove(words, 1)
            else
                table.remove(words, #words)
            end
            break
        end
    end

    local street_name = table.concat(words, " ")

    if street_name == "" then
        return { status = 500, code = "parse error" }
    end

    local street_id = 0
    local streets = {}
    if street_type > 0 then
        streets = box.space.street.index.name:select({ street_name, street_type })
    else
        streets = box.space.street.index.name:select({ street_name })
    end
    for _, s in pairs(streets) do
        street_id = s.id
        break
    end

    if street_id == 0 then
        local s_name = street_name
        for _, s in pairs(box.space.street.index.name:select({ street_name })) do
            s_name = s.name
            break
        end

        local t = box.space.street:insert { box.NULL, s_name, street_type }
        street_id = t.id
    end

    return { status = 200, code = "ok", id = street_id }
end

return street
