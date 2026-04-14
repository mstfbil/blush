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

function blush.render(richtext, x, y, wrap)
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
