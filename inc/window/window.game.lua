--- The round being played.
--- @section GameWindow

--- Starts the game music (it keeps playing when coming back from the pause).
--- @within GameWindow
function GameWindow.enter()
  if Context.phase ~= "dying" then
    Audio.music_play("game")
  end
end

--- Draws the READY / GO countdown over the board.
--- @within GameWindow
function GameWindow.draw_countdown()
  if Context.phase ~= "ready" then return end
  local cx = Config.screen.width / 2
  if Context.phase_timer > Config.timing.go_duration then
    Print.text_center_contour("ROUND " .. Context.round, cx, 50, Config.colors.white, false, 1)
    Print.text_center_contour("READY", cx, 62, Config.colors.yellow, false, 3)
  else
    Print.text_center_contour("GO!", cx, 58, Config.colors.lime, false, 4)
  end
end

--- Draws the board and the countdown.
--- @within GameWindow
function GameWindow.draw()
  Board.draw()
  GameWindow.draw_countdown()
end

--- Runs the round; Back opens the pause menu.
--- @within GameWindow
function GameWindow.update()
  if Input.pause() and Context.phase ~= "dying" then
    Audio.sfx_back()
    Context.pause_item = 1
    Window.set_current("pause")
    return
  end
  Match.update()
  Effects.update()
end
