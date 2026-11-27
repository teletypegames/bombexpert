--- Digital rain: columns of falling glyphs with a bright head and a fading trail.
--- Stateless: every column's speed and phase come from a hash of its index and the frame.
--- @section Rain
local GLYPHS = "0123456789ABCDEFXZ*+=<>:"
local TRAIL = 7

--- A cheap deterministic hash of two integers.
--- @within Rain
--- @param a number First integer.
--- @param b number Second integer.
--- @return number Hash in 0..65520.
local function rain_hash(a, b)
  return (a * 7919 + b * 104729 + a * b * 31) % 65521
end

--- Draws the rain over a grid of cells.
--- @within Rain
--- @param x0 number Left of the grid.<br/>
--- @param y0 number Top of the grid.<br/>
--- @param cols number Number of columns.<br/>
--- @param rows number Number of rows.<br/>
--- @param cell number Cell size in pixels.<br/>
--- @param colors table Colors: head, mid and tail.<br/>
function Rain.draw(x0, y0, cols, rows, cell, colors)
  cols, rows = math.floor(cols), math.floor(rows)
  for c = 0, cols - 1 do
    local h = rain_hash(c + 1, 7)
    local speed = 0.06 + (h % 7) * 0.015
    local span = rows + TRAIL + h % 13
    local head = math.floor(Context.frame * speed + h) % span
    for t = 0, TRAIL - 1 do
      local row = head - t
      if row >= 0 and row < rows then
        local flicker = t == 0 and math.floor(Context.frame / 6) or 0
        local g = math.floor((rain_hash(c, row) + flicker) % #GLYPHS) + 1
        local color = colors.tail
        if t == 0 then color = colors.head elseif t < 3 then color = colors.mid end
        print(GLYPHS:sub(g, g), x0 + c * cell + 2, y0 + row * cell + 1, color, true, 1, true)
      end
    end
  end
end
