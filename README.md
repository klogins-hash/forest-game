# Forest Chop 🌲

A tiny third-person 3D forest game in a single HTML file. No build step, no install.

## Run

```bash
cd ~/projects/forest-game
python3 -m http.server 8000
```

Then open: **http://localhost:8000/**

> ES module imports need to be served over HTTP — opening `index.html` directly via `file://` will fail.

## Controls

| Input | Action |
|---|---|
| `W` `A` `S` `D` or arrow keys | Move |
| `Space` | Chop nearest tree |
| Mouse drag | Rotate camera |
| Touch drag | Rotate camera (mobile) |

## What it has

- Third-person camera that follows the player and rotates with mouse drag
- 80 randomly placed trees, each takes 3 chops to fell
- Trees actually fall over (rotate to the ground) instead of just disappearing
- Walking leg animation
- HUD with tree-felled counter
- Trees spawn at varied scales; a few decorative rocks
- Shadow-mapped sun + hemisphere light + sky-blue fog
- Touch + keyboard support

## Tech

- Three.js 0.160 (via import map from unpkg, so an internet connection is needed the first time)
- No frameworks, no bundler
