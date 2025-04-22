"""
themes.py - Color schemes and styling for the Egypt Travel Planner
"""
import tkinter as tk
from tkinter import ttk
import tkinter.font as tkfont
import os
import sys
import platform

# Color Scheme - Egyptian Desert Theme
DESERT_THEME = {
    "primary": "#E8A94B",      # Warmer Gold
    "primary_dark": "#D68D30",  # Darker Gold
    "secondary": "#2C5697",    # Rich Blue
    "accent": "#D93B1A",       # Vibrant Red
    "bg_light": "#FFFCF7",     # Lighter Sand
    "bg_medium": "#F3EEE2",    # Medium Sand  
    "text_dark": "#1F1F1F",    # Almost Black
    "text_medium": "#4A4A4A",  # Dark Gray
    "text_light": "#FFFFFF",   # White
    "border": "#E5DBC7",       # Light Sand Border
    "success": "#4CAF50",      # Green
    "warning": "#FFC107",      # Amber
    "error": "#F44336",        # Red
    "shadow": "rgba(0, 0, 0, 0.1)", # Shadow color
    "card_bg": "#FFFFFF",      # Card background
}

# The active theme that will be used
ACTIVE_THEME = DESERT_THEME

def setup_fonts():
    """Setup and return custom fonts based on what's available on the system"""
    fonts = {}
    
    # Determine best font family based on operating system
    if platform.system() == "Windows":
        base_family = "Segoe UI"
        heading_family = "Segoe UI"
        mono_family = "Consolas"
    elif platform.system() == "Darwin":  # macOS
        base_family = "SF Pro"
        heading_family = "SF Pro Display"
        mono_family = "SF Mono"
    else:  # Linux and others
        base_family = "Roboto"
        heading_family = "Roboto"
        mono_family = "DejaVu Sans Mono"
    
    # Check if we can use the fonts, otherwise fall back
    available_fonts = tkfont.families()
    
    if base_family not in available_fonts:
        base_family = "Arial" if "Arial" in available_fonts else "TkDefaultFont"
    
    if heading_family not in available_fonts:
        heading_family = base_family
    
    if mono_family not in available_fonts:
        mono_family = "Courier" if "Courier" in available_fonts else "TkFixedFont"
    
    # Create our font set
    fonts["display"] = (heading_family, 22, "bold")
    fonts["h1"] = (heading_family, 18, "bold")
    fonts["h2"] = (heading_family, 16, "bold")
    fonts["h3"] = (heading_family, 14, "bold")
    fonts["h4"] = (heading_family, 12, "bold")
    fonts["subtitle"] = (heading_family, 12, "italic")
    fonts["body"] = (base_family, 11)
    fonts["body_bold"] = (base_family, 11, "bold")
    fonts["body_italic"] = (base_family, 11, "italic")
    fonts["small"] = (base_family, 9)
    fonts["button"] = (base_family, 10, "bold")
    fonts["mono"] = (mono_family, 10)
    fonts["mono_bold"] = (mono_family, 10, "bold")
    
    return fonts

