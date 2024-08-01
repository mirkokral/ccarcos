---@param x number
---@param y number
---@param bgCol any
---@param forCol any
---@param text any
local function blitAtPos(x, y, bgCol, forCol, text)
    term.setCursorPos(x, y)
    term.setBackgroundColor(bgCol)
    term.setTextColor(forCol)
    term.write(text)
end
---@class RenderCommand
---@field x number

---@class Widget
---@field x number The x position of the button
---@field y number The y position of the button
---@field getDrawCommands fun(): RenderCommand[]

---@param config { label: string, x: number, y: number, col: number?, textCol: number? } The button configuration
function Button(config)
end

-- C:Exc
_G.ui = {
    Button = Button
}
-- C:End
