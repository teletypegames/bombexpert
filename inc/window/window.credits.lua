--- Credits: falling title, raster bars, the names appearing one by one and a rainbow scroller.
--- @section CreditsWindow
local CREDITS_TITLE = "CREDITS"
local LINES = {
  {
    text = "Author: Zsolt Tasnadi",
    color = 12,
  },
  {
    text = "Powered by Claude",
    color = 11,
  },
  {
    text = "Sponsored by Zen Heads",
    color = 4,
  },
  {
    text = "Happy X-MAS!",
    color = 2,
  },
}
local SCROLL = "BOMBEXPERT FOR TIC-80   *   TELETYPEGAMES.ORG   *   THANKS FOR PLAYING   *   "
local RASTER = { 8, 9, 10, 11, 12, 11, 10, 9, 8 }
local RAINBOW = { 4, 3, 2, 11, 10, 5 }
local TITLE_FALL = 20
local TITLE_DELAY = 5
local LINE_DELAY = 25
local LINE_SLIDE = 18
local _credits_timer = 0
local _scroll_x = 0
local _scroll_w = 0

--- Starts the credits.
--- @within CreditsWindow
function CreditsWindow.enter()
  _credits_timer = 0
  _scroll_x = Config.screen.width
  _scroll_w = Print.width(SCROLL)
end

--- Draws two raster bars swinging behind the text.
--- @within CreditsWindow
local function draw_raster()
  for b = 0, 1 do
    local y = math.floor(70 + math.sin(_credits_timer * 0.04 + b * 2.5) * 32)
    for i, color in ipairs(RASTER) do
      rect(0, y + i, Config.screen.width, 1, color)
    end
  end
end

--- Draws the title, its letters falling in one after the other.
--- @within CreditsWindow
local function draw_credits_title()
  local scale = 2
  local x = (Config.screen.width - Print.width(CREDITS_TITLE, false, scale)) / 2
  for i = 1, #CREDITS_TITLE do
    local ch = CREDITS_TITLE:sub(i, i)
    local t = math.min(1, math.max(0, (_credits_timer - i * TITLE_DELAY) / TITLE_FALL))
    if t > 0 then
      local y = math.floor(-16 + (1 - (1 - t) * (1 - t)) * 24)
      Print.text_contour(ch, x, y, Config.colors.yellow, false, scale)
    end
    x = x + Print.width(ch, false, scale)
  end
end

--- Draws the names, each sliding in from the right in turn.
--- @within CreditsWindow
local function draw_lines()
  for i, entry in ipairs(LINES) do
    local t = math.min(1, math.max(0, (_credits_timer - 30 - i * LINE_DELAY) / LINE_SLIDE))
    if t > 0 then
      local center = Config.screen.width / 2 + (1 - t) * Config.screen.width
      Print.text_center_contour(entry.text, center, 34 + i * 16, entry.color, false, 1)
    end
  end
end

--- Draws the rainbow scroller.
--- @within CreditsWindow
local function draw_scroller()
  local x = _scroll_x
  for i = 1, #SCROLL do
    local ch = SCROLL:sub(i, i)
    local w = Print.width(ch)
    if x > -8 and x < Config.screen.width then
      local y = 124 + math.floor(math.sin(_credits_timer * 0.15 + i * 0.4) * 2 + 0.5)
      print(ch, x, y, RAINBOW[(i + math.floor(_credits_timer / 4)) % #RAINBOW + 1])
    end
    x = x + w
  end
end

--- Draws the credits.
--- @within CreditsWindow
function CreditsWindow.draw()
  cls(Config.colors.black)
  draw_raster()
  draw_credits_title()
  draw_lines()
  draw_scroller()
end

--- Scrolls and goes back to the menu on a key.
--- @within CreditsWindow
function CreditsWindow.update()
  _credits_timer = _credits_timer + 1
  _scroll_x = _scroll_x - 1
  if _scroll_x < -_scroll_w then _scroll_x = Config.screen.width end
  if Input.back() or Input.select() then
    Audio.sfx_back()
    Window.set_current("menu")
  end
end
