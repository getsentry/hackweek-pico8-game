#!/usr/bin/env uv run
# /// script
# dependencies = ["pillow"]
# ///

from PIL import Image
import os
import shutil

"""
PICO-8 Color Palette - Standard 16 Colors

Standard Colors (0-15):
0: Black, 1: Dark Blue, 2: Dark Purple, 3: Dark Green, 4: Brown, 5: Dark Gray
6: Light Gray, 7: White, 8: Red, 9: Orange, 10: Yellow, 11: Green
12: Blue, 13: Indigo, 14: Pink, 15: Peach
"""

# PICO-8 palette as RGB tuples (16 standard colors only)
PICO8_PALETTE = [
    # Standard PICO-8 colors (0-15)
    (0, 0, 0), (29, 43, 83), (126, 37, 83), (0, 135, 81),
    (171, 82, 54), (95, 87, 79), (194, 195, 199), (255, 241, 232),
    (255, 0, 77), (255, 163, 0), (255, 236, 39), (0, 228, 54),
    (41, 173, 255), (131, 118, 156), (255, 119, 168), (255, 204, 170),
]

def closest_palette_color(rgb):
    return min(range(16), key=lambda i: sum((a - b) ** 2 for a, b in zip(rgb, PICO8_PALETTE[i])))

def load_and_convert_image(path):
    im = Image.open(path).convert('RGB')
    w, h = im.size
    print(f"  → Loading image {path}: {w}x{h}")
    
    out = Image.new('P', (w, h))
    palette = sum(PICO8_PALETTE, ()) + (0,) * (768 - 3 * len(PICO8_PALETTE))
    out.putpalette(palette)

    for y in range(h):
        for x in range(w):
            c = im.getpixel((x, y))
            out.putpixel((x, y), closest_palette_color(c))

    return out

def generate_gfx_from_sprites(sprite_files):
    """Generate PICO-8 gfx data directly from individual sprite files"""
    data = []
    
    # Find the highest row that will contain sprite data
    max_sprite_row = 0
    for i, sprite_path in enumerate(sprite_files):
        sprite_y = i // 16  # 16 sprites per row
        sprite_end_row = (sprite_y + 1) * 8 - 1  # Last row of this sprite
        max_sprite_row = max(max_sprite_row, sprite_end_row)
    
    # Only generate gfx data for rows that contain sprite pixels
    rows_to_generate = max_sprite_row + 1
    
    print(f"  → Generating gfx data for {rows_to_generate} rows (instead of 128)")
    
    # Initialize only the needed lines with zeros
    for y in range(rows_to_generate):
        line = "00" * 64  # 64 hex characters = 128 pixels, all zeros
        data.append(line)
    
    # Place each sprite directly in its correct gfx position
    for i, sprite_path in enumerate(sprite_files):
        # Load and convert the sprite
        im = load_and_convert_image(sprite_path)
        if im.size != (8, 8):
            print(f"  → Resizing sprite {i} from {im.size} to (8, 8)")
            im = im.resize((8, 8), Image.NEAREST)
        
        # Calculate sprite position
        sprite_x = i % 16  # 16 sprites per row
        sprite_y = i // 16
        
        print(f"  → Placing sprite {i} at gfx position "
              f"({sprite_x}, {sprite_y})")
        
        # Place sprite pixels directly in the gfx data
        for sy in range(8):
            y_pos = sprite_y * 8 + sy
            if y_pos < len(data):  # Ensure we don't exceed our data bounds
                line = list(data[y_pos])  # Convert string to list for mod
                
                for sx in range(0, 8, 2):  # Process 2 pixels at a time
                    x_pos = sprite_x * 8 + sx
                    if x_pos < 128:  # Ensure we don't exceed gfx bounds
                        # Get 2 pixels: left and right
                        left = im.getpixel((sx, sy))
                        right = im.getpixel((sx + 1, sy)) if sx + 1 < 8 else 0
                        
                        # Convert to hex: each hex character represents 2 pixels
                        byte = (left << 4) | right
                        
                        # Calculate position in the hex string 
                        # (each hex char = 2 pixels)
                        hex_pos = x_pos // 2
                        if hex_pos < 64:  # Ensure we don't exceed line bounds
                            # Update the hex character in the line
                            line[hex_pos * 2:hex_pos * 2 + 2] = f"{byte:02x}"
                
                # Convert list back to string and update the data
                data[y_pos] = "".join(line)
    
    return data

def inject_gfx_into_cart(template_path, output_path, gfx_data):
    """Inject gfx data into PICO-8 cartridge"""
    with open(template_path, "r") as f:
        content = f.read()
    
    # Check if __gfx__ section already exists
    if "__gfx__" in content:
        # Replace existing gfx section
        lines = content.split("\n")
        new_lines = []
        in_gfx = False
        
        for line in lines:
            if line.strip() == "__gfx__":
                in_gfx = True
                new_lines.append("__gfx__")
                # Add all gfx data lines
                for gfx_line in gfx_data:
                    new_lines.append(gfx_line)
                continue
            if in_gfx:
                if line.strip().startswith("__"):
                    in_gfx = False
                    new_lines.append(line)
                continue
            new_lines.append(line)
        
        new_content = "\n".join(new_lines)
    else:
        # Add gfx section at the end
        new_content = content + "\n__gfx__\n" + "\n".join(gfx_data)
    
    with open(output_path, "w") as f:
        f.write(new_content)


def main():
    template_cart = "games/platformer/platformer.p8"
    output_cart = "platformer_with_sprites.p8"
    
    # Create generated directory inside assets
    generated_dir = "assets/generated"
    os.makedirs(generated_dir, exist_ok=True)

    # Get all PNG files
    sprite_files = ["assets/1.sentry.png", "assets/2.star.png"]

    # Process sprites
    if sprite_files:
        print("→ Generating gfx data directly from sprite files...")
        gfx_data = generate_gfx_from_sprites(sprite_files)

        print("→ Injecting sprites into cartridge...")
        inject_gfx_into_cart(template_cart, output_cart, gfx_data)
    else:
        print("→ No sprite files found, copying template...")
        shutil.copy(template_cart, output_cart)

    print(f"✅ Done. Output: {output_cart}")
    print(f"📁 Generated files saved to: {generated_dir}/")

if __name__ == "__main__":
    main()