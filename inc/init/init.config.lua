--- @section Config
Config = {}

--- Returns the default configuration.
--- The player, bomb, ai, map, match and audio groups are changed by the Settings window
--- and kept in persistent memory (see Settings).
--- @within Config
--- @return table The default configuration groups.
function Config.initial_data()
  return {
    screen = {
      width = 240,
      height = 136,
    },
    -- a phosphor-green palette (meta.assets PALETTE); the names keep the hue of each slot
    colors = {
      black = 0,
      shadow = 1,
      red = 2,
      orange = 3,
      yellow = 4,
      lime = 5,
      green = 6,
      teal = 7,
      navy = 8,
      blue = 9,
      light_blue = 10,
      cyan = 11,
      white = 12,
      light_grey = 13,
      grey = 14,
      dark_grey = 15,
    },
    board = {
      tile_size = 8,
      width = 27,
      height = 15,
      offset_x = 12,
      offset_y = 14,
    },
    tiles = {
      empty = 0,
      solid = 1,
      breakable = 2,
    },
    sprites = {
      player_blue = 256,
      player_red = 257,
      bomb = 258,
      breakable_wall = 259,
      solid_wall = 260,
    },
    player = {
      move_speed = 2,
      start_bombs = 1,
      start_power = 1,
    },
    bomb = {
      timer = 90,
      explosion_duration = 30,
      spread_delay = 6,
    },
    ai = {
      move_delay = 20,
      bomb_cooldown = 90,
      danger_threshold = 30,
    },
    map = {
      breakable_wall_chance = 0.7,
      powerup_spawn_chance = 0.3,
      generator = "classic",
    },
    match = {
      rounds_to_win = 3,
    },
    audio = {
      music = "on",
    },
    timing = {
      intro_duration = 150,
      ready_duration = 50,
      go_duration = 30,
      death_duration = 60,
      win_screen_duration = 60,
    },
  }
end

--- Restores the default configuration.
--- @within Config
function Config.reset()
  for key, value in pairs(Config.initial_data()) do
    Config[key] = value
  end
end

Config.reset()
