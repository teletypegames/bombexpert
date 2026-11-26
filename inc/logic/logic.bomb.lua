--- Bombs and their explosions.
--- @section Bomb
local SPREAD_DIRS = { -1, 1 }

--- Places a bomb under a player if the player has one left and the cell is free.
--- @within Bomb
--- @param player table The player.
function Bomb.place(player)
  if player.active_bombs >= player.max_bombs then return end
  for _, b in ipairs(Context.bombs) do
    if b.grid_x == player.grid_x and b.grid_y == player.grid_y then return end
  end
  table.insert(Context.bombs, {
    grid_x = player.grid_x,
    grid_y = player.grid_y,
    timer = Config.bomb.timer,
    owner = player,
    power = player.bomb_power,
  })
  player.active_bombs = player.active_bombs + 1
  Audio.sfx_place()
end

--- Adds one explosion cell.
--- @within Bomb
local function add_explosion(grid_x, grid_y, dist)
  table.insert(Context.explosions, {
    grid_x = grid_x,
    grid_y = grid_y,
    timer = Config.bomb.explosion_duration,
    dist = dist,
    spread = dist * Config.bomb.spread_delay,
  })
end

--- Spreads the blast along one axis; solid walls stop it, breakable walls stop it after breaking.
--- @within Bomb
local function spread_explosion(grid_x, grid_y, power, is_horizontal)
  for _, dir in ipairs(SPREAD_DIRS) do
    for dist = 1, power do
      local cell_x, cell_y = grid_x, grid_y
      if is_horizontal then
        cell_x = grid_x + dir * dist
      else
        cell_y = grid_y + dir * dist
      end
      if not Util.on_board(cell_x, cell_y) then break end

      local tile = Map.tile(cell_x, cell_y)
      if tile == Config.tiles.solid then break end

      local is_breakable = tile == Config.tiles.breakable
      if is_breakable then Map.destroy(cell_x, cell_y) end
      add_explosion(cell_x, cell_y, dist)
      if is_breakable then break end
    end
  end
end

--- Explodes a bomb at a cell.
--- @within Bomb
--- @param grid_x number Column.
--- @param grid_y number Row.
--- @param[opt] power number Blast range; 1 by default.
function Bomb.explode(grid_x, grid_y, power)
  power = power or 1
  Audio.sfx_explosion()
  Effects.shake(6 + power * 2)
  add_explosion(grid_x, grid_y, 0)
  spread_explosion(grid_x, grid_y, power, true)
  spread_explosion(grid_x, grid_y, power, false)
end

--- Counts down the bombs and the explosions.
--- @within Bomb
function Bomb.update_all()
  for i = #Context.bombs, 1, -1 do
    local bomb = Context.bombs[i]
    bomb.timer = bomb.timer - 1
    if bomb.timer <= 0 then
      Bomb.explode(bomb.grid_x, bomb.grid_y, bomb.power)
      if bomb.owner then
        bomb.owner.active_bombs = bomb.owner.active_bombs - 1
      end
      table.remove(Context.bombs, i)
    end
  end

  for i = #Context.explosions, 1, -1 do
    local expl = Context.explosions[i]
    if expl.spread > 0 then
      expl.spread = expl.spread - 1
    else
      expl.timer = expl.timer - 1
      if expl.timer <= 0 then
        table.remove(Context.explosions, i)
      end
    end
  end
end

--- Removes every bomb and explosion.
--- @within Bomb
function Bomb.clear_all()
  Context.bombs = {}
  Context.explosions = {}
end
