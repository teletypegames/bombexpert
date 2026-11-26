--- @section MenuWindow
local HEADER_H = 28
local ANIM_SPEED = 0.06
local MENU_X = 150
local MENU_Y = 44
local _anim = 0

local MENU_ITEMS = {
  {
    label = "1 Player Game",
    action = function()
      Match.start(false)
      Window.set_current("game")
    end,
  },
  {
    label = "2 Player Game",
    action = function()
      Match.start(true)
      Window.set_current("game")
    end,
  },
  {
    label = "Settings",
    action = function() Window.set_current("settings") end,
  },
  {
    label = "Controls",
    action = function() Window.set_current("controls") end,
  },
  {
    label = "Credits",
    action = function() Window.set_current("credits") end,
  },
  {
    label = "Exit",
    action = function() exit() end,
  },
}

--- Starts the slide-in animation and the menu music.
--- @within MenuWindow
function MenuWindow.enter()
  _anim = 0
  Audio.music_play("menu")
end

--- Draws the header with the title.
--- @within MenuWindow
function MenuWindow.draw_header()
  rect(0, 0, Config.screen.width, HEADER_H, Config.colors.black)
  rect(0, HEADER_H - 2, Config.screen.width, 2, Config.colors.lime)
  Print.text_center("BOMBEXPERT", Config.screen.width / 2, 5, Config.colors.lime, false, 2)
  Print.text_center("blow up your friends", Config.screen.width / 2, 18, Config.colors.light_grey, false, 1)
end

--- Draws the two players and a bomb, 4x scaled, sliding in from the left.
--- @within MenuWindow
function MenuWindow.draw_heroes()
  local ease = 1 - (1 - _anim) * (1 - _anim)
  local x = math.floor(-110 + ease * 118)
  local y = HEADER_H + 30
  local bob = math.floor(Context.frame / 12) % 2
  rect(x, y + 32, 104, 2, Config.colors.grey)
  Board.draw_player_sprite(1, x, y - bob, 4)
  spr(Config.sprites.bomb, x + 36, y + 2, 0, 4)
  Board.draw_player_sprite(2, x + 72, y - (1 - bob), 4, 1)
end

--- Draws the menu window.
--- @within MenuWindow
function MenuWindow.draw()
  cls(Config.colors.navy)
  Rain.draw(0, HEADER_H, Config.screen.width / 8, (Config.screen.height - HEADER_H) / 8 + 1, 8,
    { head = Config.colors.grey, mid = Config.colors.teal, tail = Config.colors.shadow })
  MenuWindow.draw_header()
  MenuWindow.draw_heroes()
  local ease = 1 - (1 - _anim) * (1 - _anim)
  local x = math.floor(MENU_X + (1 - ease) * 100)
  UI.draw_menu(MENU_ITEMS, Context.menu_item, x, MENU_Y)
  Print.text("TTG", Config.screen.width - 18, Config.screen.height - 10, Config.colors.lime)
end

--- Updates the menu: animation, selection, Select runs the item, Back returns to the title.
--- @within MenuWindow
function MenuWindow.update()
  _anim = math.min(1, _anim + ANIM_SPEED)
  Context.menu_item = UI.update_menu(MENU_ITEMS, Context.menu_item)
  if Input.select() then
    Audio.sfx_confirm()
    MENU_ITEMS[Context.menu_item].action()
  elseif Input.back() then
    Audio.sfx_back()
    Window.set_current("title")
  end
end
