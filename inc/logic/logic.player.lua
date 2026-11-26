--- The players: grid position, smooth movement, bombs and power.
--- @section Player

--- Creates a player at a spawn cell.
--- @within Player
--- @param index number 1 (blue) or 2 (red).<br/>
--- @param grid_x number Spawn column.<br/>
--- @param grid_y number Spawn row.<br/>
--- @param is_ai boolean Whether the CPU controls it.<br/>
--- @return table The player.
function Player.create(index, grid_x, grid_y, is_ai)
  local player = {
    index = index,
    is_ai = is_ai,
    spawn_x = grid_x,
    spawn_y = grid_y,
  }
  Player.reset(player)
  return player
end

--- Puts a player back on its spawn with the starting bombs and power.
--- @within Player
--- @param player table The player.
function Player.reset(player)
  player.grid_x = player.spawn_x
  player.grid_y = player.spawn_y
  player.last_grid_x = player.spawn_x
  player.last_grid_y = player.spawn_y
  player.pixel_x = Util.to_pixel(player.spawn_x)
  player.pixel_y = Util.to_pixel(player.spawn_y)
  player.moving = false
  player.facing = player.index == 1 and 1 or -1
  player.max_bombs = Config.player.start_bombs
  player.active_bombs = 0
  player.bomb_power = Config.player.start_power
  player.move_timer = 0
  player.bomb_cooldown = 0
  player.dead = false
end

--- Returns the name shown for a player.
--- @within Player
--- @param player table The player.
--- @return string "PLAYER 1", "PLAYER 2" or "CPU".
function Player.name(player)
  if player.is_ai then return "CPU" end
  return "PLAYER " .. player.index
end

--- Slides the player's pixel position towards its grid cell; counts down the bomb cooldown.
--- @within Player
--- @param player table The player.
function Player.update_movement(player)
  local target_x = Util.to_pixel(player.grid_x)
  local target_y = Util.to_pixel(player.grid_y)
  local speed = Config.player.move_speed

  player.moving = true
  if player.pixel_x < target_x then
    player.pixel_x = math.min(player.pixel_x + speed, target_x)
    player.facing = 1
  elseif player.pixel_x > target_x then
    player.pixel_x = math.max(player.pixel_x - speed, target_x)
    player.facing = -1
  elseif player.pixel_y < target_y then
    player.pixel_y = math.min(player.pixel_y + speed, target_y)
  elseif player.pixel_y > target_y then
    player.pixel_y = math.max(player.pixel_y - speed, target_y)
  else
    player.moving = false
  end

  if player.bomb_cooldown > 0 then
    player.bomb_cooldown = player.bomb_cooldown - 1
  end
end

--- Reads a human player's controls: one cell per move, a bomb on its key.
--- @within Player
--- @param player table The player.
--- @param controls table The player's controls (see Input.player).
function Player.handle_input(player, controls)
  if player.moving then return end

  local new_x, new_y = player.grid_x, player.grid_y
  if controls.up() then
    new_y = player.grid_y - 1
  elseif controls.down() then
    new_y = player.grid_y + 1
  elseif controls.left() then
    new_x = player.grid_x - 1
  elseif controls.right() then
    new_x = player.grid_x + 1
  end

  if Map.can_move_to(new_x, new_y, player) then
    player.grid_x = new_x
    player.grid_y = new_y
  end

  if controls.bomb() then
    Bomb.place(player)
  end
end
