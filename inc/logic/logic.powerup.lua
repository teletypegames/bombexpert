--- Power-ups hidden under breakable walls.
--- @section Powerup
local POWERUP_TYPES = {
  {
    type = "bomb",
    weight = 50,
    color = Config.colors.yellow,
    label = "B",
    description = "+1 Bomb capacity",
    apply = function(player)
      player.max_bombs = player.max_bombs + 1
    end,
  },
  {
    type = "power",
    weight = 50,
    color = Config.colors.orange,
    label = "P",
    description = "+1 Blast range",
    apply = function(player)
      player.bomb_power = player.bomb_power + 1
    end,
  },
}

--- Returns the power-up types.
--- @within Powerup
--- @return table The types.
function Powerup.types()
  return POWERUP_TYPES
end

--- Returns a power-up type by name (the first one if unknown).
--- @within Powerup
--- @param type_name string The type.
--- @return table The type.
function Powerup.get_config(type_name)
  for _, p in ipairs(POWERUP_TYPES) do
    if p.type == type_name then return p end
  end
  return POWERUP_TYPES[1]
end

--- Picks a power-up type by weight.
--- @within Powerup
--- @return string The type name.
function Powerup.get_random_type()
  local total_weight = 0
  for _, p in ipairs(POWERUP_TYPES) do
    total_weight = total_weight + p.weight
  end
  local roll = math.random() * total_weight
  local cumulative = 0
  for _, p in ipairs(POWERUP_TYPES) do
    cumulative = cumulative + p.weight
    if roll <= cumulative then return p.type end
  end
  return POWERUP_TYPES[1].type
end

--- Hides power-ups under the breakable walls of a new board.
--- @within Powerup
function Powerup.init()
  Context.powerups = {}
  for row = 1, Config.board.height do
    for col = 1, Config.board.width do
      if Map.tile(col, row) == Config.tiles.breakable and math.random() < Config.map.powerup_spawn_chance then
        table.insert(Context.powerups, {
          grid_x = col,
          grid_y = row,
          type = Powerup.get_random_type(),
        })
      end
    end
  end
end

--- Whether a power-up is uncovered.
--- @within Powerup
--- @param powerup table The power-up.
--- @return boolean
function Powerup.is_visible(powerup)
  return Map.tile(powerup.grid_x, powerup.grid_y) == Config.tiles.empty
end

--- Gives uncovered power-ups to the players standing on them.
--- @within Powerup
function Powerup.check_pickup()
  for _, player in ipairs(Context.players) do
    for i = #Context.powerups, 1, -1 do
      local pw = Context.powerups[i]
      if Powerup.is_visible(pw) and player.grid_x == pw.grid_x and player.grid_y == pw.grid_y then
        local config = Powerup.get_config(pw.type)
        config.apply(player)
        table.remove(Context.powerups, i)
        Effects.sparkle(pw.grid_x, pw.grid_y, config.color)
        Audio.sfx_pickup()
      end
    end
  end
end
