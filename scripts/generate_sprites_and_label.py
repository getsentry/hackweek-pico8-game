#!/usr/bin/env uv run
# /// script
# dependencies = ["pillow"]
# ///

from PIL import Image
import os
import shutil

"""
PICO-8 Color Palette - Full 32 Colors

Standard Colors (0-15):
0: Black, 1: Dark Blue, 2: Dark Purple, 3: Dark Green, 4: Brown, 5: Dark Gray
6: Light Gray, 7: White, 8: Red, 9: Orange, 10: Yellow, 11: Green
12: Blue, 13: Indigo, 14: Pink, 15: Peach

Extended Colors (16-31):
16: Darker Red, 17: Darker Orange, 18: Darker Yellow, 19: Darker Green
20: Darker Blue, 21: Darker Indigo, 22: Darker Pink, 23: Darker Peach
24: Very Dark Red, 25: Very Dark Orange, 26: Very Dark Yellow, 27: Very Dark Green
28: Very Dark Blue, 29: Very Dark Indigo, 30: Very Dark Pink, 31: Very Dark Peach
"""

# PICO-8 palette as RGB tuples (16 standard + 16 extended colors)
PICO8_PALETTE = [
    # Standard PICO-8 colors (0-15)
    (0, 0, 0), (29, 43, 83), (126, 37, 83), (0, 135, 81),
    (171, 82, 54), (95, 87, 79), (194, 195, 199), (255, 241, 232),
    (255, 0, 77), (255, 163, 0), (255, 236, 39), (0, 228, 54),
    (41, 173, 255), (131, 118, 156), (255, 119, 168), (255, 204, 170),
    # Secret PICO-8 colors (16-31)
    (128, 0, 38), (128, 81, 0), (128, 118, 19), (0, 114, 27),
    (20, 86, 127), (65, 59, 78), (128, 59, 84), (128, 102, 85),
    (64, 0, 19), (64, 40, 0), (64, 59, 9), (0, 57, 13),
    (10, 43, 63), (32, 29, 39), (64, 29, 42), (64, 51, 42),
]

def closest_palette_color(rgb):
    return min(range(32), key=lambda i: sum((a - b) ** 2 for a, b in zip(rgb, PICO8_PALETTE[i])))

def load_and_convert_image(path):
    im = Image.open(path).convert('RGB')
    w, h = im.size
    out = Image.new('P', (w, h))
    palette = sum(PICO8_PALETTE, ()) + (0,) * (768 - 3 * len(PICO8_PALETTE))
    out.putpalette(palette)

    for y in range(h):
        for x in range(w):
            c = im.getpixel((x, y))
            out.putpixel((x, y), closest_palette_color(c))

    return out

def pack_images(image_paths):
    sprite_sheet = Image.new('P', (128, 128))
    palette = sum(PICO8_PALETTE, ()) + (0,) * (768 - 3 * len(PICO8_PALETTE))
    sprite_sheet.putpalette(palette)

    cell_size = 8
    max_cells = 128 // cell_size
    x, y = 0, 0

    for path in image_paths:
        im = load_and_convert_image(path)
        if im.size != (8, 8):
            im = im.resize((8, 8), Image.NEAREST)
        sprite_sheet.paste(im, (x * 8, y * 8))
        x += 1
        if x >= max_cells:
            x = 0
            y += 1
        if y >= max_cells:
            raise ValueError("Sprite sheet overflow!")

    return sprite_sheet

def save_individual_sprites(sprite_sheet, sprite_files, output_dir):
    """Save each individual sprite as a separate PNG file"""
    # Create generated directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    cell_size = 8
    max_cells = 128 // cell_size
    
    for i, sprite_file in enumerate(sprite_files):
        # Calculate position in sprite sheet
        x = i % max_cells
        y = i // max_cells
        
        # Extract individual sprite
        sprite = Image.new('P', (8, 8))
        sprite.putpalette(sprite_sheet.getpalette())
        
        for sy in range(8):
            for sx in range(8):
                pixel = sprite_sheet.getpixel((x * 8 + sx, y * 8 + sy))
                sprite.putpixel((sx, sy), pixel)
        
        # Generate filename from original sprite file
        base_name = os.path.splitext(os.path.basename(sprite_file))[0]
        sprite_path = os.path.join(output_dir, f"{base_name}.sprite.png")
        sprite.save(sprite_path)
        print(f"  → Saved sprite to: {sprite_path}")

