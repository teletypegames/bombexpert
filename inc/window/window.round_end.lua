--- Between two rounds: who won it and the score.
--- @section RoundEndWindow

--- Starts the timer and the winner jingle.
--- @within RoundEndWindow
function RoundEndWindow.enter()
  Context.win_timer = Config.timing.win_screen_duration
  Audio.jingle("round_win")
end

--- Draws the score: the won rounds of both players as dots.
--- @within RoundEndWindow
--- @param y number Top of the line.
function RoundEndWindow.draw_score(y)
  local colors = Config.colors
  local cx = Config.screen.width / 2
  local p1, p2 = Context.players[1], Context.players[2]
  Print.text(Player.name(p1), cx - 12 - Print.width(Player.name(p1)), y, colors.light_blue)
  Print.text(Player.name(p2), cx + 14, y, colors.red)
  Print.text_center(Context.score[1] .. ":" .. Context.score[2], cx + 1, y, colors.white)
  for i = 1, Config.match.rounds_to_win do
    local dx = (i - (Config.match.rounds_to_win + 1) / 2) * 8
    local dot_y = y + 12
    if i <= Context.score[1] then circ(cx - 40 + dx, dot_y, 2, colors.light_blue) else circb(cx - 40 + dx, dot_y, 2, colors.grey) end
    if i <= Context.score[2] then circ(cx + 40 + dx, dot_y, 2, colors.red) else circb(cx + 40 + dx, dot_y, 2, colors.grey) end
  end
end

--- Draws the board with the round result panel.
--- @within RoundEndWindow
function RoundEndWindow.draw()
  Board.draw()
  local winner = Context.players[Context.round_winner]
  local color = winner.index == 1 and Config.colors.light_blue or Config.colors.red
  UI.draw_panel(20, 30, 200, 80, color)
  Print.text_center(Player.name(winner) .. " WON!", Config.screen.width / 2, 40, color, false, 2)
  RoundEndWindow.draw_score(62)
  if Context.win_timer <= 0 or Util.blink(15) then
    Print.text_center("Press SPACE (A) for round " .. (Context.round + 1), Config.screen.width / 2, 94, Config.colors.white)
  end
end

--- Select starts the next round once the timer is over; Back returns to the menu.
--- @within RoundEndWindow
function RoundEndWindow.update()
  Effects.update()
  if Context.win_timer > 0 then
    Context.win_timer = Context.win_timer - 1
  elseif Input.select() then
    Audio.sfx_confirm()
    Match.next_round()
    Window.set_current("game")
  elseif Input.back() then
    Audio.sfx_back()
    Window.set_current("menu")
  end
end
