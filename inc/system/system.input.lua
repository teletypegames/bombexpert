--- @section Input
local BTN_UP = 0
local BTN_DOWN = 1
local BTN_LEFT = 2
local BTN_RIGHT = 3
local BTN_A = 4
local BTN_B = 5
local BTN_P2_OFFSET = 8
local KEY_A = 1
local KEY_D = 4
local KEY_G = 7
local KEY_S = 19
local KEY_W = 23
local KEY_SPACE = 48
local KEY_ENTER = 50
local KEY_BACKSPACE = 51

--- Checks if Up was pressed (menus).
--- @within Input
function Input.up() return btnp(BTN_UP) end
--- Checks if Down was pressed (menus).
--- @within Input
function Input.down() return btnp(BTN_DOWN) end
--- Checks if Left was pressed (menus).
--- @within Input
function Input.left() return btnp(BTN_LEFT) end
--- Checks if Right was pressed (menus).
--- @within Input
function Input.right() return btnp(BTN_RIGHT) end
--- Checks if Select was pressed: A button, Space or Enter.
--- @within Input
function Input.select() return btnp(BTN_A) or keyp(KEY_SPACE) or keyp(KEY_ENTER) end
--- Checks if Back was pressed: B button or Backspace.
--- @within Input
function Input.back() return btnp(BTN_B) or keyp(KEY_BACKSPACE) end
--- Checks if Pause was pressed: Back, or the B button of gamepad 2.
--- @within Input
function Input.pause() return Input.back() or btnp(BTN_B + BTN_P2_OFFSET) end

local PLAYER_CONTROLS = {
  {
    up = function() return btn(BTN_UP) end,
    down = function() return btn(BTN_DOWN) end,
    left = function() return btn(BTN_LEFT) end,
    right = function() return btn(BTN_RIGHT) end,
    bomb = function() return btnp(BTN_A) or keyp(KEY_SPACE) end,
  },
  {
    up = function() return key(KEY_W) or btn(BTN_UP + BTN_P2_OFFSET) end,
    down = function() return key(KEY_S) or btn(BTN_DOWN + BTN_P2_OFFSET) end,
    left = function() return key(KEY_A) or btn(BTN_LEFT + BTN_P2_OFFSET) end,
    right = function() return key(KEY_D) or btn(BTN_RIGHT + BTN_P2_OFFSET) end,
    bomb = function() return keyp(KEY_G) or btnp(BTN_A + BTN_P2_OFFSET) end,
  },
}

--- Returns the controls of a player: up, down, left, right (held) and bomb (pressed).
--- Player 1: arrows + Space (or gamepad 1), player 2: W A S D + G (or gamepad 2).
--- @within Input
--- @param index number The player (1 or 2).
--- @return table The control functions.
function Input.player(index)
  return PLAYER_CONTROLS[index]
end
