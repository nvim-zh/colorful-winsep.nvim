local config = require("colorful-winsep.config")

---@class BorderNode
---@field index integer The global index in the border loop (0, 1, 2...)
---@field type "vertical_left"|"top_left_corner"|"horizontal_top"|"top_right_corner"|"vertical_right"|"bottom_right_corner"|"horizontal_bottom"|"bottom_left_corner"
---@field char string The character to render
---@field color_idx integer Current color index assigned to this node
---@field win_dir "left"|"up"|"right"|"down" Which floating window this node belongs to
---@field buf_idx integer The character index inside its respective buffer (1-based)

---@class BorderModel
---@field nodes BorderNode[] Array representing the circular linked list
local BorderModel = {}

function BorderModel:new()
    local o = {
        nodes = {}
    }
    self.__index = self
    setmetatable(o, self)
    return o
end

--- Clear the model
function BorderModel:clear()
    self.nodes = {}
end

--- Build the unified circular border based on the current planned layouts
--- @param planned_layouts table layout details from view.lua
function BorderModel:build(planned_layouts)
    self:clear()
    local index = 0

    -- Order: Left (bottom to top) -> Up (left to right) -> Right (top to bottom) -> Down (right to left)
    
    -- 1. Left border (from bottom to top)
    local left = planned_layouts["left"]
    if left then
        -- In nvim buffer, line 1 is top, line N is bottom.
        -- To go bottom-to-top, we iterate from size down to 1.
        for buf_i = left.size, 1, -1 do
            local char = left.body_symbol
            local node_type = "vertical_left"
            
            if buf_i == left.size then
                char = left.end_symbol
                node_type = "bottom_left_corner"
            elseif buf_i == 1 then
                char = left.start_symbol
                node_type = "top_left_corner"
            end
            
            local node = {
                index = index,
                type = node_type,
                char = char,
                win_dir = "left",
                buf_idx = buf_i,
                color_idx = 1
            }
            table.insert(self.nodes, node)
            index = index + 1
        end
    end

    -- 2. Up border (from left to right)
    local up = planned_layouts["up"]
    if up then
        -- Buffer column 1 is left, N is right
        for buf_i = 1, up.size do
            local char = up.body_symbol
            local node_type = "horizontal_top"
            
            if buf_i == 1 then
                char = up.start_symbol
                node_type = "top_left_corner"
            elseif buf_i == up.size then
                char = up.end_symbol
                node_type = "top_right_corner"
            end
            
            local node = {
                index = index,
                type = node_type,
                char = char,
                win_dir = "up",
                buf_idx = buf_i,
                color_idx = 1
            }
            table.insert(self.nodes, node)
            index = index + 1
        end
    end

    -- 3. Right border (from top to bottom)
    local right = planned_layouts["right"]
    if right then
        -- Buffer line 1 is top, line N is bottom
        for buf_i = 1, right.size do
            local char = right.body_symbol
            local node_type = "vertical_right"
            
            if buf_i == 1 then
                char = right.start_symbol
                node_type = "top_right_corner"
            elseif buf_i == right.size then
                char = right.end_symbol
                node_type = "bottom_right_corner"
            end
            
            local node = {
                index = index,
                type = node_type,
                char = char,
                win_dir = "right",
                buf_idx = buf_i,
                color_idx = 1
            }
            table.insert(self.nodes, node)
            index = index + 1
        end
    end

    -- 4. Down border (from right to left)
    local down = planned_layouts["down"]
    if down then
        -- Buffer column N is right, 1 is left. 
        -- To go right-to-left, we iterate from size down to 1
        for buf_i = down.size, 1, -1 do
            local char = down.body_symbol
            local node_type = "horizontal_bottom"
            
            if buf_i == down.size then
                char = down.end_symbol
                node_type = "bottom_right_corner"
            elseif buf_i == 1 then
                char = down.start_symbol
                node_type = "bottom_left_corner"
            end
            
            local node = {
                index = index,
                type = node_type,
                char = char,
                win_dir = "down",
                buf_idx = buf_i,
                color_idx = 1
            }
            table.insert(self.nodes, node)
            index = index + 1
        end
    end
end

--- Get all nodes
function BorderModel:get_nodes()
    return self.nodes
end

--- Get total length of the border loop
function BorderModel:len()
    return #self.nodes
end

return BorderModel
