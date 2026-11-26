--- @section Print

--- Prints text with a drop shadow.
--- @within Print
--- @param text string The text to print.<br/>
--- @param x number The x-coordinate.<br/>
--- @param y number The y-coordinate.<br/>
--- @param color number The color of the text.<br/>
--- @param[opt] fixed boolean If true, uses fixed-width font.<br/>
--- @param[opt] scale number The scaling factor.<br/>
function Print.text(text, x, y, color, fixed, scale)
  local shadow_color = Config.colors.shadow
  if color == shadow_color then shadow_color = Config.colors.black end
  scale = scale or 1
  print(text, x + scale, y + scale, shadow_color, fixed, scale)
  print(text, x, y, color, fixed, scale)
end

--- Prints text with a contour (outline).
--- @within Print
--- @param text string The text to print.<br/>
--- @param x number The x-coordinate.<br/>
--- @param y number The y-coordinate.<br/>
--- @param color number The color of the text.<br/>
--- @param[opt] fixed boolean If true, uses fixed-width font.<br/>
--- @param[opt] scale number The scaling factor (also the outline thickness).<br/>
--- @param[opt] contour_color number Outline color; black by default.<br/>
function Print.text_contour(text, x, y, color, fixed, scale, contour_color)
  scale = scale or 1
  local cc = contour_color or Config.colors.black
  if color == cc then cc = Config.colors.white end
  local ox = { -scale, scale, 0, 0, -scale, scale, -scale, scale }
  local oy = { 0, 0, -scale, scale, -scale, -scale, scale, scale }
  for i = 1, 8 do
    print(text, x + ox[i], y + oy[i], cc, fixed, scale)
  end
  print(text, x, y, color, fixed, scale)
end

--- Returns the width of a text in pixels.
--- @within Print
--- @param text string The text.<br/>
--- @param[opt] fixed boolean If true, uses fixed-width font.<br/>
--- @param[opt] scale number The scaling factor.<br/>
--- @return number The width.
function Print.width(text, fixed, scale)
  scale = scale or 1
  return print(text, 0, -8 * scale, 0, fixed, scale)
end

--- Prints centered text with a drop shadow.
--- @within Print
--- @param text string The text to print.<br/>
--- @param x number The x-coordinate of the center.<br/>
--- @param y number The y-coordinate.<br/>
--- @param color number The color of the text.<br/>
--- @param[opt] fixed boolean If true, uses fixed-width font.<br/>
--- @param[opt] scale number The scaling factor.<br/>
function Print.text_center(text, x, y, color, fixed, scale)
  Print.text(text, x - Print.width(text, fixed, scale) / 2, y, color, fixed, scale)
end

--- Prints centered text with a contour.
--- @within Print
--- @param text string The text to print.<br/>
--- @param x number The x-coordinate of the center.<br/>
--- @param y number The y-coordinate.<br/>
--- @param color number The color of the text.<br/>
--- @param[opt] fixed boolean If true, uses fixed-width font.<br/>
--- @param[opt] scale number The scaling factor.<br/>
--- @param[opt] contour_color number Outline color.<br/>
function Print.text_center_contour(text, x, y, color, fixed, scale, contour_color)
  Print.text_contour(text, x - Print.width(text, fixed, scale) / 2, y, color, fixed, scale, contour_color)
end
