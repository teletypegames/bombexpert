--- Global game context: everything that changes while the game runs.
--- @section Context
Context = {}

--- Builds a board filled with empty tiles.
--- @within Context
--- @return table rows of tile types, indexed [row][col].
function Context.empty_map()
  local map = {}
  for row = 1, Config.board.height do
    map[row] = {}
    for col = 1, Config.board.width do
      map[row][col] = Config.tiles.empty
    end
  end
  return map
end

--- Returns the initial context.
--- @within Context
--- @return table result The initial context. </br>
--- Fields: </br>
--- * current_window (string) ID of the active window.<br/>
--- * frame (number) Frames since the cartridge started.<br/>
--- * menu_item, settings_item, pause_item, match_end_item (number) Selected item of each menu.<br/>
--- * two_player_mode (boolean) Whether player 2 is human.<br/>
--- * players, bombs, explosions, powerups (table) Entities of the current round.<br/>
--- * map (table) Tile types, [row][col].<br/>
--- * score (table) Rounds won by player 1 and player 2 in this match.<br/>
--- * round (number) The current round of the match.<br/>
--- * phase (string) "ready", "play" or "dying".<br/>
--- * phase_timer (number) Frames left of the phase.<br/>
--- * round_winner, match_winner (number) Index of the winning player.<br/>
--- * win_timer (number) Frames until the round end screen accepts a key.<br/>
function Context.initial_data()
  return {
    current_window = nil,
    frame = 0,
    menu_item = 1,
    settings_item = 1,
    pause_item = 1,
    match_end_item = 1,
    two_player_mode = false,
    players = {},
    bombs = {},
    explosions = {},
    powerups = {},
    map = Context.empty_map(),
    score = {
      0,
      0,
    },
    round = 1,
    phase = "ready",
    phase_timer = 0,
    round_winner = nil,
    match_winner = nil,
    win_timer = 0,
  }
end

--- Resets the context to its initial state.
--- @within Context
function Context.reset()
  for key, value in pairs(Context.initial_data()) do
    Context[key] = value
  end
end
