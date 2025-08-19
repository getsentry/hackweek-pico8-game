#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./build.sh <game-name> [--watch]"
    echo "Available games:"
    echo "  - hackweek-game"
    echo "  - platformer"
    exit 1
fi

GAME=$1
GAME_DIR="games/$GAME"

if [ ! -d "$GAME_DIR" ]; then
    echo "Error: Game '$GAME' not found in games/ directory"
    exit 1
fi

cd "$GAME_DIR" || exit 1

if [ "$2" = "--watch" ]; then
    echo "Building and watching $GAME..."
    ../../pico-build build --watch
else
    echo "Building $GAME..."
    ../../pico-build build
fi