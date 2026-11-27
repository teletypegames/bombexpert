--- The CPU opponent. It plans on the grid with the timing of every blast in mind:
--- danger windows tell when each cell burns, a breadth-first search finds the safe
--- routes, and a bomb is placed only if a safe cell can still be reached after it.
--- Priorities: flee when the cell will burn; bomb where the opponent has no way out, or walk
--- to such a cell; bomb the opponent in the blast; pick up a near power-up; walk to a cell
--- from where the blast reaches the opponent; dig through the walls towards the opponent.
--- @section AI
local DIRECTIONS = {
  { 0, -1 },
  { 0, 1 },
  { -1, 0 },
  { 1, 0 },
}
local SAFETY_MARGIN = 4
local BREAKABLE_COST = 8
local BOMB_COST = 3
local POWERUP_REACH = 8
local TRAP_CANDIDATES = 40

--- Key of a cell in the per-cell tables.
--- @within AI
local function cell_key(x, y)
  return y * 64 + x
end

--- Frames a player needs to walk one cell.
--- @within AI
local function frames_per_step()
  return math.ceil(Config.board.tile_size / Config.player.move_speed)
end

--- Returns the cells a bomb's blast reaches, as {x, y, distance}; solid walls stop it,
--- a breakable wall is reached and stops it.
--- @within AI
--- @param grid_x number Column of the bomb.
--- @param grid_y number Row of the bomb.
--- @param power number Blast range.
--- @return table The cells.
function AI.blast_cells(grid_x, grid_y, power)
  local cells = { { grid_x, grid_y, 0 } }
  for _, dir in ipairs(DIRECTIONS) do
    for dist = 1, power do
      local x, y = grid_x + dir[1] * dist, grid_y + dir[2] * dist
      if not Util.on_board(x, y) then break end
      local tile = Map.tile(x, y)
      if tile == Config.tiles.solid then break end
      table.insert(cells, { x, y, dist })
      if tile == Config.tiles.breakable then break end
    end
  end
  return cells
end

--- Whether a bomb at a cell would reach a target cell.
--- @within AI
--- @param grid_x number Column of the bomb.
--- @param grid_y number Row of the bomb.
--- @param power number Blast range.
--- @param target_x number Column of the target.
--- @param target_y number Row of the target.
--- @return boolean
function AI.blast_reaches(grid_x, grid_y, power, target_x, target_y)
  if grid_x ~= target_x and grid_y ~= target_y then return false end
  for _, cell in ipairs(AI.blast_cells(grid_x, grid_y, power)) do
    if cell[1] == target_x and cell[2] == target_y then return true end
  end
  return false
end

--- Returns when each cell burns, from now in frames, as {from, to} per cell key:
--- the ticking bombs (plus an optional planned one) and the flames already spreading.
--- @within AI
--- @param[opt] planned table A bomb being considered: grid_x, grid_y, timer, power.
--- @return table The danger windows.
function AI.danger_windows(planned)
  local windows = {}
  local function add(x, y, from, to)
    local k = cell_key(x, y)
    local w = windows[k]
    if w then
      w.from = math.min(w.from, from)
      w.to = math.max(w.to, to)
    else
      windows[k] = {
        from = from,
        to = to,
      }
    end
  end

  local bombs = { planned }
  for _, bomb in ipairs(Context.bombs) do
    table.insert(bombs, bomb)
  end
  local spread, duration = Config.bomb.spread_delay, Config.bomb.explosion_duration
  for _, bomb in ipairs(bombs) do
    for _, cell in ipairs(AI.blast_cells(bomb.grid_x, bomb.grid_y, bomb.power or 1)) do
      local start = bomb.timer + cell[3] * spread
      add(cell[1], cell[2], start - SAFETY_MARGIN, start + duration + SAFETY_MARGIN)
    end
  end
  for _, expl in ipairs(Context.explosions) do
    add(expl.grid_x, expl.grid_y, expl.spread - SAFETY_MARGIN, expl.spread + expl.timer + SAFETY_MARGIN)
  end
  return windows
end

