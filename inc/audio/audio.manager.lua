--- Sound effects and a small step sequencer for the music and the jingles.
--- Channels: 0 explosions, 1 game and menu effects, 2 melody and jingles, 3 bass.
--- @section Audio
local SFX_EXPLOSION = 0
local SFX_PICKUP = 1
local SFX_MOVE = 2
local SFX_CONFIRM = 3
local SFX_PLACE = 4
local SFX_LEAD = 5
local SFX_BASS = 6

local CH_EXPLOSION = 0
local CH_EFFECT = 1
local CH_LEAD = 2
local CH_BASS = 3

local SONGS = {
  menu = {
    step_frames = 9,
    bass = { 33, 0, 33, 0, 36, 0, 36, 0, 31, 0, 31, 0, 28, 0, 28, 0 },
    lead = { 57, 60, 64, 0, 60, 64, 67, 0, 55, 59, 62, 0, 52, 55, 59, 0 },
  },
  game = {
    step_frames = 7,
    bass = { 26, 26, 38, 26, 26, 38, 26, 29, 24, 24, 36, 24, 24, 36, 24, 28 },
    lead = { 62, 0, 0, 65, 0, 0, 69, 0, 60, 0, 0, 64, 0, 0, 67, 0 },
  },
}

local JINGLES = {
  ready = { { 60, 8 } },
  go = { { 72, 16 } },
  round_win = { { 60, 6 }, { 64, 6 }, { 67, 6 }, { 72, 20 } },
  match_win = { { 60, 6 }, { 64, 6 }, { 67, 6 }, { 72, 10 }, { 67, 6 }, { 72, 30 } },
  death = { { 55, 6 }, { 51, 6 }, { 48, 6 }, { 43, 24 } },
}

local _music = {
  song = nil,
  step = 0,
  timer = 0,
}

local _jingle = {
  notes = nil,
  index = 0,
  timer = 0,
}

--- Plays a song in a loop; nothing happens if it is already playing or the music is off.
--- @within Audio
--- @param name string "menu" or "game".
function Audio.music_play(name)
  if Config.audio.music ~= "on" then
    Audio.music_stop()
    return
  end
  if _music.song == SONGS[name] then return end
  _music.song = SONGS[name]
  _music.step = 0
  _music.timer = 0
end

--- Stops the music.
--- @within Audio
function Audio.music_stop()
  _music.song = nil
  sfx(-1, 0, 0, CH_BASS)
  if not _jingle.notes then sfx(-1, 0, 0, CH_LEAD) end
end

--- Plays a short tune on the melody channel over the music.
--- @within Audio
--- @param name string "ready", "go", "round_win", "match_win" or "death".
function Audio.jingle(name)
  _jingle.notes = JINGLES[name]
  _jingle.index = 0
  _jingle.timer = 0
end

--- Advances the music and the jingle; called once per frame.
--- @within Audio
function Audio.update()
  if _jingle.notes then
    _jingle.timer = _jingle.timer - 1
    if _jingle.timer <= 0 then
      _jingle.index = _jingle.index + 1
      local note = _jingle.notes[_jingle.index]
      if note then
        sfx(SFX_LEAD, note[1], note[2], CH_LEAD, 12)
        _jingle.timer = note[2]
      else
        _jingle.notes = nil
      end
    end
  end

  local song = _music.song
  if not song then return end
  _music.timer = _music.timer - 1
  if _music.timer > 0 then return end
  _music.timer = song.step_frames
  _music.step = _music.step % #song.bass + 1
  local bass = song.bass[_music.step]
  if bass > 0 then
    sfx(SFX_BASS, bass, song.step_frames * 2, CH_BASS, 7)
  end
  local lead = song.lead[_music.step]
  if lead > 0 and not _jingle.notes then
    sfx(SFX_LEAD, lead, song.step_frames, CH_LEAD, 4)
  end
end

--- Explosion.
--- @within Audio
function Audio.sfx_explosion() sfx(SFX_EXPLOSION, nil, 30, CH_EXPLOSION) end
--- Power-up picked up.
--- @within Audio
function Audio.sfx_pickup() sfx(SFX_PICKUP, nil, 8, CH_EFFECT) end
--- Bomb placed.
--- @within Audio
function Audio.sfx_place() sfx(SFX_PLACE, 36, 8, CH_EFFECT, 10) end
--- Menu cursor moved or a value changed.
--- @within Audio
function Audio.sfx_move() sfx(SFX_MOVE, 60, 6, CH_EFFECT, 8) end
--- Menu item chosen.
--- @within Audio
function Audio.sfx_confirm() sfx(SFX_CONFIRM, 64, 12, CH_EFFECT, 10) end
--- Back or pause.
--- @within Audio
function Audio.sfx_back() sfx(SFX_CONFIRM, 55, 12, CH_EFFECT, 8) end
