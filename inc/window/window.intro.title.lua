--- The title screen: digital rain, a big bomb with a burning fuse between the two players.
--- @section TitleWindow
local TITLE_TEXT = "BOMBEXPERT"
local GROUND_Y = 100
local _title_timer = 0

--- Starts the title screen and the menu music.
--- @within TitleWindow
function TitleWindow.enter()
  _title_timer = 0
  Audio.music_play("menu")
end

--- Draws the title letters, each bouncing on its own wave.
--- @within TitleWindow
local function draw_title()
  local scale = 3
  local width = Print.width(TITLE_TEXT, false, scale)
  local x = (Config.screen.width - width) / 2
  for i = 1, #TITLE_TEXT do
    local ch = TITLE_TEXT:sub(i, i)
    local y = 10 + math.floor(math.sin(_title_timer * 0.08 + i * 0.6) * 3 + 0.5)
    local color = i <= 4 and Config.colors.lime or Config.colors.white
    Print.text_contour(ch, x, y, color, false, scale, Config.colors.black)
    x = x + Print.width(ch, false, scale)
  end
end

--- Draws the big bomb and its fuse spark.
--- @within TitleWindow
--- @param cx number Center x.
--- @param cy number Center y.
local function draw_bomb(cx, cy)
  local colors = Config.colors
  local r = 17
  circ(cx + 3, cy + 3, r, colors.black)
  circ(cx, cy, r, colors.dark_grey)
  circ(cx - 6, cy - 6, 5, colors.grey)
  circ(cx - 7, cy - 7, 2, colors.light_grey)
  rect(cx - 4, cy - r - 4, 9, 6, colors.grey)
  local fx, fy = cx + 1, cy - r - 4
  line(fx, fy, fx + 4, fy - 6, colors.light_grey)
  line(fx + 4, fy - 6, fx + 10, fy - 9, colors.light_grey)
  local sparks = { colors.yellow, colors.orange, colors.white, colors.red }
  for _ = 1, 6 do
    pix(fx + 10 + math.random(-3, 3), fy - 9 + math.random(-3, 3), sparks[math.random(#sparks)])
  end
end

--- Draws the title screen.
--- @within TitleWindow
function TitleWindow.draw()
  local colors = Config.colors
  cls(colors.navy)
  Rain.draw(0, 0, Config.screen.width / 8, GROUND_Y / 8, 8, { head = colors.white, mid = colors.lime, tail = colors.grey })

  rect(0, GROUND_Y, Config.screen.width, Config.screen.height - GROUND_Y, colors.green)
  for x = 0, Config.screen.width - 1, 8 do
    spr(Config.sprites.breakable_wall, x, GROUND_Y, 0)
  end

  draw_title()
  draw_bomb(120, 72)

  local bob = math.floor(_title_timer / 10) % 2
  Board.draw_player_sprite(1, 50, GROUND_Y - 13 - bob, 2)
  Board.draw_player_sprite(2, 174, GROUND_Y - 13 - (1 - bob), 2, 1)

  if Util.blink(20) then
    Print.text_center("PRESS SPACE", Config.screen.width / 2, 116, colors.white)
  end
  print("(c) Teletype Games", 3, 129, colors.grey, false, 1, true)
end

--- Opens the menu on Select.
--- @within TitleWindow
function TitleWindow.update()
  _title_timer = _title_timer + 1
  if Input.select() then
    Audio.sfx_confirm()
    Window.set_current("menu")
  end
end
