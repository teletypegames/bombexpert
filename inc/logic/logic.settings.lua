--- The settings the player can change; each one is a Config value kept in a pmem slot.
--- pmem holds integers, so fractions are stored multiplied and enums by index.
--- @section Settings
local SETTINGS_ITEMS = {
  {
    label = "Start Bombs",
    path = { "player", "start_bombs" },
    min = 1,
    max = 5,
    step = 1,
    pmem_slot = 0,
  },
  {
    label = "Start Power",
    path = { "player", "start_power" },
    min = 1,
    max = 5,
    step = 1,
    pmem_slot = 1,
  },
  {
    label = "Move Speed",
    path = { "player", "move_speed" },
    min = 1,
    max = 4,
    step = 1,
    pmem_slot = 2,
  },
  {
    label = "Bomb Timer",
    path = { "bomb", "timer" },
    min = 60,
    max = 180,
    step = 15,
    pmem_slot = 3,
  },
  {
    label = "AI Speed",
    path = { "ai", "move_delay" },
    min = 10,
    max = 40,
    step = 5,
    pmem_slot = 4,
  },
  {
    label = "Wall Density",
    path = { "map", "breakable_wall_chance" },
    min = 30,
    max = 90,
    step = 10,
    pmem_slot = 5,
    multiplier = 100,
  },
  {
    label = "Powerup Chance",
    path = { "map", "powerup_spawn_chance" },
    min = 10,
    max = 50,
    step = 5,
    pmem_slot = 6,
    multiplier = 100,
  },
  {
    label = "Map Style",
    path = { "map", "generator" },
    min = 1,
    max = 4,
    step = 1,
    pmem_slot = 7,
    enum_values = { "classic", "arena", "maze", "corridors" },
  },
  {
    label = "Rounds To Win",
    path = { "match", "rounds_to_win" },
    min = 1,
    max = 5,
    step = 1,
    pmem_slot = 8,
  },
  {
    label = "Music",
    path = { "audio", "music" },
    min = 1,
    max = 2,
    step = 1,
    pmem_slot = 9,
    enum_values = { "on", "off" },
  },
}

local PMEM_INIT_SLOT = 255
local PMEM_INIT_VALUE = 12345

--- Returns the setting definitions.
--- @within Settings
--- @return table The settings, in menu order.
function Settings.items()
  return SETTINGS_ITEMS
end

--- Returns the stored (integer) value of a setting from Config.
--- @within Settings
--- @param item table The setting.
--- @return number The value.
function Settings.get_value(item)
  local value = Config
  for _, key in ipairs(item.path) do
    value = value[key]
  end
  if item.multiplier then
    return math.floor(value * item.multiplier + 0.5)
  end
  if item.enum_values then
    for i, v in ipairs(item.enum_values) do
      if v == value then return i end
    end
    return 1
  end
  return value
end

--- Writes the stored (integer) value of a setting into Config.
--- @within Settings
--- @param item table The setting.
--- @param value number The value.
function Settings.set_value(item, value)
  local target = Config
  for i = 1, #item.path - 1 do
    target = target[item.path[i]]
  end
  local final_key = item.path[#item.path]
  if item.multiplier then
    target[final_key] = value / item.multiplier
  elseif item.enum_values then
    target[final_key] = item.enum_values[value]
  else
    target[final_key] = value
  end
end

--- Steps a setting up or down, wrapping at the ends.
--- @within Settings
--- @param item table The setting.
--- @param direction number +1 or -1.
function Settings.change(item, direction)
  local value = Settings.get_value(item) + direction * item.step
  if value < item.min then value = item.max end
  if value > item.max then value = item.min end
  Settings.set_value(item, value)
end

--- Returns the text shown for a setting.
--- @within Settings
--- @param item table The setting.
--- @return string The value as text.
function Settings.display(item)
  local value = Settings.get_value(item)
  if item.enum_values then
    return item.enum_values[value] or "?"
  end
  if item.multiplier then
    return value .. "%"
  end
  return tostring(value)
end

--- Loads the settings from pmem; on the first run it stores the defaults.
--- @within Settings
function Settings.load()
  if pmem(PMEM_INIT_SLOT) ~= PMEM_INIT_VALUE then
    Settings.save()
    pmem(PMEM_INIT_SLOT, PMEM_INIT_VALUE)
    return
  end
  for _, item in ipairs(SETTINGS_ITEMS) do
    local stored = pmem(item.pmem_slot)
    if stored >= item.min and stored <= item.max then
      Settings.set_value(item, stored)
    end
  end
end

--- Saves the settings to pmem.
--- @within Settings
function Settings.save()
  for _, item in ipairs(SETTINGS_ITEMS) do
    pmem(item.pmem_slot, Settings.get_value(item))
  end
end