--- Breadth-first search over the walkable cells from the player.
--- Timed: a cell may be entered when it does not burn while the player is on it.
--- Untimed: cells that will burn at all are avoided. blocked_key: a planned bomb's cell.
--- @within AI
--- @return table nodes by cell key, table the nodes in order of distance.
local function search(player, windows, timed, blocked_key)
  local fps = frames_per_step()
  local start = {
    x = player.grid_x,
    y = player.grid_y,
    steps = 0,
  }
  local nodes = { [cell_key(start.x, start.y)] = start }
  local order = { start }
  local head = 1
  while head <= #order do
    local node = order[head]
    head = head + 1
    for _, dir in ipairs(DIRECTIONS) do
      local x, y = node.x + dir[1], node.y + dir[2]
      local k = cell_key(x, y)
      if not nodes[k] and k ~= blocked_key and Map.can_move_to(x, y, player) then
        local steps = node.steps + 1
        local w = windows[k]
        local enterable = w == nil
        if timed and w then
          enterable = (steps + 1) * fps < w.from or (steps - 1) * fps > w.to
        end
        if enterable then
          local next_node = {
            x = x,
            y = y,
            steps = steps,
            parent = node,
          }
          nodes[k] = next_node
          table.insert(order, next_node)
        end
      end
    end
  end
  return nodes, order
end

--- Returns the nearest node matching a predicate (order is sorted by distance).
--- @within AI
local function nearest(order, predicate)
  for _, node in ipairs(order) do
    if predicate(node) then return node end
  end
  return nil
end

--- Moves the player one cell along the path to a node.
--- @within AI
local function step_to(player, node)
  while node.parent and node.parent.steps > 0 do
    node = node.parent
  end
  if node.steps > 0 then
    player.grid_x = node.x
    player.grid_y = node.y
  end
end

--- Returns the nearest cell that never burns and can be reached in time, or nil.
--- @within AI
local function find_escape(player, windows, blocked_key)
  local _, order = search(player, windows, true, blocked_key)
  return nearest(order, function(node) return windows[cell_key(node.x, node.y)] == nil end)
end

--- Danger windows with a bomb of the player planned at a cell.
--- @within AI
local function windows_with_bomb(player, x, y)
  return AI.danger_windows({
    grid_x = x,
    grid_y = y,
    timer = Config.bomb.timer,
    power = player.bomb_power,
  })
end

--- Whether the player could still reach a safe cell after placing a bomb here.
--- @within AI
local function can_escape_after_bomb(player)
  return find_escape(player, windows_with_bomb(player, player.grid_x, player.grid_y)) ~= nil
end

--- Whether a bomb of the player at a cell would leave the target no way out.
--- @within AI
local function traps(player, x, y, target)
  if not AI.blast_reaches(x, y, player.bomb_power, target.grid_x, target.grid_y) then return false end
  local key = cell_key(x, y)
  local blocked = (target.grid_x ~= x or target.grid_y ~= y) and key or nil
  return find_escape(target, windows_with_bomb(player, x, y), blocked) == nil
end

--- Places a bomb if one is left, the cooldown is over and there is a way out.
--- @within AI
--- @return boolean Whether a bomb was placed.
local function try_bomb(player)
  if player.active_bombs >= player.max_bombs or player.bomb_cooldown > 0 then return false end
  if not can_escape_after_bomb(player) then return false end
  Bomb.place(player)
  player.bomb_cooldown = Config.ai.bomb_cooldown
  return true
end

--- Leaves a cell that will burn: to the nearest safe cell, or else where the fire comes latest.
--- @within AI
local function flee(player, windows)
  local escape = find_escape(player, windows)
  if escape then
    step_to(player, escape)
    return
  end
  local _, order = search(player, windows, true)
  local best, best_time = nil, -math.huge
  for _, node in ipairs(order) do
    local w = windows[cell_key(node.x, node.y)]
    local time = w and w.from or math.huge
    if node.steps > 0 and time > best_time then
      best, best_time = node, time
    end
  end
  if best then step_to(player, best) end
end

