# BombExpert

A Bomberman-style duel for the [TIC-80](https://tic80.com/) fantasy console: one player against the CPU, or two players on one keyboard.

## Features

- 1 Player mode (vs CPU) and 2 Player local multiplayer
- Matches: the first to win 3 rounds (adjustable) is the champion, with a rematch
- READY / GO countdown, pause menu (resume, restart round, main menu)
- A Matrix-style look: phosphor-green palette, digital rain, code walls, coat-and-shades players with a blue-pill and a red-pill glow
- Grid-based movement with smooth animation, destructible walls, screen shake and debris
- Power-ups hidden under the walls:
  - **B** (yellow): +1 bomb capacity
  - **P** (orange): +1 blast range
- A CPU opponent that hunts you down: it plans with the timing of every blast, never bombs without a way out, digs towards you and sets traps where you cannot escape
- Four map styles (classic, arena, maze, corridors)
- Settings kept between sessions: start bombs and power, speed, bomb timer, CPU speed, wall density, power-up chance, map style, rounds to win, music

## Controls

| Action | Player 1 (blue) | Player 2 (red) |
|--------|-----------------|----------------|
| Move | Arrow keys | W A S D |
| Place bomb | Space / Z | G |
| Pause | Backspace / X | Backspace |

Gamepad 1 and gamepad 2 work too. In the menus: Up / Down to choose, Space to select, Backspace to go back.

## Running the game

```bash
make build          # concatenate inc/ into bombexpert.lua (order: bombexpert.inc)
tic80 --fs=. bombexpert.lua
```

Other targets: `make run`, `make lint` (luacheck, errors mapped back to the `inc/` files), `make check`, `make web` (HTML export into `dist/web`), `make export`, `make docs` (ldoc).

## Source layout

The game follows the module layout of [Definitely not an Impostor](https://git.teletypegames.org/games/impostor): `inc/<layer>/<layer>.<name>.lua` files, concatenated in the order of `bombexpert.inc`. See `CLAUDE.md` for the architecture.

## Credits

- **Author**: Zsolt Tasnadi
- **Powered by**: Claude
- **Sponsored by**: Zen Heads

## License

MIT License

---

Happy X-MAS!
