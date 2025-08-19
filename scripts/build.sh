#!/bin/bash
set -ex

if [ -z "$1" ]; then
    echo "Usage: ./build.sh <game-name> [--watch]"
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

# Determine cart name from game name
if [ "$GAME" = "santry-maze" ]; then
    CART="santry_maze.p8"
elif [ "$GAME" = "platformer" ]; then
    CART="platformer.p8"
else
    echo "Error: Unknown game '$GAME'"
    exit 1
fi

cd "$GAME_DIR" || exit 1

if [ "$2" = "--watch" ]; then
    echo "Building and watching $GAME..."
    ../../pico-build build --watch
else
    echo "Building $GAME..."
    ../../pico-build build
    
    # Export to HTML after successful build
    cd ../..
    mkdir -p exports
    echo "Exporting $GAME to exports/$GAME.html..."
    "$PICO8" -export "exports/$GAME.html" "$GAME_DIR/$CART"
    echo '<script>parent.picoWin = window;</script>' >> "exports/$GAME.html"
fi