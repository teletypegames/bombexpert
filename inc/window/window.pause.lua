--- The pause menu over the frozen round.
--- @section PauseWindow
local PAUSE_ITEMS = {
  {
    label = "Resume",
    action = function() Window.set_current("game") end,
  },
  {
    label = "Restart round",
    action = function()
      Match.start_round()
      Window.set_current("game")
    end,
  },
  {
    label = "Main menu",
    action = function() Window.set_current("menu") end,
  },
}

--- Draws the frozen board with the pause panel.
--- @within PauseWindow
function PauseWindow.draw()
  Board.draw()
  local w, h = 110, 62
  local x = (Config.screen.width - w) / 2
  local y = 38
  UI.draw_panel(x, y, w, h, Config.colors.yellow)
  Print.text_center("PAUSED", Config.screen.width / 2, y + 7, Config.colors.yellow)
  UI.draw_menu(PAUSE_ITEMS, Context.pause_item, x + 26, y + 22)
end

--- Select runs the item, Back resumes.
--- @within PauseWindow
function PauseWindow.update()
  Context.pause_item = UI.update_menu(PAUSE_ITEMS, Context.pause_item)
  if Input.select() then
    Audio.sfx_confirm()
    PAUSE_ITEMS[Context.pause_item].action()
  elseif Input.back() then
    Audio.sfx_back()
    Window.set_current("game")
  end
end
