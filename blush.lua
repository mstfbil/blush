local blush = {}

local DEFAULTS = {
    color = { 1, 1, 1 },
    font = love.graphics.getFont(),
    r = 0,
    sx = 1,
    ox = 0,
    oy = 0,
    kx = 0,
    ky = 0
}

function blush.render(richtext, x, y, wrap, align)
    local cur_x, cur_y

    cur_x = x
    local lines = { {} }
    local cur_line_width, cur_line_height = 0, 0
    for _, segment in ipairs(richtext) do
        local text = segment[1] or segment.text
        local font = segment.font or DEFAULTS.font

        for word in string.gmatch(text, "%S+%s*") do
            local word_width = font:getWidth(word)
            local word_height = font:getHeight()
            if word_height > cur_line_height then
                cur_line_height = word_height
            end

            if wrap and (cur_x + word_width > wrap + x) and cur_line_width > 0 then
                lines[#lines].width = cur_line_width
                lines[#lines].height = cur_line_height

                table.insert(lines, {})
                cur_x = 0
                cur_line_width, cur_line_height = 0, 0
            end

            if word_height > cur_line_height then
                cur_line_height = word_height
            end

            cur_line_width = cur_line_width + word_width
            cur_x = cur_x + word_width

            table.insert(lines[#lines], {
                word = word,
                segment = segment,
                width = word_width,
                height = word_height
            })
        end
    end

    if #lines > 0 then
        lines[#lines].width = cur_line_width
        lines[#lines].height = cur_line_height
    end

    cur_y = y
    for _, line in ipairs(lines) do
        local line_width = line.width
        local line_height = line.height

        cur_x = x

        local align_offset = 0
        if wrap and align then
            if align == "center" then
                align_offset = (wrap - line_width) / 2
            elseif align == "right" then
                align_offset = wrap - line_width
            end
        end

        for _, v in ipairs(line) do
            local word = v.word
            local word_width = v.width

            local segment = v.segment
            local color = segment.color or DEFAULTS.color
            local font = segment.font or DEFAULTS.font
            local r = segment.r or DEFAULTS.r
            local sx = segment.sx or DEFAULTS.sx
            local sy = segment.sy or sx
            local ox = segment.ox or DEFAULTS.ox
            local oy = segment.oy or DEFAULTS.oy
            local kx = segment.kx or DEFAULTS.kx
            local ky = segment.ky or DEFAULTS.ky

            love.graphics.setColor(color)
            love.graphics.setFont(font)

            love.graphics.print(word, cur_x + align_offset, cur_y, r, sx, sy, ox, oy, kx, ky)
            cur_x = cur_x + word_width
        end

        cur_y = cur_y + line_height
    end
end

function blush.renderold(richtext, x, y, wrap)
    local cur_x, cur_y = x, y
    local max_line_height = 0
    for _, segment in ipairs(richtext) do
        local text = segment[1] or segment.text
        local color = segment.color or DEFAULTS.color
        local font = segment.font or DEFAULTS.font
        local r = segment.r or DEFAULTS.r
        local sx = segment.sx or DEFAULTS.sx
        local sy = segment.sy or sx
        local ox = segment.ox or DEFAULTS.ox
        local oy = segment.oy or DEFAULTS.oy
        local kx = segment.kx or DEFAULTS.kx
        local ky = segment.ky or DEFAULTS.ky

        love.graphics.setColor(color)
        love.graphics.setFont(font)

        local height = font:getHeight()
        if height > max_line_height then
            max_line_height = height
        end

        for word in string.gmatch(text, "%S+%s*") do
            local width = font:getWidth(word)

            if wrap and (cur_x + width > x + wrap) and (cur_x > x) then
                cur_x = x
                cur_y = cur_y + max_line_height
                max_line_height = height
            end

            love.graphics.print(word, cur_x, cur_y, r, sx, sy, ox, oy, kx, ky)
            cur_x = cur_x + width
        end
    end
end

function blush.sub(richtext, i, j)
    local n = {}
    local pos = 1

    for _, segment in ipairs(richtext) do
        local text = segment[1] or segment.text
        local segment_end = pos + #text - 1

        if segment_end >= i and pos <= j then
            local rel_i = math.max(1, i - pos + 1)
            local rel_j = math.min(#text, j - pos + 1)

            local slice = {}
            for k, v in pairs(segment) do
                slice[k] = v
            end
            slice[1] = string.sub(text, rel_i, rel_j)

            table.insert(n, slice)
        end

        pos = pos + #text
        if pos > j then break end
    end

    return n
end

function blush.length(richtext)
    local n = 0
    for _, segment in ipairs(richtext) do
        local text = segment[1] or segment.text
        n = n + #text
    end
    return n
end

function blush.updateDefaults(t)
    for k, v in pairs(t) do
        DEFAULTS[k] = v
    end
end

setmetatable(blush, {
    __call = function(_, ...)
        blush.render(...)
    end
})

return blush
