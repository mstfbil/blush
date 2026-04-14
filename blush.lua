local blush = {}

local DEFAULTS = {
    color = { 1, 1, 1 },
    font = love.graphics.getFont()
}

function blush.render(richtext, x, y, wrap)
    local cur_x, cur_y = x, y
    local max_line_height = 0
    for _, segment in ipairs(richtext) do
        local text = segment[1] or segment.text
        local color = segment.color or DEFAULTS.color
        local font = segment.font or DEFAULTS.font

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

            love.graphics.print(word, cur_x, cur_y)
            cur_x = cur_x + width
        end
    end
end

setmetatable(blush, {
    __call = function(_, ...)
        blush.render(...)
    end
})

return blush