--- Finds where to stand to bomb the first breakable wall on the cheapest way to the target,
--- or nil if the way is open. The way is planned on the board as it is: a wall costs about as
--- much as the walk it saves, a ticking bomb a little (it will be gone), fire nothing.
--- @within AI
local function dig_position(player, target)
  local start_key = cell_key(player.grid_x, player.grid_y)
  local target_key = cell_key(target.grid_x, target.grid_y)
  local dist = { [start_key] = 0 }
  local cells = { [start_key] = { player.grid_x, player.grid_y } }
  local prev, done = {}, {}
  local buckets = { [0] = { start_key } }
  local current, max_bucket = 0, 0
  local found = false
  while current <= max_bucket do
    local bucket = buckets[current]
    local best_key = bucket and table.remove(bucket)
    if not best_key then
      current = current + 1
    elseif not done[best_key] and dist[best_key] == current then
      if best_key == target_key then
        found = true
        break
      end
      done[best_key] = true
      local best = current
      local cx, cy = cells[best_key][1], cells[best_key][2]
      for _, dir in ipairs(DIRECTIONS) do
        local x, y = cx + dir[1], cy + dir[2]
        local k = cell_key(x, y)
        if Util.on_board(x, y) and not done[k] then
          local tile = Map.tile(x, y)
          local cost = nil
          if tile == Config.tiles.breakable then
            cost = BREAKABLE_COST
          elseif tile == Config.tiles.empty then
            cost = Map.can_move_to(x, y, player) and 1 or BOMB_COST
          end
          if cost and (dist[k] == nil or best + cost < dist[k]) then
            dist[k] = best + cost
            prev[k] = best_key
            cells[k] = { x, y }
            buckets[dist[k]] = buckets[dist[k]] or {}
            table.insert(buckets[dist[k]], k)
            max_bucket = math.max(max_bucket, dist[k])
          end
        end
      end
    end
  end
  if not found then return nil end

  local path = {}
  local k = target_key
  while k do
    table.insert(path, 1, cells[k])
    k = prev[k]
  end
  for i = 2, #path do
    if Map.tile(path[i][1], path[i][2]) == Config.tiles.breakable then
      return {
        x = path[i - 1][1],
        y = path[i - 1][2],
      }
    end
  end
  return nil
end

--- Chooses and starts the next move when the player is safe.
--- @within AI
local function act(player, target, windows)
  local nodes, order = search(player, windows, false)
  local power = player.bomb_power
  local has_bomb = player.active_bombs < player.max_bombs and player.bomb_cooldown <= 0
  local hunting = target and not target.dead

  if hunting and has_bomb and traps(player, player.grid_x, player.grid_y, target) and try_bomb(player) then
    return
  end
  local trap_node = nil
  if hunting and has_bomb then
    for i = 2, math.min(#order, TRAP_CANDIDATES) do
      if traps(player, order[i].x, order[i].y, target) then
        trap_node = order[i]
        break
      end
    end
  end
  if trap_node then
    step_to(player, trap_node)
    return
  end
  if hunting and AI.blast_reaches(player.grid_x, player.grid_y, power, target.grid_x, target.grid_y) then
    if try_bomb(player) or not has_bomb then return end
  end

  local powerup_node = nearest(order, function(node)
    for _, pw in ipairs(Context.powerups) do
      if pw.grid_x == node.x and pw.grid_y == node.y and Powerup.is_visible(pw) then return true end
    end
    return false
  end)
  local attack_node = hunting and nearest(order, function(node)
    return node.steps > 0 and AI.blast_reaches(node.x, node.y, power, target.grid_x, target.grid_y)
  end)
  if powerup_node and powerup_node.steps > 0 and powerup_node.steps <= POWERUP_REACH
    and (not attack_node or powerup_node.steps <= attack_node.steps + 3) then
    step_to(player, powerup_node)
    return
  end
  if attack_node then
    step_to(player, attack_node)
    return
  end

  if hunting then
    local stand = dig_position(player, target)
    if stand then
      if stand.x == player.grid_x and stand.y == player.grid_y then
        try_bomb(player)
      else
        local node = nodes[cell_key(stand.x, stand.y)]
        if node then step_to(player, node) end
      end
      return
    end
  end

  local wall_node = nearest(order, function(node) return AI.has_adjacent_breakable_wall(node.x, node.y) end)
  if wall_node then
    if wall_node.steps == 0 then
      try_bomb(player)
    else
      step_to(player, wall_node)
    end
  end
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

--- One frame of the CPU. Between two cells it only walks; on a cell it flees at once
--- if the cell will burn, otherwise it thinks after a short pause (Config.ai.move_delay / 10 frames).
--- @within AI
--- @param player table The CPU player.
--- @param target table The opponent.
function AI.update(player, target)
  if player.moving then return end
  local windows = AI.danger_windows()
  if windows[cell_key(player.grid_x, player.grid_y)] then
    player.move_timer = 0
    flee(player, windows)
    return
  end
  player.move_timer = player.move_timer + 1
  if player.move_timer < math.floor(Config.ai.move_delay / 10) then return end
  player.move_timer = 0
  act(player, target, windows)
end
