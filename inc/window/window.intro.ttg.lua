--- @section TTGIntroWindow
local LOGO = {
  "###### ###### ######",
  "  ##     ##   #     ",
  "  ##     ##   # ####",
  "  ##     ##   #    #",
  "  ##     ##   ######",
}
local BLOCK = 5
local REVEAL_SPEED = 0.5
local _timer = 0

--- Starts the intro.
--- @within TTGIntroWindow
function TTGIntroWindow.enter()
  _timer = 0
end

--- Draws the Teletype Games logo, revealed column by column.
--- @within TTGIntroWindow
function TTGIntroWindow.draw()
  cls(Config.colors.black)
  local cols = #LOGO[1]
  local x0 = math.floor((Config.screen.width - cols * BLOCK) / 2)
  local y0 = 40
  local reveal = math.floor(_timer * REVEAL_SPEED)
  for row, line in ipairs(LOGO) do
    for col = 1, math.min(cols, reveal) do
      if line:sub(col, col) == "#" then
        local color = col >= reveal - 1 and Config.colors.white or Config.colors.lime
        rect(x0 + (col - 1) * BLOCK, y0 + (row - 1) * BLOCK, BLOCK - 1, BLOCK - 1, color)
      end
    end
  end
  if reveal > cols + 8 then
    Print.text_center("Teletype Games", Config.screen.width / 2, y0 + #LOGO * BLOCK + 10, Config.colors.light_grey)
  end
end

--- Moves on to the title after a while or on a key.
--- @within TTGIntroWindow
function TTGIntroWindow.update()
  _timer = _timer + 1
  if _timer >= Config.timing.intro_duration or Input.select() or Input.back() then
    Window.set_current("title")
  end
end
