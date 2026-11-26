--- @section Window
local _windows = {}

--- Registers a window table.
--- @within Window
--- @param id string The ID of the window (e.g., "menu", "game").</br>
--- @param window_table table The window module: update and draw, optionally enter.</br>
function Window.register(id, window_table)
  _windows[id] = window_table
end

--- Retrieves a registered window table by its ID.
--- @within Window
--- @param id string The ID of the window.
--- @return result table The window module table or nil. </br>
--- Fields: </br>
--- * update (function) Called each frame to update window logic.<br/>
--- * draw (function) Called each frame to draw the window.<br/>
--- * enter (function, optional) Called when the window becomes active.<br/>
function Window.get(id)
  return _windows[id]
end

--- Sets the currently active window and calls its enter function.
--- @within Window
--- @param id string The ID of the window to activate.</br>
function Window.set_current(id)
  Context.current_window = id
  local window_table = _windows[id]
  if window_table and window_table.enter then
    window_table.enter()
  end
end

--- Gets the ID of the currently active window.
--- @within Window
--- @return string The ID of the active window.
function Window.get_current_id()
  return Context.current_window
end

--- Gets the handler function for the currently active window.
--- The window drawn is the one active after the update, so a window switch
--- never draws the previous window with the new state.
--- @within Window
--- @return function A function that updates and draws the current window.
function Window.get_current_handler()
  local window_table = Window.get(Context.current_window)
  if window_table and window_table.update and window_table.draw then
    return function()
      window_table.update()
      Window.get(Context.current_window).draw()
    end
  end
  return function() trace("Error: No handler for window: " .. tostring(Context.current_window)) end
end
