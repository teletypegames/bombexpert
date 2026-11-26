--- The CPU opponent: avoids blasts, collects power-ups, bombs walls and the player.
--- @section AI
local DIRECTIONS = {
  { 0, -1 },
  { 0, 1 },
  { -1, 0 },
  { 1, 0 },
}

--- Whether a solid wall lies strictly between two positions of a row or column.
--- @within AI
local function is_blast_line_blocked(pos1, pos2, fixed_coord, is_horizontal)
  for i = math.min(pos1, pos2) + 1, math.max(pos1, pos2) - 1 do
    local tile = is_horizontal and Map.tile(i, fixed_coord) or Map.tile(fixed_coord, i)
    if tile == Config.tiles.solid then return true end
  end
  return false
end

--- Whether a cell is on fire, holds a bomb, or is in the blast line of a bomb about to explode.
--- @within AI
--- @param grid_x number Column.
--- @param grid_y number Row.
--- @return boolean
function AI.is_dangerous(grid_x, grid_y)
  for _, expl in ipairs(Context.explosions) do
    if grid_x == expl.grid_x and grid_y == expl.grid_y then return true end
  end

  for _, bomb in ipairs(Context.bombs) do
    local power = bomb.power or 1
    if grid_x == bomb.grid_x and grid_y == bomb.grid_y then return true end
    if bomb.timer < Config.ai.danger_threshold then
      if grid_y == bomb.grid_y and math.abs(grid_x - bomb.grid_x) <= power
        and not is_blast_line_blocked(grid_x, bomb.grid_x, grid_y, true) then
        return true
      end
      if grid_x == bomb.grid_x and math.abs(grid_y - bomb.grid_y) <= power
        and not is_blast_line_blocked(grid_y, bomb.grid_y, grid_x, false) then
        return true
      end
    end
  end

  return false
end

--- Whether a breakable wall is next to a cell.
--- @within AI
--- @param grid_x number Column.
--- @param grid_y number Row.
--- @return boolean
function AI.has_adjacent_breakable_wall(grid_x, grid_y)
  for _, dir in ipairs(DIRECTIONS) do
    local x, y = grid_x + dir[1], grid_y + dir[2]
    if Util.on_board(x, y) and Map.tile(x, y) == Config.tiles.breakable then
      return true
    end
  end
  return false
end

--- Returns the nearest uncovered power-up (Manhattan distance), or nil.
--- @within AI
--- @param grid_x number Column.
--- @param grid_y number Row.
--- @return table|nil The power-up.
function AI.find_nearest_powerup(grid_x, grid_y)
  local nearest, nearest_dist = nil, 9999
  for _, pw in ipairs(Context.powerups) do
    if Powerup.is_visible(pw) then
      local dist = math.abs(pw.grid_x - grid_x) + math.abs(pw.grid_y - grid_y)
      if dist < nearest_dist then
        nearest_dist = dist
        nearest = pw
      end
    end
  end
  return nearest
end

--- Whether a cell is in the row or column of a bomb within its range.
--- @within AI
--- @param cell_x number Column of the cell.
--- @param cell_y number Row of the cell.
--- @param bomb_x number Column of the bomb.
--- @param bomb_y number Row of the bomb.
--- @param power number Blast range.
--- @return boolean
function AI.is_in_blast_line(cell_x, cell_y, bomb_x, bomb_y, power)
  if cell_y == bomb_y and math.abs(cell_x - bomb_x) <= power then return true end
  if cell_x == bomb_x and math.abs(cell_y - bomb_y) <= power then return true end
  return false
end

--- Finds the first step towards a cell out of the blast line of a bomb placed here
--- (directly, or by turning a corner after one step).
--- @within AI
--- @param grid_x number Column.
--- @param grid_y number Row.
--- @param player table The CPU player.
--- @return table|nil {x, y} of the first step.
function AI.find_safe_cell(grid_x, grid_y, player)
  local power = player.bomb_power
  for _, dir in ipairs(DIRECTIONS) do
    local new_x, new_y = grid_x + dir[1], grid_y + dir[2]
    if Map.can_move_to(new_x, new_y, player) and not AI.is_dangerous(new_x, new_y) then
      if not AI.is_in_blast_line(new_x, new_y, grid_x, grid_y, power) then
        return { new_x, new_y }
      end
      for _, dir2 in ipairs(DIRECTIONS) do
        local safe_x, safe_y = new_x + dir2[1], new_y + dir2[2]
        if Map.can_move_to(safe_x, safe_y, player) and not AI.is_dangerous(safe_x, safe_y)
          and not AI.is_in_blast_line(safe_x, safe_y, grid_x, grid_y, power) then
          return { new_x, new_y }
        end
      end
    end
  end
  return nil
