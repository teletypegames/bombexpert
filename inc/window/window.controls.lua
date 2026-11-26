--- @section ControlsWindow
local CONTROLS = {
  {
    action = "Move",
    player1 = "Arrow keys",
    player2 = "W A S D",
  },
  {
    action = "Bomb",
    player1 = "Space / Z",
    player2 = "G",
  },
  {
    action = "Pause",
    player1 = "Backspace / X",
    player2 = "Backspace",
  },
}

--- Draws the key table and the power-ups.
--- @within ControlsWindow
function ControlsWindow.draw()
  local colors = Config.colors
  cls(colors.navy)
  UI.draw_top_bar("Controls")

  local col_action, col_p1, col_p2 = 6, 60, 150
  local y_header = 18
  Print.text("Action", col_action, y_header, colors.light_grey)
  Print.text("Player 1", col_p1, y_header, colors.light_blue)
  Print.text("Player 2", col_p2, y_header, colors.red)
  line(col_action, y_header + 8, Config.screen.width - 6, y_header + 8, colors.dark_grey)

  for i, entry in ipairs(CONTROLS) do
    local y = y_header + 4 + i * 10
    Print.text(entry.action, col_action, y, colors.white)
    Print.text(entry.player1, col_p1, y, colors.cyan)
    Print.text(entry.player2, col_p2, y, colors.cyan)
  end
  print("Gamepads work too: gamepad 1 and gamepad 2.", col_action, 66, colors.light_grey, false, 1, true)

  Print.text("Power-ups", col_action, 80, colors.light_grey)
  line(col_action, 88, Config.screen.width - 6, 88, colors.dark_grey)
  for i, config in ipairs(Powerup.types()) do
    local y = 82 + i * 10
    UI.draw_powerup_icon(config, col_action, y)
    Print.text(config.description, col_action + 12, y, config.color)
  end

  UI.draw_footer("Space / Backspace: back")
end

--- Goes back to the menu.
--- @within ControlsWindow
function ControlsWindow.update()
  if Input.back() or Input.select() then
    Audio.sfx_back()
    Window.set_current("menu")
  end
end
