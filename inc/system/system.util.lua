--- @section Util

--- Converts a board pixel coordinate to a grid coordinate (1-based).
--- @within Util
--- @param pixel number Pixel coordinate relative to the board.
--- @return number The grid coordinate.
function Util.to_grid(pixel)
  return math.floor(pixel / Config.board.tile_size) + 1
end

--- Converts a grid coordinate (1-based) to a board pixel coordinate.
--- @within Util
--- @param grid number Grid coordinate.
--- @return number The pixel coordinate relative to the board.
function Util.to_pixel(grid)
  return (grid - 1) * Config.board.tile_size
end

--- Whether a grid cell lies on the board.
--- @within Util
--- @param grid_x number Column.
--- @param grid_y number Row.
--- @return boolean
function Util.on_board(grid_x, grid_y)
  return grid_x >= 1 and grid_y >= 1 and grid_x <= Config.board.width and grid_y <= Config.board.height
end

--- Moves an index by a step and wraps it into 1..count.
--- @within Util
--- @param index number The current index.
--- @param step number The step (+1 or -1).
--- @param count number Number of items.
--- @return number The wrapped index.
function Util.wrap(index, step, count)
  return (index - 1 + step) % count + 1
end

--- Whether a blinking element is visible in this frame.
--- @within Util
--- @param period number Frames of one on or off half.
--- @return boolean
function Util.blink(period)
  return math.floor(Context.frame / period) % 2 == 0
end
