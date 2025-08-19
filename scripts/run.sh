#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./run.sh <game-name>"
    echo "Available games:"
    echo "  - santry-maze"
    echo "  - platformer"
    exit 1
fi

GAME=$1
GAME_DIR="games/$GAME"
PICO8="/Applications/pico-8/PICO-8.app/Contents/MacOS/pico8"

if [ ! -d "$GAME_DIR" ]; then
    echo "Error: Game '$GAME' not found in games/ directory"
    exit 1
fi

# Determine cart name from pico.toml
if [ "$GAME" = "santry-maze" ]; then
    CART="santry_maze.p8"
elif [ "$GAME" = "platformer" ]; then
    CART="platformer.p8"
else
    echo "Error: Unknown game '$GAME'"
    exit 1
fi

echo "Running $GAME in PICO-8..."
"$PICO8" "$GAME_DIR/$CART"