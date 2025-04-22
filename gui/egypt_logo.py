import base64
from io import BytesIO
import tkinter as tk
from PIL import Image, ImageTk, ImageDraw

def create_egypt_logo(size=100, color1="#E7B656", color2="#3A5BA0", color3="#C93C20"):
    """Creates an Egypt-themed logo for the travel planner.
    
    Returns:
        A PhotoImage object that can be used in Tkinter
    """
    # Create a transparent image
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw a simplified pyramid
    pyramid_points = [
        (size//2, size//6),  # Top
        (size//6, size*5//6),  # Bottom left
        (size*5//6, size*5//6)  # Bottom right
    ]
    draw.polygon(pyramid_points, fill=color1)
    
    # Draw a simplified sun
    sun_radius = size//5
    sun_position = (size*3//4, size//4)
    draw.ellipse((sun_position[0]-sun_radius, sun_position[1]-sun_radius,
                  sun_position[0]+sun_radius, sun_position[1]+sun_radius), 
                 fill=color2)
    
    # Draw a palm tree silhouette
    trunk_width = size//20
    trunk_height = size//3
    trunk_bottom = (size//5, size*3//4)
    trunk_top = (trunk_bottom[0], trunk_bottom[1] - trunk_height)
    
    # Trunk
    draw.rectangle((trunk_top[0] - trunk_width//2, trunk_top[1],
                    trunk_top[0] + trunk_width//2, trunk_bottom[1]),
                   fill=color3)
    
    # Fronds
    frond_size = size//6
    for angle in [30, 0, -30, 60, -60]:
        if angle == 0:
            draw.ellipse((trunk_top[0] - frond_size, trunk_top[1] - frond_size,
                          trunk_top[0] + frond_size, trunk_top[1] + frond_size//2),
                         fill=color3)
        elif angle > 0:
            draw.ellipse((trunk_top[0], trunk_top[1] - frond_size//2,
                          trunk_top[0] + frond_size, trunk_top[1] + frond_size//2),
                         fill=color3)
        else:
            draw.ellipse((trunk_top[0] - frond_size, trunk_top[1] - frond_size//2,
                          trunk_top[0], trunk_top[1] + frond_size//2),
                         fill=color3)
    
    return ImageTk.PhotoImage(img)

def get_base64_logo():
    """Returns the logo as a base64 encoded string for embedding in applications."""
    img = Image.new("RGBA", (100, 100), (0, 0, 0, 0))
    # ... (same drawing code as above)
    
    # Convert to base64
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    return base64.b64encode(buffer.getvalue()).decode('utf-8')

if __name__ == "__main__":
    # Test the logo by displaying it
    root = tk.Tk()
    root.title("Egypt Logo Test")
    root.geometry("200x200")
    root.configure(bg="#f5f5f5")
    
    logo = create_egypt_logo(150)
    label = tk.Label(root, image=logo, bg="#f5f5f5")
    label.pack(padx=20, pady=20)
    
    root.mainloop() 