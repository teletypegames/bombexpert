# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**BombExpert** is a Bomberman-style duel for [TIC-80](https://tic80.com/), written in Lua. All source modules in `inc/` are concatenated at build time into a single `bombexpert.lua` that TIC-80 loads. The structure follows `games/impostor`.

## Build Commands

```bash
make build          # Concatenate inc/**/*.lua into bombexpert.lua (order from bombexpert.inc)
make run            # Build and start TIC-80
make lint           # luacheck with errors mapped back to the inc/ files
make check          # lint when luacheck is installed (the CI contract), else the build
make web            # HTML export into dist/web (needs a released TIC-80; a -dev build cannot download the player)
make export         # Export minified game to HTML and .tic formats
make export_assets  # Extract the TIC-80 asset sections into inc/meta/meta.assets.lua
make docs           # Documentation with ldoc
make clean          # Remove build artifacts
```

There is no test framework; validation is `make lint`. Because every file ends up in one chunk, file-level `local` names must be unique across all files (luacheck reports shadowing), and the code must stay Lua 5.1 syntax for luacheck (no `//`, no `goto`).

## Code Conventions (from impostor)

- **Modules**: global tables declared in `init/init.module.lua` (windows in `window/window.register.lua`), functions `Module.snake_case`
- **Variables**: `snake_case`; **constants**: `SCREAMING_SNAKE_CASE`; file-private state `_name`
- **Indentation**: 2 spaces; tables multi-line, one key per line
- **Docs**: `--- @section Name` per file, `--- @within Name` on every function (ldoc)
- New globals go into `.luacheckrc`

## Architecture

State machine driven by a window manager. `TIC()` in `inc/system/system.main.lua` initializes once (Config defaults, Settings from pmem, Context), then each frame updates and draws the current window, advances the audio sequencer and applies the screen shake.

### Init (`inc/init/`)

| File | Purpose |
|------|---------|
| `init.module.lua` | Global module tables |
| `init.config.lua` | `Config`: screen, Sweetie 16 colors, board, tiles, sprite ids, player/bomb/ai/map/match/audio values, timing |
| `init.context.lua` | `Context`: runtime state — current window, menu selections, players, bombs, explosions, power-ups, map, score, round, phase |

### Windows (`inc/window/`)

`Window.register(id, table)`; a window has `update`, `draw` and optionally `enter` (called by `Window.set_current`). After an update the window that is current *then* is drawn.

| Window | Purpose |
|--------|---------|
| `intro_ttg` | Teletype Games logo reveal |
| `title` | Title screen: bouncing letters, big bomb, PRESS SPACE |
| `menu` | 1P / 2P / Settings / Controls / Credits / Exit |
| `settings` | Settings editor, saved to pmem |
| `controls` | Key table and power-ups |
| `credits` | Raster bars, falling title, scroller |
| `game` | The round (READY / GO countdown overlay) |
| `pause` | Resume / Restart round / Main menu over the frozen board |
| `round_end` | Round winner and score |
| `match_end` | Champion, confetti, Rematch / Main menu |

### Logic (`inc/logic/`)

| Module | Purpose |
|--------|---------|
| `logic.match.lua` | Match and round flow; phases `ready` → `play` → `dying`; first player found in a flame loses the round |
| `logic.map.lua` | Board generators (classic, arena, maze, corridors), walkability, spawn areas |
| `logic.bomb.lua` | Placing, exploding and spreading bombs; explosion cells |
| `logic.ai.lua` | CPU: danger map, escape routes, power-up seeking, bombing |
| `logic.player.lua` | Player creation/reset, smooth movement, human input |
| `logic.powerup.lua` | Power-up types (weighted), hiding and pickup |
| `logic.effects.lua` | Particles and screen shake (screen offset register 0x3FF9/0x3FFA) |
| `logic.settings.lua` | Settings definitions and pmem persistence (slots 0–9, init marker in 255) |

### Drawing, system, audio

- `draw/draw.board.lua`: the round — walls, flames, power-ups, bombs (palette-map flash), players (player 1 tinted light blue), particles, top bar.
- `system/`: `Util`, `Print` (shadow/contour text), `Input` (menu keys, `Input.player(n)` controls), `UI` (top bar, menus, panels).
- `audio/audio.manager.lua`: sound effects and a step sequencer for the menu/game music and jingles (channels: 0 explosion, 1 effects, 2 melody/jingles, 3 bass). SFX 0–6 live in `inc/meta/meta.assets.lua`.

### Assets

`inc/meta/meta.assets.lua` holds the TIC-80 sections (TILES, SPRITES, WAVES, SFX, TRACKS, PALETTE). Sprites 256–260: player 1, player 2, bomb, breakable wall, solid wall.
