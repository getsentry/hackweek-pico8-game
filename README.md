# PICO-8 Games

Exploring PICO-8 for hackweek.

[Play game in browser](https://getsentry.github.io/hackweek-pico8-game)

## Quick Start

```bash
npm install                               # Install dependencies
./scripts/build.sh santry-maze           # Build and export to HTML
./scripts/build.sh santry-maze --watch   # Build & watch for changes (no auto-export)
./scripts/run.sh santry-maze             # Launch in PICO-8
```

## Commands

Build & Export: `./scripts/build.sh <game-name>`  
Build & Watch: `./scripts/build.sh <game-name> --watch`  
Run: `./scripts/run.sh <game-name>`

Games: `santry-maze`, `platformer`  
HTML exports are automatically created in `exports/` directory when building

## How to Play

### Santry Maze
You are the Sentry logo and need to dodge the bugs. The goal is to make it to the top. 
- Controls: X and O buttons (Z and X keys) to move left and right
- Press both buttons at once to move up

### Platformer
An AI-generated platformer with standard platforming mechanics.