end

--- Steps away from the bomb just placed.
--- @within AI
--- @param player table The CPU player.
function AI.escape_from_bomb(player)
  local safe = AI.find_safe_cell(player.grid_x, player.grid_y, player)
  if safe then
    player.grid_x = safe[1]
    player.grid_y = safe[2]
  end
end

--- Moves one cell towards the target (or a closer power-up), placing a bomb when useful.
--- @within AI
--- @param player table The CPU player.
--- @param target table The opponent.
function AI.move_and_bomb(player, target)
  if not target then return end

  local actual_target = target
  local powerup = AI.find_nearest_powerup(player.grid_x, player.grid_y)
  if powerup then
    local pw_dist = math.abs(powerup.grid_x - player.grid_x) + math.abs(powerup.grid_y - player.grid_y)
    local target_dist = math.abs(target.grid_x - player.grid_x) + math.abs(target.grid_y - player.grid_y)
    if pw_dist < target_dist or pw_dist <= 5 then
      actual_target = {
        grid_x = powerup.grid_x,
        grid_y = powerup.grid_y,
      }
    end
  end

  local dx = actual_target.grid_x - player.grid_x
  local dy = actual_target.grid_y - player.grid_y
  local dist = math.abs(dx) + math.abs(dy)

  local should_bomb = (dist <= 2 and actual_target == target) or AI.has_adjacent_breakable_wall(player.grid_x, player.grid_y)
  if should_bomb and player.active_bombs < player.max_bombs and player.bomb_cooldown <= 0
    and AI.find_safe_cell(player.grid_x, player.grid_y, player) then
    player.last_grid_x = player.grid_x
    player.last_grid_y = player.grid_y
    Bomb.place(player)
    player.bomb_cooldown = Config.ai.bomb_cooldown
    AI.escape_from_bomb(player)
    return
  end

  local dirs = {}
  if dx > 0 then table.insert(dirs, { 1, 0 }) elseif dx < 0 then table.insert(dirs, { -1, 0 }) end
  if dy > 0 then table.insert(dirs, { 0, 1 }) elseif dy < 0 then table.insert(dirs, { 0, -1 }) end
  for _, d in ipairs(DIRECTIONS) do
    table.insert(dirs, d)
  end

  local fallback = nil
  for _, dir in ipairs(dirs) do
    local new_x, new_y = player.grid_x + dir[1], player.grid_y + dir[2]
    if Map.can_move_to(new_x, new_y, player) and not AI.is_dangerous(new_x, new_y) then
      if new_x == player.last_grid_x and new_y == player.last_grid_y then
        fallback = fallback or { new_x, new_y }
      else
        player.last_grid_x = player.grid_x
        player.last_grid_y = player.grid_y
        player.grid_x = new_x
        player.grid_y = new_y
        return
      end
    end
  end

  if fallback then
    player.last_grid_x = player.grid_x
    player.last_grid_y = player.grid_y
    player.grid_x = fallback[1]
    player.grid_y = fallback[2]
  end
end

--- One frame of the CPU: flee danger at once, otherwise act every move_delay frames.
--- @within AI
--- @param player table The CPU player.
--- @param target table The opponent.
function AI.update(player, target)
  if player.moving then
    if AI.is_dangerous(player.grid_x, player.grid_y) then
      local current_x = Util.to_grid(player.pixel_x)
      local current_y = Util.to_grid(player.pixel_y)
      if not AI.is_dangerous(current_x, current_y) then
        player.grid_x = current_x
        player.grid_y = current_y
      end
    end
    return
  end

  if AI.is_dangerous(player.grid_x, player.grid_y) then
    local best_dir, best_safe = nil, false
    for _, dir in ipairs(DIRECTIONS) do
      local new_x, new_y = player.grid_x + dir[1], player.grid_y + dir[2]
      if Map.can_move_to(new_x, new_y, player) then
        local safe = not AI.is_dangerous(new_x, new_y)
        if safe and not best_safe then
          best_dir = dir
          best_safe = true
        elseif not best_dir then
          best_dir = dir
        end
      end
    end
    if best_dir then
      player.grid_x = player.grid_x + best_dir[1]
      player.grid_y = player.grid_y + best_dir[2]
    end
    player.move_timer = 0
    return
  end

  player.move_timer = player.move_timer + 1
  if player.move_timer < Config.ai.move_delay then return end
  player.move_timer = 0
  AI.move_and_bomb(player, target)
end
