# PICO-8 Games

Exploring PICO-8 for hackweek.

## Quick Start

```bash
npm install                               # Install dependencies
./scripts/build.sh hackweek-game --watch  # Build & watch for changes
./scripts/run.sh hackweek-game            # Launch in PICO-8
```

## Commands

Build: `./scripts/build.sh <game-name> [--watch]`  
Run: `./scripts/run.sh <game-name>`  
Export: `./scripts/export.sh <game-name>`

Games: `hackweek-game`, `platformer`  
Exports go to `exports/` directory

## How to Play

### Hackweek Game
You are the Sentry logo and need to dodge the bugs. The goal is to make it to the top. 
- Controls: X and O buttons (Z and X keys) to move left and right
- Press both buttons at once to move up

### Platformer
An AI-generated platformer with standard platforming mechanics.
