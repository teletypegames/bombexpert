--- @section UI
local MENU_ROW_H = 12

--- Draws the top bar of a screen.
--- @within UI
--- @param title string The title text.<br/>
function UI.draw_top_bar(title)
  rect(0, 0, Config.screen.width, 10, Config.colors.shadow)
  rect(0, 10, Config.screen.width, 2, Config.colors.black)
  Print.text(title, 4, 2, Config.colors.yellow)
end

--- Draws the hint line at the bottom of a screen.
--- @within UI
--- @param text string The hint.<br/>
function UI.draw_footer(text)
  Print.text_center(text, Config.screen.width / 2, Config.screen.height - 9, Config.colors.light_grey)
end

--- Draws a framed panel with a drop shadow.
--- @within UI
--- @param x number Left.<br/>
--- @param y number Top.<br/>
--- @param w number Width.<br/>
--- @param h number Height.<br/>
--- @param[opt] border number Border color; light blue by default.<br/>
function UI.draw_panel(x, y, w, h, border)
  rect(x + 3, y + 3, w, h, Config.colors.black)
  rect(x, y, w, h, border or Config.colors.light_blue)
  rect(x + 2, y + 2, w - 4, h - 4, Config.colors.black)
end

--- Draws a vertical menu; the selected item is highlighted with a moving cursor.
--- @within UI
--- @param items table Menu items, each with a label.<br/>
--- @param selected number Index of the selected item.<br/>
--- @param x number Left of the labels.<br/>
--- @param y number Top of the first item.<br/>
--- @param[opt] centered boolean Center each label on x.<br/>
function UI.draw_menu(items, selected, x, y, centered)
  local nudge = math.floor(math.sin(Context.frame * 0.2) + 0.5)
  for i, item in ipairs(items) do
    local item_y = y + (i - 1) * MENU_ROW_H
    local is_selected = i == selected
    local color = is_selected and Config.colors.cyan or Config.colors.light_grey
    local label_x = x
    if centered then label_x = x - Print.width(item.label) / 2 end
    if is_selected then
      Print.text(">", label_x - 9 + nudge, item_y, Config.colors.yellow)
    end
    Print.text(item.label, label_x, item_y, color)
  end
end

--- Moves the menu selection with Up and Down (wrapping) and plays the move sound.
--- @within UI
--- @param items table Menu items.<br/>
--- @param selected number Index of the selected item.<br/>
--- @return number The new selection.
function UI.update_menu(items, selected)
  if Input.up() then
    Audio.sfx_move()
    return Util.wrap(selected, -1, #items)
  elseif Input.down() then
    Audio.sfx_move()
    return Util.wrap(selected, 1, #items)
  end
  return selected
end

--- Draws a power-up icon: a colored box with its letter.
--- @within UI
--- @param config table The power-up type (color, label).<br/>
--- @param x number Left.<br/>
--- @param y number Top.<br/>
function UI.draw_powerup_icon(config, x, y)
  rect(x + 1, y + 1, 6, 6, Config.colors.shadow)
  rect(x, y, 6, 6, config.color)
  print(config.label, x + 1, y, Config.colors.black)
end