def convert_sprite_sheet_to_gfx(sprite_sheet):
    data = ""
    # Count how many sprites we actually have
    sprite_count = 0
    cell_size = 8
    max_cells = 128 // cell_size
    
    # Find the last sprite position
    for y in range(max_cells):
        for x in range(max_cells):
            # Check if this cell has any non-zero pixels
            has_data = False
            for sy in range(cell_size):
                for sx in range(cell_size):
                    pixel = sprite_sheet.getpixel((
                        x * cell_size + sx, 
                        y * cell_size + sy
                    ))
                    if pixel != 0:
                        has_data = True
                        break
                if has_data:
                    break
            if has_data:
                sprite_count = max(sprite_count,
                                  y * max_cells + x + 1)
    
    # Calculate how many rows we need
    rows_needed = (sprite_count + max_cells - 1) // max_cells  # Ceiling division
    
    # Only generate data for the rows that contain sprites
    for y in range(rows_needed):
        for x in range(max_cells):
            # Check if this cell has any non-zero pixels
            has_data = False
            for sy in range(cell_size):
                for sx in range(cell_size):
                    pixel = sprite_sheet.getpixel((
                        x * cell_size + sx, 
                        y * cell_size + sy
                    ))
                    if pixel != 0:
                        has_data = True
                        break
                if has_data:
                    break
            
            if has_data:
                # Generate data for this sprite (8 pixels = 4 hex bytes)
                sprite_data = ""
                for sy in range(cell_size):
                    for sx in range(0, cell_size, 2):
                        c1 = sprite_sheet.getpixel((
                            x * cell_size + sx, 
                            y * cell_size + sy
                        ))
                        c2 = sprite_sheet.getpixel((
                            x * cell_size + sx + 1, 
                            y * cell_size + sy
                        ))
                        byte = (c1 << 4) | c2
                        sprite_data += f"{byte:02x}"
                    sprite_data += "\n"
                data += sprite_data
            else:
                # Empty sprite row (8 lines of zeros)
                for _ in range(cell_size):
                    data += "00000000000000000000000000000000\n"
    
    return data





def inject_gfx_into_cart(template_path, output_path, gfx_data):
    with open(template_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    in_gfx = False
    gfx_section_found = False
    
    for line in lines:
        if line.strip() == "__gfx__":
            in_gfx = True
            gfx_section_found = True
            new_lines.append("__gfx__\n")
            new_lines.extend(gfx_data)
            continue
        if in_gfx:
            if line.strip().startswith("__"):
                in_gfx = False
                new_lines.append(line)
            continue
        new_lines.append(line)
    
    # If no __gfx__ section was found, add one at the end
    if not gfx_section_found:
        new_lines.append("__gfx__\n")
        new_lines.extend(gfx_data)

    with open(output_path, "w") as f:
        f.writelines(new_lines)





def main():
    template_cart = "games/platformer/platformer.p8"
    output_cart = "platformer_with_sprites.p8"
    
    # Create generated directory inside assets
    generated_dir = "assets/generated"
    os.makedirs(generated_dir, exist_ok=True)

    # Get all PNG files
    sprite_files = ["assets/1.sentry.png"]

    # Process sprites
    if sprite_files:
        print("→ Packing sprites...")
        sheet = pack_images(sprite_files)

        # Save individual sprites to generated folder
        save_individual_sprites(sheet, sprite_files, generated_dir)

        print("→ Converting to __gfx__ format...")
        gfx_data = convert_sprite_sheet_to_gfx(sheet)

        print("→ Injecting sprites into cartridge...")
        inject_gfx_into_cart(template_cart, output_cart, gfx_data)
    else:
        print("→ No sprite files found, copying template...")
        shutil.copy(template_cart, output_cart)



    print(f"✅ Done. Output: {output_cart}")
    print(f"📁 Generated files saved to: {generated_dir}/")

if __name__ == "__main__":
    main()