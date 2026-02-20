import random
from PIL import Image, ImageDraw

def create_tiling_pixel_grass():
    # Base size for pixel art (we will scale up 2x later)
    size = 128
    
    # Create a new image with a dark green base color
    img = Image.new("RGB", (size, size), (20, 50, 20))
    pixels = img.load()
    
    # Colors for noise and grass blades (strictly limited palette)
    palette = [
        (15, 40, 15), # Darker shadow
        (25, 60, 25), # Mid green
        (30, 75, 30), # Lighter green
    ]
    
    # 1. Base Noise (tiling)
    for y in range(size):
        for x in range(size):
            if random.random() < 0.3:
                pixels[x, y] = random.choice(palette[:2])
                
    # 2. Draw grass blades (tiny vertical/diagonal strokes)
    # We use a custom drawing function to enforce wrap-around (tiling)
    def put_pixel_wrapped(px, py, color):
        pixels[px % size, py % size] = color

    for _ in range(400): # Number of blades
        x = random.randint(0, size - 1)
        y = random.randint(0, size - 1)
        
        # Blade color
        color = palette[2] if random.random() < 0.3 else palette[1]
        
        # Grass shape (2 to 3 pixels tall)
        length = random.randint(2, 3)
        for i in range(length):
            put_pixel_wrapped(x, y - i, color)
            # Maybe slight curve
            if i == length - 1 and random.random() < 0.5:
                # Top of the grass bends
                bend_dir = 1 if random.random() < 0.5 else -1
                put_pixel_wrapped(x + bend_dir, y - i, color)

    # 3. Add a few tiny pebbles
    pebble_color = (60, 60, 65)
    for _ in range(10):
        x = random.randint(0, size - 1)
        y = random.randint(0, size - 1)
        put_pixel_wrapped(x, y, pebble_color)
        if random.random() < 0.5:
            put_pixel_wrapped(x + 1, y, pebble_color)
            
    # Resize to 256x256 using nearest neighbor to keep the blocky pixel art look
    final_img = img.resize((256, 256), Image.NEAREST)
    final_img.save("assets/grass.png")
    print("Generated perfectly tiling pixel art grass at assets/grass.png")

if __name__ == "__main__":
    create_tiling_pixel_grass()
