--- The board: generation and walkability.
--- @section Map
local MapGenerators = {}

--- Classic grid: solid pillars on every odd cell, breakable walls elsewhere.
--- @within Map
--- @param row number Row.
--- @param col number Column.
--- @return number The tile.
local function classic(row, col)
  if row % 2 == 1 and col % 2 == 1 and row > 1 and col > 1 then
    return Config.tiles.solid
  elseif math.random() < Config.map.breakable_wall_chance then
    return Config.tiles.breakable
  end
  return Config.tiles.empty
end

MapGenerators.classic = classic

--- Open arena: pillars on every 4th cell, half as many breakable walls.
--- @within Map
--- @param row number Row.
--- @param col number Column.
--- @return number The tile.
function MapGenerators.arena(row, col)
  if row % 4 == 1 and col % 4 == 1 and row > 1 and col > 1 then
    return Config.tiles.solid
  elseif math.random() < Config.map.breakable_wall_chance * 0.5 then
    return Config.tiles.breakable
  end
  return Config.tiles.empty
end

--- Dense maze: the classic grid with 85% breakable walls.
--- @within Map
--- @param row number Row.
--- @param col number Column.
--- @return number The tile.
function MapGenerators.maze(row, col)
  if row % 2 == 1 and col % 2 == 1 and row > 1 and col > 1 then
    return Config.tiles.solid
  elseif math.random() < 0.85 then
    return Config.tiles.breakable
  end
  return Config.tiles.empty
end

--- Corridors: mostly open rows 4, 8, 12 and columns 7, 14, 21 over the classic grid.
--- @within Map
--- @param row number Row.
--- @param col number Column.
--- @return number The tile.
function MapGenerators.corridors(row, col)
  if (row == 4 or row == 8 or row == 12) and col > 1 and col < Config.board.width then
    if math.random() < 0.3 then return Config.tiles.breakable end
    return Config.tiles.empty
  end
  if (col == 7 or col == 14 or col == 21) and row > 1 and row < Config.board.height then
    if math.random() < 0.3 then return Config.tiles.breakable end
    return Config.tiles.empty
  end
  return classic(row, col)
end

--- Returns the tile type of a cell.
--- @within Map
--- @param grid_x number Column.
--- @param grid_y number Row.
--- @return number The tile type.
function Map.tile(grid_x, grid_y)
  return Context.map[grid_y][grid_x]
end

--- Whether a player can step onto a cell: on the board, no wall, no bomb
--- (except the bomb the player is standing on).
--- @within Map
--- @param grid_x number Column.
--- @param grid_y number Row.
--- @param[opt] player table The moving player.
--- @return boolean
function Map.can_move_to(grid_x, grid_y, player)
  if not Util.on_board(grid_x, grid_y) then return false end
  if Map.tile(grid_x, grid_y) >= Config.tiles.solid then return false end
  for _, bomb in ipairs(Context.bombs) do
    if grid_x == bomb.grid_x and grid_y == bomb.grid_y then
      return player ~= nil and player.grid_x == bomb.grid_x and player.grid_y == bomb.grid_y
    end
  end
  return true
end

--- Whether a cell is a corner spawn point or next to one (always kept empty).
--- @within Map
--- @param row number Row.
--- @param col number Column.
--- @return boolean
function Map.is_spawn_area(row, col)
  local last_col = Config.board.width - 1
  local last_row = Config.board.height - 1
  for _, corner in ipairs({ { 2, 2, 1, 1 }, { 2, last_col, 1, -1 }, { last_row, 2, -1, 1 }, { last_row, last_col, -1, -1 } }) do
    local r, c, dr, dc = corner[1], corner[2], corner[3], corner[4]
    if (row == r and col == c) or (row == r and col == c + dc) or (row == r + dr and col == c) then
      return true
    end
  end
  return false
end

--- Generates a new board: solid border, empty spawns, the rest from the chosen generator.
--- @within Map
--- @param[opt] generator_name string Generator; Config.map.generator by default.
function Map.generate(generator_name)
  local generator = MapGenerators[generator_name or Config.map.generator] or MapGenerators.classic
  local width, height = Config.board.width, Config.board.height
  for row = 1, height do
    for col = 1, width do
      if row == 1 or row == height or col == 1 or col == width then
        Context.map[row][col] = Config.tiles.solid
      elseif Map.is_spawn_area(row, col) then
        Context.map[row][col] = Config.tiles.empty
      else
        Context.map[row][col] = generator(row, col)
      end
    end
  end
end

--- Destroys a breakable wall.
--- @within Map
--- @param grid_x number Column.
--- @param grid_y number Row.
function Map.destroy(grid_x, grid_y)
  Context.map[grid_y][grid_x] = Config.tiles.empty
  Effects.debris(grid_x, grid_y)
end
