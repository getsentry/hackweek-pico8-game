#!/bin/bash
PICO8="/Applications/pico-8/PICO-8.app/Contents/MacOS/pico8"
DIR="$HOME/Code/hackweek-pico8-game"

# Run export
"$PICO8" -export "$DIR/platformer.html" "$DIR/platformer.p8" --help

