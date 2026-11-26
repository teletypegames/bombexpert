--- Screen shake and particles (wall debris, sparks).
--- Particle coordinates are board pixels, like the entities.
--- @section Effects
local SCREEN_OFFSET_X = 0x3FF9
local SCREEN_OFFSET_Y = 0x3FFA

local _particles = {}
local _shake = 0

--- Removes every particle and stops the shake.
--- @within Effects
function Effects.clear()
  _particles = {}
  _shake = 0
end

--- Shakes the screen for some frames (the longer request wins).
--- @within Effects
--- @param frames number Duration.
function Effects.shake(frames)
  _shake = math.max(_shake, frames)
end

--- Adds particles flying out of a point.
--- @within Effects
--- @param x number Board pixel x.<br/>
--- @param y number Board pixel y.<br/>
--- @param colors table Colors to pick from.<br/>
--- @param count number Number of particles.<br/>
--- @param speed number Initial speed.<br/>
--- @param gravity number Downward acceleration per frame.<br/>
function Effects.burst(x, y, colors, count, speed, gravity)
  for i = 1, count do
    local angle = math.random() * math.pi * 2
    local v = speed * (0.4 + math.random() * 0.6)
    table.insert(_particles, {
      x = x,
      y = y,
      vx = math.cos(angle) * v,
      vy = math.sin(angle) * v - speed * 0.5,
      gravity = gravity,
      life = 16 + math.random(16),
      color = colors[(i % #colors) + 1],
    })
  end
end

--- Debris of a destroyed wall.
--- @within Effects
--- @param grid_x number Column.<br/>
--- @param grid_y number Row.<br/>
function Effects.debris(grid_x, grid_y)
  local half = Config.board.tile_size / 2
  Effects.burst(Util.to_pixel(grid_x) + half, Util.to_pixel(grid_y) + half,
    { Config.colors.light_grey, Config.colors.grey, Config.colors.white }, 7, 1.6, 0.15)
end

--- Sparks of a picked-up power-up.
--- @within Effects
--- @param grid_x number Column.<br/>
--- @param grid_y number Row.<br/>
--- @param color number The power-up's color.<br/>
function Effects.sparkle(grid_x, grid_y, color)
  local half = Config.board.tile_size / 2
  Effects.burst(Util.to_pixel(grid_x) + half, Util.to_pixel(grid_y) + half,
    { color, Config.colors.white }, 8, 1.2, 0)
end

--- Moves the particles and counts down the shake.
--- @within Effects
function Effects.update()
  for i = #_particles, 1, -1 do
    local p = _particles[i]
    p.x = p.x + p.vx
    p.y = p.y + p.vy
    p.vy = p.vy + p.gravity
    p.life = p.life - 1
    if p.life <= 0 then
      table.remove(_particles, i)
    end
  end
  if _shake > 0 then _shake = _shake - 1 end
end

--- Draws the particles over the board.
--- @within Effects
function Effects.draw()
  for _, p in ipairs(_particles) do
    pix(math.floor(p.x) + Config.board.offset_x, math.floor(p.y) + Config.board.offset_y, p.color)
  end
end

--- Sets the screen offset register: a random jolt while shaking, zero otherwise.
--- @within Effects
--- @param enabled boolean Whether the shake may show (only on the game screen).
function Effects.apply_shake(enabled)
  local dx, dy = 0, 0
  if enabled and _shake > 0 then
    local amount = math.min(2, math.ceil(_shake / 4))
    dx = math.random(-amount, amount)
    dy = math.random(-amount, amount)
  end
  poke(SCREEN_OFFSET_X, dx % 256)
  poke(SCREEN_OFFSET_Y, dy % 256)
end
