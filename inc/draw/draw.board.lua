--- Drawing the round: board, explosions, power-ups, bombs, players, particles and the top bar.
--- @section Board
local PALETTE_MAP = 0x3FF0 * 2

--- Screen position of a board pixel coordinate.
--- @within Board
local function screen_x(pixel) return pixel + Config.board.offset_x end
local function screen_y(pixel) return pixel + Config.board.offset_y end

--- Draws the drop shadows of the walls.
--- @within Board
function Board.draw_shadows()
  local size = Config.board.tile_size
  for row = 1, Config.board.height do
    for col = 1, Config.board.width do
      if Map.tile(col, row) ~= Config.tiles.empty then
        rect(screen_x(Util.to_pixel(col)) + 1, screen_y(Util.to_pixel(row)) + 1, size, size, Config.colors.shadow)
      end
    end
  end
end

--- Draws the walls.
--- @within Board
function Board.draw_tiles()
  for row = 1, Config.board.height do
    for col = 1, Config.board.width do
      local tile = Map.tile(col, row)
      local x, y = screen_x(Util.to_pixel(col)), screen_y(Util.to_pixel(row))
      if tile == Config.tiles.solid then
        spr(Config.sprites.solid_wall, x, y, 0)
      elseif tile == Config.tiles.breakable then
        spr(Config.sprites.breakable_wall, x, y, 0)
      end
    end
  end
end

--- Draws a flame cell: green edge, neon body, flickering pale core.
--- @within Board
local function draw_flame(x, y, size, seed)
  local colors = Config.colors
  local inset = math.floor((Config.board.tile_size - size) / 2)
  rect(x + inset, y + inset, size, size, colors.grey)
  if size > 2 then
    rect(x + inset + 1, y + inset + 1, size - 2, size - 2, colors.lime)
  end
  if size > 4 then
    local core = (Context.frame + seed) % 6 < 3 and colors.yellow or colors.white
    rect(x + inset + 2, y + inset + 2, size - 4, size - 4, core)
  end
end

--- Draws the explosions: cells grow while the blast spreads and shrink before they go out.
--- @within Board
function Board.draw_explosions()
  local tile = Config.board.tile_size
  for _, expl in ipairs(Context.explosions) do
    local x, y = screen_x(Util.to_pixel(expl.grid_x)), screen_y(Util.to_pixel(expl.grid_y))
    local seed = expl.grid_x + expl.grid_y
    if expl.spread <= 0 then
      local size = tile
      if expl.timer < 8 then size = tile - 2 * math.floor((8 - expl.timer) / 3) end
      draw_flame(x, y, size, seed)
    else
      local progress = 1 - (expl.spread / (expl.dist * Config.bomb.spread_delay))
      if progress > 0 then
        draw_flame(x, y, math.floor(tile * progress), seed)
      end
    end
  end
end

--- Draws the uncovered power-ups, bobbing.
--- @within Board
function Board.draw_powerups()
  for _, pw in ipairs(Context.powerups) do
    if Powerup.is_visible(pw) then
      local bob = math.floor(math.sin(Context.frame * 0.15 + pw.grid_x) * 1.2 + 0.5)
      UI.draw_powerup_icon(Powerup.get_config(pw.type),
        screen_x(Util.to_pixel(pw.grid_x)) + 1, screen_y(Util.to_pixel(pw.grid_y)) + 1 + bob)
    end
  end
end