def apply_theme(root, style):
    """Apply the active theme to a ttk.Style and root window"""
    theme = ACTIVE_THEME
    
    # Root window background
    root.configure(background=theme["bg_light"])
    
    # Use a theme with better support for customization if available
    available_themes = style.theme_names()
    if 'clam' in available_themes:
        style.theme_use('clam')
    
    # Configure style for various elements
    # Frames
    style.configure('TFrame', background=theme["bg_light"])
    style.configure('Card.TFrame', 
                   background=theme["card_bg"],
                   borderwidth=0, 
                   relief="solid")
    
    # Labels
    style.configure('TLabel', 
                   background=theme["bg_light"],
                   foreground=theme["text_dark"])
    
    style.configure('Primary.TLabel', 
                   foreground=theme["primary_dark"])
    
    style.configure('Secondary.TLabel', 
                   foreground=theme["secondary"])
    
    style.configure('Title.TLabel', 
                   foreground=theme["text_dark"],
                   font=setup_fonts()["h2"])
    
    style.configure('Subtitle.TLabel', 
                   foreground=theme["text_medium"],
                   font=setup_fonts()["subtitle"])
                   
    style.configure('WhiteOnPrimary.TLabel',
                   background=theme["primary"],
                   foreground=theme["text_light"])
    
    # Buttons
    style.configure('TButton', 
                   background=theme["bg_light"],
                   foreground=theme["text_dark"])
    
    style.map('TButton',
             background=[('active', theme["bg_medium"]), 
                        ('pressed', theme["border"])])
    
    style.configure('Primary.TButton',
                   background=theme["primary"],
                   foreground=theme["text_light"],
                   borderwidth=0,
                   font=setup_fonts()["button"])
    
    style.map('Primary.TButton',
             background=[('active', theme["primary_dark"]), 
                        ('pressed', theme["primary_dark"])])
    
    style.configure('Secondary.TButton',
                   background=theme["secondary"],
                   foreground=theme["text_light"],
                   borderwidth=0,
                   font=setup_fonts()["button"])
    
    style.map('Secondary.TButton',
             background=[('active', theme["secondary"]), 
                        ('pressed', theme["secondary"])])
    
    # Accent button
    style.configure('Accent.TButton',
                   background=theme["accent"],
                   foreground=theme["text_light"],
                   borderwidth=0,
                   font=setup_fonts()["button"])
    
    style.map('Accent.TButton',
             background=[('active', theme["accent"]), 
                        ('pressed', theme["accent"])])
    
    # Entries and Comboboxes
    style.configure('TEntry',
                   fieldbackground=theme["bg_light"],
                   foreground=theme["text_dark"],
                   bordercolor=theme["border"])
    
    style.map('TEntry',
             fieldbackground=[('focus', theme["bg_light"])],
             bordercolor=[('focus', theme["primary"])])
    
    style.configure('TCombobox',
                   fieldbackground=theme["bg_light"],
                   foreground=theme["text_dark"],
                   selectbackground=theme["primary"],
                   selectforeground=theme["text_light"],
                   bordercolor=theme["border"])
    
    # Notebooks (tabs)
    style.configure('TNotebook',
                   background=theme["bg_light"],
                   tabmargins=[2, 5, 2, 0])
    
    style.configure('TNotebook.Tab',
                   background=theme["bg_medium"],
                   foreground=theme["text_dark"],
                   padding=[10, 2])
    
    style.map('TNotebook.Tab',
             background=[('selected', theme["primary"])],
             foreground=[('selected', theme["text_light"])])
    
    # Progressbar
    style.configure("TProgressbar", 
                   troughcolor=theme["bg_medium"],
                   background=theme["primary"],
                   bordercolor=theme["border"],
                   lightcolor=theme["primary"],
                   darkcolor=theme["primary_dark"])
    
    # Configure Text and ScrolledText widgets via root (since they're not ttk)
    root.option_add('*Text.background', theme["bg_light"])
    root.option_add('*Text.foreground', theme["text_dark"])
    root.option_add('*Text.borderwidth', 1)
    root.option_add('*Text.relief', 'solid')
    
    # Configure other options
    root.option_add('*TEntry*Font', setup_fonts()["body"])
    root.option_add('*TCombobox*Font', setup_fonts()["body"])

def create_rounded_rectangle(canvas, x1, y1, x2, y2, radius=20, **kwargs):
    """Helper function to create a rounded rectangle on a canvas"""
    points = [
        x1 + radius, y1,
        x2 - radius, y1,
        x2, y1,
        x2, y1 + radius,
        x2, y2 - radius,
        x2, y2,
        x2 - radius, y2,
        x1 + radius, y2,
        x1, y2,
        x1, y2 - radius,
        x1, y1 + radius,
        x1, y1
    ]
    return canvas.create_polygon(points, **kwargs, smooth=True)

def create_card_frame(parent, padding=(15, 15), has_shadow=True):
    """Create a frame styled as a card with modern shadow effect"""
    outer_frame = ttk.Frame(parent, style='TFrame')
    
    # Create shadow effect if requested
    if has_shadow:
        # Create a canvas for the shadow effect
        shadow_color = ACTIVE_THEME["shadow"].replace("rgba", "").replace("(", "").replace(")", "").split(",")
        shadow_r = int(shadow_color[0])
        shadow_g = int(shadow_color[1])
        shadow_b = int(shadow_color[2])
        shadow_hex = f"#{shadow_r:02x}{shadow_g:02x}{shadow_b:02x}"
        
        shadow_frame = ttk.Frame(outer_frame, style='TFrame')
        shadow_frame.pack(fill="both", expand=True, padx=3, pady=3)
        
    # Create card with raised appearance
    card = ttk.Frame(shadow_frame if has_shadow else outer_frame, style='Card.TFrame', padding=padding)
    card.pack(fill="both", expand=True)
    
    # Apply border styling
    card.configure(borderwidth=1, relief="solid")
    
    return outer_frame

def add_tooltip(widget, text):
    """Add a tooltip to a widget on hover"""
    def show_tooltip(event):
        x, y, _, _ = widget.bbox("insert")
        x += widget.winfo_rootx() + 25
        y += widget.winfo_rooty() + 25
        
        # Create a toplevel window
        tooltip = tk.Toplevel(widget)
        tooltip.wm_overrideredirect(True)
        tooltip.wm_geometry(f"+{x}+{y}")
        
        # Create tooltip content with more attractive styling
        label = tk.Label(tooltip, text=text, background=ACTIVE_THEME["secondary"],
                        foreground=ACTIVE_THEME["text_light"], relief="solid",
                        borderwidth=1, padx=8, pady=3, font=('Segoe UI', 9))
        label.pack()
        
        widget.tooltip = tooltip
    
    def hide_tooltip(event):
        if hasattr(widget, "tooltip"):
            widget.tooltip.destroy()
    
    widget.bind("<Enter>", show_tooltip)
    widget.bind("<Leave>", hide_tooltip) 