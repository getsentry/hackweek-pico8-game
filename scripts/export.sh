#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./scripts/export.sh <game-name>"
    echo "Available games:"
    echo "  - hackweek-game"
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
if [ "$GAME" = "hackweek-game" ]; then
    CART="hackweek_pico_8_game.p8"
elif [ "$GAME" = "platformer" ]; then
    CART="platformer.p8"
else
    echo "Error: Unknown game '$GAME'"
    exit 1
fi

# Create exports directory if it doesn't exist
mkdir -p exports

# Export to HTML
echo "Exporting $GAME to exports/$GAME.html..."
"$PICO8" -export "exports/$GAME.html" "$GAME_DIR/$CART"

echo '<script>parent.picoWin = window;</script>' >> "exports/$GAME.html"