--- Draws the bombs with a sparking fuse; they flash red when about to explode.
--- @within Board
function Board.draw_bombs()
  local sparks = { Config.colors.yellow, Config.colors.orange, Config.colors.white }
  for _, bomb in ipairs(Context.bombs) do
    local x, y = screen_x(Util.to_pixel(bomb.grid_x)), screen_y(Util.to_pixel(bomb.grid_y))
    local pulse = math.floor(Context.frame / 8) % 2
    local flashing = bomb.timer < Config.ai.danger_threshold and math.floor(bomb.timer / 3) % 2 == 0
    if flashing then poke4(PALETTE_MAP + Config.colors.dark_grey, Config.colors.red) end
    spr(Config.sprites.bomb, x, y + pulse, 0)
    if flashing then poke4(PALETTE_MAP + Config.colors.dark_grey, Config.colors.dark_grey) end
    pix(x + 4 + math.random(-1, 1), y - 1 + pulse + math.random(-1, 0), sparks[math.random(#sparks)])
  end
end

--- Draws a player's sprite: a coat, shades and the pill color (blue or red) on the tie.
--- With glow, a one-pixel outline in the pill color keeps the dark coat visible on the board.
--- @within Board
--- @param index number The player (1 or 2).<br/>
--- @param x number Left.<br/>
--- @param y number Top.<br/>
--- @param[opt] scale number Scale; 1 by default.<br/>
--- @param[opt] flip number 1 to mirror horizontally.<br/>
--- @param[opt] glow boolean Draw the outline.<br/>
function Board.draw_player_sprite(index, x, y, scale, flip, glow)
  local sprite = index == 1 and Config.sprites.player_blue or Config.sprites.player_red
  scale, flip = scale or 1, flip or 0
  if glow then
    local color = index == 1 and Config.colors.blue or Config.colors.red
    for c = 1, 15 do poke4(PALETTE_MAP + c, color) end
    spr(sprite, x - scale, y, 0, scale, flip)
    spr(sprite, x + scale, y, 0, scale, flip)
    spr(sprite, x, y - scale, 0, scale, flip)
    spr(sprite, x, y + scale, 0, scale, flip)
    for c = 1, 15 do poke4(PALETTE_MAP + c, c) end
  end
  spr(sprite, x, y, 0, scale, flip)
end

--- Draws the players; they bob while walking, face their direction and blink while dying.
--- @within Board
function Board.draw_players()
  for _, player in ipairs(Context.players) do
    local visible = not player.dead or Util.blink(3)
    if visible and not (player.dead and Context.phase_timer < Config.timing.death_duration / 2) then
      local x, y = screen_x(player.pixel_x), screen_y(player.pixel_y)
      local bob = player.moving and math.floor(Context.frame / 4) % 2 or 0
      Board.draw_player_sprite(player.index, x, y - bob, 1, player.facing < 0 and 1 or 0, true)
    end
  end
end

--- Draws one player's side of the top bar: name, bomb and power icons with counts, won rounds.
--- @within Board
local function draw_player_status(player, x, mirrored)
  local colors = Config.colors
  local name_color = player.index == 1 and colors.light_blue or colors.red
  local name = player.is_ai and "CPU" or "P" .. player.index
  local wins = Context.score[player.index]
  local dots_w = Config.match.rounds_to_win * 6
  local bomb_icon, power_icon = Powerup.get_config("bomb"), Powerup.get_config("power")

  local function stat(icon, value)
    local text = tostring(value)
    return {
      width = 8 + Print.width(text),
      draw = function(sx)
        UI.draw_powerup_icon(icon, sx, 2)
        print(text, sx + 8, 2, colors.white)
      end,
    }
  end
  local items = {
    {
      width = Print.width(name),
      draw = function(sx) print(name, sx, 2, name_color) end,
    },
    stat(bomb_icon, player.max_bombs),
    stat(power_icon, player.bomb_power),
  }

  local cursor = x
  if mirrored then
    for _, item in ipairs(items) do
      cursor = cursor - item.width
      item.draw(cursor)
      cursor = cursor - 5
    end
    cursor = cursor - dots_w
  else
    for _, item in ipairs(items) do
      item.draw(cursor)
      cursor = cursor + item.width + 5
    end
  end
  for i = 1, Config.match.rounds_to_win do
    local dot_x = cursor + 2 + (i - 1) * 6
    if i <= wins then
      circ(dot_x, 4, 2, colors.yellow)
    else
      circb(dot_x, 4, 2, colors.grey)
    end
  end
end

--- Draws the top bar: both players' name, bombs, power and won rounds; the round in the middle.
--- @within Board
function Board.draw_top_bar()
  rect(0, 0, Config.screen.width, 10, Config.colors.shadow)
  rect(0, 10, Config.screen.width, 2, Config.colors.black)
  local p1, p2 = Context.players[1], Context.players[2]
  if p1 then draw_player_status(p1, 3, false) end
  if p2 then draw_player_status(p2, Config.screen.width - 3, true) end
  local round = "ROUND " .. Context.round
  print(round, (Config.screen.width - Print.width(round)) / 2, 2, Config.colors.white)
end

--- Draws the whole round.
--- @within Board
function Board.draw()
  cls(Config.colors.green)
  Rain.draw(Config.board.offset_x, Config.board.offset_y, Config.board.width, Config.board.height,
    Config.board.tile_size, { head = Config.colors.grey, mid = Config.colors.teal, tail = Config.colors.shadow })
  Board.draw_shadows()
  Board.draw_tiles()
  Board.draw_explosions()
  Board.draw_powerups()
  Board.draw_bombs()
  Board.draw_players()
  Effects.draw()
  Board.draw_top_bar()
end
