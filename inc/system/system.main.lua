--- @section Main
local _initialized = false

--- Initializes the game once: settings from pmem, a fresh context, the intro window.
--- @within Main
local function init_game()
  if _initialized then return end
  Config.reset()
  Settings.load()
  Context.reset()
  Window.set_current("intro_ttg")
  _initialized = true
end

--- Main game loop (TIC-80 callback).
--- @within Main
function TIC()
  init_game()
  Context.frame = Context.frame + 1
  cls(Config.colors.black)
  Window.get_current_handler()()
  Audio.update()
  Effects.apply_shake(Window.get_current_id() == "game")
end
