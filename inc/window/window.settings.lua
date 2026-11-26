--- @section SettingsWindow
local START_Y = 16
local ROW_H = 10
local LABEL_X = 26
local VALUE_X = 160

--- Draws the settings with their values; the last row saves and goes back.
--- @within SettingsWindow
function SettingsWindow.draw()
  local colors = Config.colors
  cls(colors.navy)
  UI.draw_top_bar("Settings")

  local items = Settings.items()
  for i, item in ipairs(items) do
    local y = START_Y + (i - 1) * ROW_H
    local is_selected = Context.settings_item == i
    if is_selected then
      rect(0, y - 2, Config.screen.width, ROW_H, colors.teal)
      print("<", VALUE_X - 10, y, colors.cyan)
      print(">", VALUE_X + 40, y, colors.cyan)
    end
    Print.text(item.label, LABEL_X, y, is_selected and colors.white or colors.light_grey)
    Print.text(Settings.display(item), VALUE_X, y, colors.yellow)
  end

  local back_y = START_Y + #items * ROW_H + 2
  local back_selected = Context.settings_item == #items + 1
  if back_selected then
    Print.text(">", LABEL_X - 10, back_y, colors.yellow)
  end
  Print.text("Save & Back", LABEL_X, back_y, back_selected and colors.cyan or colors.light_grey)

  UI.draw_footer("UP/DOWN: select   LEFT/RIGHT: change")
end

--- Moves the selection, changes the selected value, saves and goes back on Select or Back.
--- @within SettingsWindow
function SettingsWindow.update()
  local items = Settings.items()
  local item = items[Context.settings_item]
  if Input.up() then
    Audio.sfx_move()
    Context.settings_item = Util.wrap(Context.settings_item, -1, #items + 1)
  elseif Input.down() then
    Audio.sfx_move()
    Context.settings_item = Util.wrap(Context.settings_item, 1, #items + 1)
  elseif Input.left() and item then
    Audio.sfx_move()
    Settings.change(item, -1)
  elseif Input.right() and item then
    Audio.sfx_move()
    Settings.change(item, 1)
  elseif Input.select() or Input.back() then
    Audio.sfx_confirm()
    Settings.save()
    Context.settings_item = 1
    Window.set_current("menu")
    Audio.music_play("menu")
  end
end
