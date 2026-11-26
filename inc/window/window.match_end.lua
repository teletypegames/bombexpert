--- The end of a match: the champion, confetti, rematch or menu.
--- @section MatchEndWindow
local NUM_CONFETTI = 60
local _confetti = {}

local MATCH_END_ITEMS = {
  {
    label = "Rematch",
    action = function()
      Match.start(Context.two_player_mode)
      Window.set_current("game")
    end,
  },
  {
    label = "Main menu",
    action = function() Window.set_current("menu") end,
  },
}

--- Starts the confetti and the fanfare.
--- @within MatchEndWindow
function MatchEndWindow.enter()
  Context.match_end_item = 1
  Context.win_timer = Config.timing.win_screen_duration
  local colors = { 2, 3, 4, 5, 10, 11, 12 }
  _confetti = {}
  for i = 1, NUM_CONFETTI do
    _confetti[i] = {
      x = math.random(0, Config.screen.width - 1),
      y = math.random(-Config.screen.height, 0),
      speed = 0.4 + math.random() * 0.8,
      sway = math.random() * 6,
      color = colors[math.random(#colors)],
    }
  end
  Audio.music_stop()
  Audio.jingle("match_win")
end

--- Draws the champion, the final score and the choices.
--- @within MatchEndWindow
function MatchEndWindow.draw()
  local colors = Config.colors
  cls(colors.navy)
  for _, c in ipairs(_confetti) do
    local x = math.floor(c.x + math.sin(Context.frame * 0.05 + c.sway) * 3)
    rect(x, math.floor(c.y), 2, 1, c.color)
  end

  local winner = Context.players[Context.match_winner]
  local color = winner.index == 1 and colors.light_blue or colors.red
  local jump = math.floor(math.abs(math.sin(Context.frame * 0.1)) * 6)
  Board.draw_player_sprite(winner.index, Config.screen.width / 2 - 16, 18 - jump, 4)

  Print.text_center_contour(Player.name(winner), Config.screen.width / 2, 52, color, false, 2)
  Print.text_center_contour("WINS THE MATCH!", Config.screen.width / 2, 68, colors.yellow, false, 1)
  RoundEndWindow.draw_score(80)

  if Context.win_timer <= 0 then
    UI.draw_menu(MATCH_END_ITEMS, Context.match_end_item, Config.screen.width / 2, 106, true)
  end
end

--- Moves the confetti; after the timer Select runs the choice.
--- @within MatchEndWindow
function MatchEndWindow.update()
  for _, c in ipairs(_confetti) do
    c.y = c.y + c.speed
    if c.y > Config.screen.height then c.y = -2 end
  end
  if Context.win_timer > 0 then
    Context.win_timer = Context.win_timer - 1
    return
  end
  Context.match_end_item = UI.update_menu(MATCH_END_ITEMS, Context.match_end_item)
  if Input.select() then
    Audio.sfx_confirm()
    MATCH_END_ITEMS[Context.match_end_item].action()
  end
end
