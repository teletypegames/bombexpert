--- A match: rounds until a player has won Config.match.rounds_to_win of them.
--- A round goes through the phases "ready" (countdown), "play" and "dying" (the loser's death).
--- @section Match

--- Starts a new match.
--- @within Match
--- @param two_player_mode boolean Whether player 2 is human.
function Match.start(two_player_mode)
  local width, height = Config.board.width, Config.board.height
  Context.two_player_mode = two_player_mode
  Context.score = {
    0,
    0,
  }
  Context.round = 1
  Context.match_winner = nil
  Context.players = {
    Player.create(1, 2, 2, false),
    Player.create(2, width - 1, height - 1, not two_player_mode),
  }
  Match.start_round()
end

--- Starts the current round on a new board.
--- @within Match
function Match.start_round()
  Context.round_winner = nil
  Bomb.clear_all()
  Effects.clear()
  Map.generate()
  for _, player in ipairs(Context.players) do
    Player.reset(player)
  end
  Powerup.init()
  Context.phase = "ready"
  Context.phase_timer = Config.timing.ready_duration + Config.timing.go_duration
  Audio.jingle("ready")
end

--- Starts the next round.
--- @within Match
function Match.next_round()
  Context.round = Context.round + 1
  Match.start_round()
end

--- Returns the first player standing in a burning explosion cell, or nil.
--- @within Match
--- @return table|nil The player.
function Match.find_burnt_player()
  for _, player in ipairs(Context.players) do
    for _, expl in ipairs(Context.explosions) do
      if expl.spread <= 0 and player.grid_x == expl.grid_x and player.grid_y == expl.grid_y then
        return player
      end
    end
  end
  return nil
end

--- Moves every player: the CPU hunts the other player, humans read their controls.
--- @within Match
local function update_players()
  for _, player in ipairs(Context.players) do
    Player.update_movement(player)
    if player.is_ai then
      AI.update(player, Context.players[player.index == 1 and 2 or 1])
    else
      Player.handle_input(player, Input.player(player.index))
    end
  end
end

--- Kills a player: the other one wins the round once the death animation ends.
--- @within Match
--- @param player table The burnt player.
local function kill(player)
  player.dead = true
  Context.round_winner = player.index == 1 and 2 or 1
  Context.phase = "dying"
  Context.phase_timer = Config.timing.death_duration
  local half = Config.board.tile_size / 2
  Effects.burst(player.pixel_x + half, player.pixel_y + half,
    { Config.colors.white, Config.colors.yellow, Config.colors.red }, 16, 2, 0.1)
  Effects.shake(16)
  Audio.music_stop()
  Audio.jingle("death")
end

--- Counts the round for its winner and opens the round or match end screen.
--- @within Match
local function finish_round()
  local winner = Context.round_winner
  Context.score[winner] = Context.score[winner] + 1
  if Context.score[winner] >= Config.match.rounds_to_win then
    Context.match_winner = winner
    Window.set_current("match_end")
  else
    Window.set_current("round_end")
  end
end

--- One frame of the round.
--- @within Match
function Match.update()
  if Context.phase == "ready" then
    Context.phase_timer = Context.phase_timer - 1
    if Context.phase_timer == Config.timing.go_duration then
      Audio.jingle("go")
    elseif Context.phase_timer <= 0 then
      Context.phase = "play"
    end
    return
  end

  if Context.phase == "dying" then
    Bomb.update_all()
    Context.phase_timer = Context.phase_timer - 1
    if Context.phase_timer <= 0 then finish_round() end
    return
  end

  update_players()
  Bomb.update_all()
  Powerup.check_pickup()
  local burnt = Match.find_burnt_player()
  if burnt then kill(burnt) end
end
