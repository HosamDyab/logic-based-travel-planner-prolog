import os
import sys
import json
import tempfile
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext, simpledialog, Toplevel, Listbox, filedialog
from PIL import Image, ImageTk
import subprocess
from pyswip import Prolog
import datetime
import time
import threading

# Import custom modules for advanced GUI features
from egypt_logo import create_egypt_logo
import themes

# Global variables and font definitions
entry_font = ('Segoe UI', 10)
text_font = ('Segoe UI', 9)
button_font = ('Segoe UI', 10)
welcome_text = """Welcome to the Egyptian Travel Planner!

This application helps you plan your perfect trip to Egypt.
Fill in your travel details in the form above and click "Generate Plan" to get started.

You can also:
• Submit hotel reviews to help other travelers
• Update hotel information if you notice changes
• Save or print your travel plans for future reference

Keyboard shortcuts:
• Ctrl+G: Generate plan
• Ctrl+S: Save plan
• Ctrl+P: Print plan
• Ctrl+Tab: Switch tabs
• Alt+R: Submit review
• Alt+U: Update hotel
• Ctrl+Tab: Switch tabs
• Esc: Exit application

Enjoy planning your Egyptian adventure!
"""

# --- Global Prolog Instance ---
PROLOG_FILE = "travel_planner_4_api.pl" # Make sure this matches your file name
prolog = None

# --- Initialization ---
def initialize_prolog():
    global prolog
    try:
        prolog = Prolog()
        prolog.consult(PROLOG_FILE)
        print(f"Successfully consulted {PROLOG_FILE}")
        return True
    except Exception as e:
        messagebox.showerror("Prolog Initialization Error",
                             f"Could not initialize SWI-Prolog or consult '{PROLOG_FILE}'.\n"
                             f"Ensure SWI-Prolog is installed and in PATH.\nError: {e}")
        return False

# --- Helper to decode bytes from Prolog results ---
def decode_bytes_recursive(item):
    """Recursively decodes bytes to strings in lists and dictionaries."""
    if isinstance(item, bytes):
        try:
            return item.decode('utf-8')
        except UnicodeDecodeError:
            return item.decode('latin-1') # Fallback encoding
    elif isinstance(item, dict):
        return {decode_bytes_recursive(k): decode_bytes_recursive(v) for k, v in item.items()}
    elif isinstance(item, list):
        return [decode_bytes_recursive(elem) for elem in item]
    else:
        return item # Keep numbers, etc., as they are

# --- Helper to run Prolog queries and handle results/errors ---
def run_prolog_query(query_string):
    """Runs a query, decodes results, handles errors."""
    if not prolog:
        messagebox.showerror("Error", "Prolog engine not initialized.")
        return None

    print(f"Running Query: {query_string}") # For debugging
    try:
        results = list(prolog.query(query_string))
        if results:
            # Assuming the last variable in the query holds the result dict
            result_key = query_string.split(',')[-1].strip().split(')')[0]
            # Decode bytes in the result structure
            decoded_result = decode_bytes_recursive(results[0][result_key])
            print(f"Query Result (Decoded): {decoded_result}") # Debugging
            return decoded_result
        else:
            # This might indicate a failure in Prolog predicate logic before the catch block
            print("Query succeeded but returned no results.") # Debugging
            return {"status": "error", "message": "Prolog query failed to produce a result."}
    except Exception as e:
        print(f"Prolog Error: {e}") # Debugging
        return {"status": "error", "message": f"Error during Prolog query: {e}"}

# --- Formatting Functions ---
def format_plan_results(plan_data):
    """Formats the plan dictionary into a readable string."""
    if not isinstance(plan_data, dict) or plan_data.get('status') != 'success':
        return f"Error or invalid plan data received:\n{plan_data}"

    output = f"=== TRAVEL PLAN FOR {plan_data['user_id']} ===\n"
    output += f"  Destination: {plan_data['city']} (Month: {plan_data['month']})\n"
    output += f"  Duration: {plan_data['duration']} days\n"
    output += f"  Group Size: {plan_data['group_size']}\n\n"

    hotel = plan_data['hotel']
    transport = plan_data['transport']
    food = plan_data['food']
    output += "=== SELECTIONS ===\n"
    output += f"  Hotel: {hotel['name']} (Rating: {hotel['rating']:.1f}, {hotel['price_per_night']} EGP/night)\n"
    output += f"  Transport: {transport['mode']} ({transport['cost']} EGP)\n"
    output += f"  Est. Daily Food Cost: {food['daily_cost']} EGP\n\n"

    # Recommendations
    recs = plan_data.get('recommendations', {})
    other_hotels = recs.get('other_hotels', [])
    if other_hotels:
        output += "=== OTHER HOTEL OPTIONS ===\n"
        for h in other_hotels:
            output += f"  - {h['name']} (Rating: {h.get('rating', 'N/A'):.1f}, {h['price']} EGP/night)\n"
        output += "\n"

    output += "=== COST ESTIMATE ===\n"
    total_hotel_cost = hotel['price_per_night'] * plan_data['duration']
    total_food_cost = food['daily_cost'] * plan_data['duration']
    total_activity_cost = sum(plan_data.get('daily_costs', [0])) # Sum costs per day
    output += f"  Hotel: {total_hotel_cost} EGP\n"
    output += f"  Activities: {total_activity_cost} EGP\n"
    output += f"  Transport: {transport['cost']} EGP\n"
    output += f"  Food: {total_food_cost} EGP\n"
    output += "  --------------------\n"
    output += f"  TOTAL: {plan_data['total_budget']} EGP\n"
    status_msg = {
        'ok': 'Fits within budget guidelines.',
        'under': 'Significantly under minimum desired budget.'
    }.get(plan_data['budget_status'], plan_data['budget_status']) # Handle unexpected status
    output += f"  Budget Status: {status_msg}\n\n"


    output += "=== DAILY ITINERARY & DETAILS ===\n"
    daily_activities = plan_data.get('daily_activities', [])
    daily_details = plan_data.get('daily_details', [])
    daily_costs = plan_data.get('daily_costs', [])

    if not daily_activities:
         output += "  No activities planned.\n"
    else:
        for day_num, activities in enumerate(daily_activities, 1):
            output += f"--- DAY {day_num} (Cost: {daily_costs[day_num-1] if day_num-1 < len(daily_costs) else 'N/A'} EGP) ---\n"
            if activities:
                # Find corresponding details for the day
                day_detail_list = daily_details[day_num-1] if day_num-1 < len(daily_details) else []
                details_dict = {d['name']: d for d in day_detail_list} # Map name to details dict

                for act_name in activities:
                    detail = details_dict.get(act_name)
                    if detail:
                        output += f"  - {detail['name']} ({detail['duration']} hrs, {detail['cost']} EGP)\n"
                    else:
                        output += f"  - {act_name} (Details missing)\n" # Fallback
            else:
                output += "  Rest day or no activities planned.\n"
            output += "\n" # Space between days

    return output


# --- GUI Actions ---
def generate_plan():
    """Gets inputs, calls Prolog plan_trip_api, displays results."""
    # Get inputs
    user_id = entry_user_id.get().strip()
    city = combo_city.get()
    duration_str = entry_duration.get()
    month = combo_month.get()
    max_hours_str = combo_max_hours.get()
    group_size_str = entry_group_size.get()
    min_budget_str = entry_min_budget.get()
    max_budget_str = entry_max_budget.get()

    # Basic Validation
    if not all([user_id, city, duration_str, month, max_hours_str, group_size_str, min_budget_str, max_budget_str]):
        messagebox.showerror("Input Error", "Please fill in all fields.")
        return
    try:
        duration = int(duration_str)
        max_hours = int(max_hours_str)
        group_size = int(group_size_str)
        min_budget = float(min_budget_str)
        max_budget = float(max_budget_str)
        if duration <= 0 or group_size <= 0 or min_budget < 0 or max_budget < min_budget:
            raise ValueError("Invalid numeric range.")
    except ValueError:
         messagebox.showerror("Input Error", "Invalid numeric input for Duration, Hours, Group Size, or Budgets. Ensure budgets are non-negative and Max >= Min.")
         return

    # Construct query (escape single quotes in UserID if necessary)
    safe_user_id = user_id.replace("'", "\\'")
    query = (f"plan_trip_api('{safe_user_id}', '{city}', {duration}, '{month}', {max_hours}, "
             f"{group_size}, {min_budget}, {max_budget}, PlanResult).")
    
    # Show loading animation
    loading_window, progress_bar = show_loading_animation(f"Generating travel plan for {city}...")
    
    # Use threading to prevent UI from freezing
    def query_thread():
        try:
            # Run the query
            result_data = run_prolog_query(query)
            
            # Schedule UI updates to run in the main thread
            root.after(0, lambda: process_results(result_data))
        except Exception as e:
            # Handle any unexpected errors
            root.after(0, lambda: handle_error(str(e)))
    
    def process_results(result_data):
        # Close loading dialog
        close_loading_animation(loading_window, progress_bar)
        
        # Clear previous results
        results_area.delete(1.0, tk.END)
        
        # Process and display results
        if result_data and isinstance(result_data, dict):
            if result_data.get('status') == 'success':
                formatted_plan = format_plan_results(result_data)
                results_area.insert(tk.END, formatted_plan)
                
                # Show a success indicator
                status_label.config(text="Plan generated successfully!", foreground=themes.ACTIVE_THEME["success"])
                root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
            else:
                error_msg = result_data.get('message', 'Unknown error occurred.')
                results_area.insert(tk.END, f"Planning Failed:\n{error_msg}")
                
                # Show error indicator
                status_label.config(text="Error generating plan", foreground=themes.ACTIVE_THEME["error"])
                root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
        else:
            results_area.insert(tk.END, f"Failed to get a valid response from Prolog.\nRaw result: {result_data}")
            status_label.config(text="Error communicating with Prolog", foreground=themes.ACTIVE_THEME["error"])
            root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
    
    def handle_error(error_message):
        # Close loading dialog
        close_loading_animation(loading_window, progress_bar)
        
        # Display the error
        messagebox.showerror("Error", f"An unexpected error occurred:\n{error_message}")
        status_label.config(text="Error occurred", foreground=themes.ACTIVE_THEME["error"])
        root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
    
    # Start the thread
    thread = threading.Thread(target=query_thread)
    thread.daemon = True  # This ensures the thread will exit when the main program does
    thread.start()


def open_review_window():
    """Submits a hotel review from the form"""
    # Get inputs directly from the form
    hotel = entry_hotel_name.get().strip()
    rating_str = entry_rating.get().strip()
    comment = text_comment.get("1.0", tk.END).strip()
    
    if not hotel or not rating_str or not comment:
        messagebox.showerror("Input Error", "Please fill all review fields.")
        return
    
    try:
        rating = float(rating_str)
        if not (0 <= rating <= 5):
            raise ValueError("Rating out of range.")
    except ValueError:
        messagebox.showerror("Input Error", "Rating must be a number between 0 and 5.")
        return

    user_id = entry_user_id.get().strip() or "AnonymousGUIUser" # Get UserID from main form or use default
    safe_hotel = hotel.replace("'", "\\'")
    safe_comment = comment.replace("'", "\\'")

    # Construct the query
    query = (f"submit_hotel_review_api('{user_id}', '{safe_hotel}', {rating}, '{safe_comment}', Result).")
    
    # Show loading animation
    loading_window, progress_bar = show_loading_animation("Submitting your review...")
    
    # Use threading to prevent UI from freezing
    def query_thread():
        try:
            # Run the query
            result_data = run_prolog_query(query)
            
            # Schedule UI updates to run in the main thread
            root.after(0, lambda: process_results(result_data))
        except Exception as e:
            # Handle any unexpected errors
            root.after(0, lambda: handle_error(str(e)))
    
    def process_results(result_data):
        # Close loading dialog
        close_loading_animation(loading_window, progress_bar)
        
        # Process and display results
        if result_data and isinstance(result_data, dict):
            status = result_data.get('status')
            message = result_data.get('message', 'No message received.')
            if status == 'success':
                messagebox.showinfo("Success", message)
                # Clear the form after successful submission
                entry_hotel_name.delete(0, tk.END)
                entry_rating.delete(0, tk.END)
                text_comment.delete(1.0, tk.END)
                
                # Show a success indicator
                status_label.config(text="Review submitted successfully!", foreground=themes.ACTIVE_THEME["success"])
                root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
            else:
                messagebox.showerror("Submission Failed", message)
                # Show error indicator
                status_label.config(text="Error submitting review", foreground=themes.ACTIVE_THEME["error"])
                root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
        else:
            messagebox.showerror("Error", "Failed to get response from Prolog.")
            status_label.config(text="Error communicating with Prolog", foreground=themes.ACTIVE_THEME["error"])
            root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
    
    def handle_error(error_message):
        # Close loading dialog
        close_loading_animation(loading_window, progress_bar)
        
        # Display the error
        messagebox.showerror("Error", f"An unexpected error occurred:\n{error_message}")
        status_label.config(text="Error occurred", foreground=themes.ACTIVE_THEME["error"])
        root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
    
    # Start the thread
    thread = threading.Thread(target=query_thread)
    thread.daemon = True  # This ensures the thread will exit when the main program does
    thread.start()


def open_update_hotel_window():
    """Updates hotel information from the form"""
    # Get inputs directly from the form
    city = combo_upd_city.get()
    old_name = entry_old_name.get().strip()
    new_name = entry_new_name.get().strip()
    new_price_str = entry_new_price.get().strip()

    if not all([city, old_name, new_name, new_price_str]):
        messagebox.showerror("Input Error", "Please fill all fields.")
        return
    
    try:
        new_price = float(new_price_str)
        if new_price <= 0:
            raise ValueError("Price must be positive.")
    except ValueError:
        messagebox.showerror("Input Error", "New Price must be a positive number.")
        return

    user_id = entry_user_id.get().strip() or "AdminGUIUser" # Get UserID or use default
    safe_old = old_name.replace("'", "\\'")
    safe_new = new_name.replace("'", "\\'")
    
    # Construct the query
    query = (f"update_hotel_api('{user_id}', '{city}', '{safe_old}', '{safe_new}', {new_price}, Result).")
    
    # Show loading animation
    loading_window, progress_bar = show_loading_animation("Updating hotel information...")
    
    # Use threading to prevent UI from freezing
    def query_thread():
        try:
            # Run the query
            result_data = run_prolog_query(query)
            
            # Schedule UI updates to run in the main thread
            root.after(0, lambda: process_results(result_data))
        except Exception as e:
            # Handle any unexpected errors
            root.after(0, lambda: handle_error(str(e)))
    
    def process_results(result_data):
        # Close loading dialog
        close_loading_animation(loading_window, progress_bar)
        
        # Process and display results
        if result_data and isinstance(result_data, dict):
            status = result_data.get('status')
            message = result_data.get('message', 'No message received.')
            if status == 'success':
                messagebox.showinfo("Success", message)
                # Clear the form after successful submission
                entry_old_name.delete(0, tk.END)
                entry_new_name.delete(0, tk.END)
                entry_new_price.delete(0, tk.END)
                
                # Show a success indicator
                status_label.config(text="Hotel updated successfully!", foreground=themes.ACTIVE_THEME["success"])
                root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
            else:
                messagebox.showerror("Update Failed", message)
                # Show error indicator
                status_label.config(text="Error updating hotel", foreground=themes.ACTIVE_THEME["error"])
                root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
        else:
            messagebox.showerror("Error", "Failed to get response from Prolog.")
            status_label.config(text="Error communicating with Prolog", foreground=themes.ACTIVE_THEME["error"])
            root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
    
    def handle_error(error_message):
        # Close loading dialog
        close_loading_animation(loading_window, progress_bar)
        
        # Display the error
        messagebox.showerror("Error", f"An unexpected error occurred:\n{error_message}")
        status_label.config(text="Error occurred", foreground=themes.ACTIVE_THEME["error"])
        root.after(3000, lambda: status_label.config(text="", foreground=themes.ACTIVE_THEME["text_dark"]))
    
    # Start the thread
    thread = threading.Thread(target=query_thread)
    thread.daemon = True  # This ensures the thread will exit when the main program does
    thread.start()

# --- Loading Animation ---
def show_loading_animation(message="Processing..."):
    """Show a loading animation with a progress bar"""
    # Create a loading window
    loading_window = Toplevel(root)
    loading_window.title("Loading")
    
    # Calculate position (center of main window)
    x = root.winfo_x() + (root.winfo_width() // 2) - 150
    y = root.winfo_y() + (root.winfo_height() // 2) - 50
    loading_window.geometry(f"300x100+{x}+{y}")
    
    # Set window properties
    loading_window.resizable(False, False)
    loading_window.transient(root)
    loading_window.grab_set()
    
    # Configure appearance based on current theme
    loading_window.configure(bg=themes.ACTIVE_THEME["bg_light"])
    
    # Add message
    message_label = ttk.Label(loading_window, text=message)
    message_label.pack(pady=(15, 10))
    
    # Add progress bar
    progress_bar = ttk.Progressbar(loading_window, mode="indeterminate", length=250)
    progress_bar.pack(pady=5)
    root.progress_bar = progress_bar  # Store reference
    
    # Start progress animation
    progress_bar.start(10)
    
    # Update the window
    loading_window.update()
    
    return loading_window, progress_bar

def close_loading_animation(loading_window, progress_bar):
    """Close the loading animation"""
    if progress_bar:
        progress_bar.stop()
    if loading_window:
        loading_window.grab_release()
        loading_window.destroy()

# --- File Operations ---
def save_plan_to_file():
    """Save the current trip plan to a text file"""
    plan_text = results_area.get("1.0", tk.END)
    if not plan_text.strip() or plan_text.strip() == welcome_text.strip():
        messagebox.showinfo("Nothing to Save", "Generate a trip plan first before saving.")
        return
        
    # Get default filename based on traveler name and date
    traveler = entry_user_id.get().strip()
    date_str = datetime.datetime.now().strftime("%Y%m%d")
    default_filename = f"{traveler}_TripPlan_{date_str}.txt"
    
    # Ask user where to save the file
    file_path = filedialog.asksaveasfilename(
        defaultextension=".txt",
        filetypes=[("Text files", "*.txt"), ("All files", "*.*")],
        initialfile=default_filename,
        title="Save Trip Plan"
    )
    
    # Save the file if user didn't cancel
    if file_path:
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(plan_text)
            messagebox.showinfo("Success", f"Trip plan saved to:\n{file_path}")
        except Exception as e:
            messagebox.showerror("Error Saving File", f"Could not save file:\n{e}")

def print_plan():
    """Print the current trip plan"""
    plan_text = results_area.get("1.0", tk.END)
    if not plan_text.strip() or plan_text.strip() == welcome_text.strip():
        messagebox.showinfo("Nothing to Print", "Generate a trip plan first before printing.")
        return
        
    # Create a temporary file to print from
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix='.txt', mode='w', encoding='utf-8') as temp:
            temp_path = temp.name
            temp.write(plan_text)
        
        # Open with default text editor which can handle printing
        if sys.platform == 'win32':
            os.startfile(temp_path, 'print')
        else:
            # Other platforms might need different approaches
            subprocess.call(['xdg-open', temp_path])
            
        messagebox.showinfo("Print", "The print dialog should have opened.\nThe temporary file will be cleaned up later.")
    except Exception as e:
        messagebox.showerror("Print Error", f"Could not print the plan:\n{e}")

# --- Splash Screen ---
def show_splash_screen():
    """Show a splash screen with the Egypt logo while loading"""
    splash = Toplevel(root)
    splash.title("Loading")
    splash.overrideredirect(True)  # Remove window decorations
    
    # Set position to center of screen
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    splash_width = 400
    splash_height = 300
    x = (screen_width - splash_width) // 2
    y = (screen_height - splash_height) // 2
    splash.geometry(f"{splash_width}x{splash_height}+{x}+{y}")
    
    # Configure background
    splash.configure(bg=themes.ACTIVE_THEME["bg_light"])
    
    # Add logo
    try:
        logo_img = create_egypt_logo(size=120)
        logo_label = ttk.Label(splash, image=logo_img, background=themes.ACTIVE_THEME["bg_light"])
        logo_label.image = logo_img  # Keep a reference
        logo_label.pack(pady=(40, 20))
    except:
        # Fallback if logo fails
        pass
    
    # Add app name
    app_name = ttk.Label(splash, text="Egyptian Travel Planner", font=('Segoe UI', 18, 'bold'),
                        foreground=themes.ACTIVE_THEME["primary_dark"], background=themes.ACTIVE_THEME["bg_light"])
    app_name.pack(pady=(0, 10))
    
    # Add loading text
    loading_label = ttk.Label(splash, text="Loading...", font=('Segoe UI', 10),
                            foreground=themes.ACTIVE_THEME["text_medium"], background=themes.ACTIVE_THEME["bg_light"])
    loading_label.pack(pady=(0, 20))
    
    # Add progress bar
    progress = ttk.Progressbar(splash, length=300, mode='indeterminate')
    progress.pack(pady=10)
    progress.start(10)
    
    # Update the window
    splash.update()
    
    return splash, progress

# --- Keyboard Shortcuts ---
def setup_keyboard_shortcuts():
    """Setup keyboard shortcuts for common actions"""
    # Generate travel plan - Ctrl+G
    root.bind('<Control-g>', lambda event: generate_plan())
    
    # Save plan - Ctrl+S
    root.bind('<Control-s>', lambda event: save_plan_to_file())
    
    # Print plan - Ctrl+P
    root.bind('<Control-p>', lambda event: print_plan())
    
    # Switch between tabs - Ctrl+Tab
    root.bind('<Control-Tab>', lambda event: notebook.select((notebook.index(notebook.select()) + 1) % notebook.index('end')))
    
    # Submit review - Alt+R
    root.bind('<Alt-r>', lambda event: open_review_window())
    
    # Update hotel - Alt+U
    root.bind('<Alt-u>', lambda event: open_update_hotel_window())
    
    # Close application - Escape
    root.bind('<Escape>', lambda event: root.destroy() if messagebox.askyesno("Exit", "Are you sure you want to exit?") else None)

# --- Main GUI Setup ---
if not initialize_prolog():
     sys.exit("Exiting due to Prolog initialization failure.") # Exit if Prolog fails

root = tk.Tk()
root.title("Egyptian Travel Planner")
root.geometry("1000x750") # Wider and taller window for more content
root.minsize(800, 650)

# Initialize style and apply theme
style = ttk.Style(root)

# Show splash screen
splash, splash_progress = show_splash_screen()

try:
    themes.apply_theme(root, style)
    fonts = themes.setup_fonts()
    has_custom_theme = True
except NameError:
    # Fallback if theme module is not available
    has_custom_theme = False
    fonts = {
        "title": ('Segoe UI', 14, 'bold'),
        "header": ('Segoe UI', 12, 'bold'),
        "body": ('Segoe UI', 10),
        "mono": ('Consolas', 10)
    }
    # Basic styling fallback
    root.configure(bg="#f5f5f5")

# Set up the rest of the UI, this can be simulated with a short delay
def finish_setup():
    global notebook, results_area, entry_user_id, combo_city, entry_duration, combo_month
    global combo_max_hours, entry_group_size, entry_min_budget, entry_max_budget
    global status_label, entry_hotel_name, entry_rating, text_comment
    global combo_upd_city, entry_old_name, entry_new_name, entry_new_price
    
    # Main container frame with padding
    main_frame = ttk.Frame(root, padding=15)
    main_frame.pack(fill="both", expand=True)

    # Modern header with logo
    header_frame = ttk.Frame(main_frame)
    header_frame.pack(fill="x", pady=(0, 15))

    # Left side - title and subtitle
    title_container = ttk.Frame(header_frame)
    title_container.pack(side=tk.LEFT, fill="y")

    if has_custom_theme:
        title_label = ttk.Label(title_container, text="Egyptian Travel Planner", style="Title.TLabel")
        subtitle_label = ttk.Label(title_container, text="Your Ultimate Egypt Vacation Guide", style="Subtitle.TLabel")
    else:
        title_label = ttk.Label(title_container, text="Egyptian Travel Planner", 
                              font=fonts["title"], background="#f5f5f5")
        subtitle_label = ttk.Label(title_container, text="Your Ultimate Egypt Vacation Guide", 
                                font=fonts["subtitle"], background="#f5f5f5")

    title_label.pack(anchor=tk.W)
    subtitle_label.pack(anchor=tk.W)

    # Right side - controls and logo
    controls_frame = ttk.Frame(header_frame)
    controls_frame.pack(side=tk.RIGHT, fill="y")

    # App logo
    try:
        # Use our custom Egypt logo
        logo_img = create_egypt_logo(size=70)  # Larger logo
        logo_label = ttk.Label(controls_frame, image=logo_img, background=themes.ACTIVE_THEME["bg_light"])
        logo_label.image = logo_img  # Keep a reference
        root.logo_label = logo_label  # Store reference for theme updates
        logo_label.pack(side=tk.RIGHT, padx=10)
    except NameError:
        # Fallback if logo module is not available
        print("Custom logo not available. Using text-only header.")

    # Content area with tabs
    content_frame = ttk.Frame(main_frame)
    content_frame.pack(fill="both", expand=True)

    # Create a notebook (tabbed interface)
    notebook = ttk.Notebook(content_frame)
    notebook.pack(fill="both", expand=True, padx=5, pady=5)

    # Tab 1: Trip Planner
    planner_frame = ttk.Frame(notebook, padding=10)
    notebook.add(planner_frame, text="Plan Your Trip")

    # Input Frame - use card style if available
    if has_custom_theme:
        input_frame = themes.create_card_frame(planner_frame)
    else:
        input_frame = ttk.LabelFrame(planner_frame, text="Trip Details")
    input_frame.pack(fill="x", padx=5, pady=10)

    # Create two column frames inside the input_frame for better organization
    left_column = ttk.Frame(input_frame, padding=10)
    left_column.pack(side=tk.LEFT, fill="both", expand=True)

    right_column = ttk.Frame(input_frame, padding=10)
    right_column.pack(side=tk.RIGHT, fill="both", expand=True)

    # Left column widgets
    ttk.Label(left_column, text="Traveler Name:", style="Secondary.TLabel" if has_custom_theme else "").grid(row=0, column=0, padx=8, pady=8, sticky="w")
    entry_user_id = ttk.Entry(left_column, width=20, font=fonts["body"])
    entry_user_id.grid(row=0, column=1, padx=8, pady=8, sticky="ew")
    if has_custom_theme:
        themes.add_tooltip(entry_user_id, "Enter your name or a nickname for the travel plan")

    ttk.Label(left_column, text="Duration (days):", style="Secondary.TLabel" if has_custom_theme else "").grid(row=1, column=0, padx=8, pady=8, sticky="w")
    entry_duration = ttk.Entry(left_column, width=20, font=fonts["body"])
    entry_duration.grid(row=1, column=1, padx=8, pady=8, sticky="ew")
    if has_custom_theme:
        themes.add_tooltip(entry_duration, "Number of days you plan to stay")

    ttk.Label(left_column, text="Daily Activity Hours:", style="Secondary.TLabel" if has_custom_theme else "").grid(row=2, column=0, padx=8, pady=8, sticky="w")
    combo_max_hours = ttk.Combobox(left_column, values=["4", "6", "8", "10"], width=18, state="readonly", font=fonts["body"])
    combo_max_hours.grid(row=2, column=1, padx=8, pady=8, sticky="ew")
    combo_max_hours.current(1) # Default to 6
    if has_custom_theme:
        themes.add_tooltip(combo_max_hours, "How many hours of activities you want each day")

    ttk.Label(left_column, text="Min Budget (EGP):", style="Secondary.TLabel" if has_custom_theme else "").grid(row=3, column=0, padx=8, pady=8, sticky="w")
    entry_min_budget = ttk.Entry(left_column, width=20, font=fonts["body"])
    entry_min_budget.grid(row=3, column=1, padx=8, pady=8, sticky="ew")
    if has_custom_theme:
        themes.add_tooltip(entry_min_budget, "Minimum budget in Egyptian Pounds")

    # Right column widgets
    ttk.Label(right_column, text="Destination:", style="Secondary.TLabel" if has_custom_theme else "").grid(row=0, column=0, padx=8, pady=8, sticky="w")
    combo_city = ttk.Combobox(right_column, values=["Cairo", "Aswan", "PortSaid"], width=18, state="readonly", font=fonts["body"])
    combo_city.grid(row=0, column=1, padx=8, pady=8, sticky="ew")
    combo_city.current(0)
    if has_custom_theme:
        themes.add_tooltip(combo_city, "Select your destination city in Egypt")

    ttk.Label(right_column, text="Travel Month:", style="Secondary.TLabel" if has_custom_theme else "").grid(row=1, column=0, padx=8, pady=8, sticky="w")
    months = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
              'August', 'September', 'October', 'November', 'December']
    combo_month = ttk.Combobox(right_column, values=months, width=18, state="readonly", font=fonts["body"])
    combo_month.grid(row=1, column=1, padx=8, pady=8, sticky="ew")
    combo_month.current(0)
    if has_custom_theme:
        themes.add_tooltip(combo_month, "Month you plan to visit")

    ttk.Label(right_column, text="Group Size:", style="Secondary.TLabel" if has_custom_theme else "").grid(row=2, column=0, padx=8, pady=8, sticky="w")
    entry_group_size = ttk.Entry(right_column, width=20, font=fonts["body"])
    entry_group_size.grid(row=2, column=1, padx=8, pady=8, sticky="ew")
    if has_custom_theme:
        themes.add_tooltip(entry_group_size, "Number of people traveling")

    ttk.Label(right_column, text="Max Budget (EGP):", style="Secondary.TLabel" if has_custom_theme else "").grid(row=3, column=0, padx=8, pady=8, sticky="w")
    entry_max_budget = ttk.Entry(right_column, width=20, font=fonts["body"])
    entry_max_budget.grid(row=3, column=1, padx=8, pady=8, sticky="ew")
    if has_custom_theme:
        themes.add_tooltip(entry_max_budget, "Maximum budget in Egyptian Pounds")

    # Set reasonable defaults for quicker testing
   
    # Action Buttons Frame
    actions_frame = ttk.Frame(planner_frame)
    actions_frame.pack(pady=12, fill="x")

    # Left aligned buttons
    btn_actions_left = ttk.Frame(actions_frame)
    btn_actions_left.pack(side=tk.LEFT)

    if has_custom_theme:
        btn_plan = ttk.Button(btn_actions_left, text="Generate Plan", command=generate_plan, style="Primary.TButton")
    else:
        btn_plan = ttk.Button(btn_actions_left, text="Generate Plan", command=generate_plan)
    btn_plan.pack(side=tk.LEFT, padx=5)

    # Add keyboard shortcut hint
    if has_custom_theme:
        shortcut_label = ttk.Label(btn_actions_left, text="(Ctrl+G)", style="Secondary.TLabel")
        shortcut_label.pack(side=tk.LEFT, padx=5)

    # Right aligned status
    status_frame = ttk.Frame(actions_frame)
    status_frame.pack(side=tk.RIGHT)

    if has_custom_theme:
        status_label = ttk.Label(status_frame, text="", style="Secondary.TLabel")
    else:
        status_label = ttk.Label(status_frame, text="")
    status_label.pack(padx=5)

    # Results Area - Card style for results
    if has_custom_theme:
        results_frame = themes.create_card_frame(planner_frame)
        results_header = ttk.Frame(results_frame)
        results_header.pack(fill="x", padx=10, pady=(10, 0))
        
        # Results title with icon
        ttk.Label(results_header, text="Trip Plan Results", style="Title.TLabel").pack(side=tk.LEFT)
        
        # Add save/print buttons
        btn_actions = ttk.Frame(results_header)
        btn_actions.pack(side=tk.RIGHT)
        
        btn_save = ttk.Button(btn_actions, text="Save Plan", command=save_plan_to_file, style="Secondary.TButton")
        btn_save.pack(side=tk.LEFT, padx=5)
        
        btn_print = ttk.Button(btn_actions, text="Print", command=print_plan, style="Secondary.TButton")
        btn_print.pack(side=tk.LEFT, padx=5)
    else:
        results_frame = ttk.LabelFrame(planner_frame, text="Generated Plan / Output")
    results_frame.pack(padx=5, pady=5, fill="both", expand=True)

    # Configure a more attractive font for the results
    if has_custom_theme:
        results_area = scrolledtext.ScrolledText(results_frame, wrap=tk.WORD, width=80, height=20, 
                                               font=fonts["mono"], bg=themes.ACTIVE_THEME["bg_light"])
    else:
        results_area = scrolledtext.ScrolledText(results_frame, wrap=tk.WORD, width=80, height=20, 
                                               font=fonts["mono"], bg="white", bd=0)
    results_area.pack(fill="both", expand=True, padx=10, pady=10)

    # Tab 2: Hotel Management
    hotel_frame = ttk.Frame(notebook, padding=10)
    notebook.add(hotel_frame, text="Hotel Management")

    # Hotel management container with two cards side by side
    hotel_container = ttk.Frame(hotel_frame)
    hotel_container.pack(fill="both", expand=True)

    # Hotel Review Card
    if has_custom_theme:
        review_frame = themes.create_card_frame(hotel_container)
        ttk.Label(review_frame, text="Submit a Hotel Review", style="Title.TLabel").pack(anchor="w", pady=(0, 10))
    else:
        review_frame = ttk.LabelFrame(hotel_container, text="Submit a Hotel Review")
    review_frame.pack(side=tk.LEFT, fill="both", expand=True, padx=(0, 5), pady=5)

    review_content = ttk.Frame(review_frame, padding=10)
    review_content.pack(fill="both", expand=True)

    ttk.Label(review_content, text="Hotel Name:", style="Secondary.TLabel" if has_custom_theme else "").grid(
        row=0, column=0, padx=8, pady=8, sticky="w")
    entry_hotel_name = ttk.Entry(review_content, width=30, font=fonts["body"])
    entry_hotel_name.grid(row=0, column=1, padx=8, pady=8, sticky="ew")

    ttk.Label(review_content, text="Rating (0-5):", style="Secondary.TLabel" if has_custom_theme else "").grid(
        row=1, column=0, padx=8, pady=8, sticky="w")
    entry_rating = ttk.Entry(review_content, width=5, font=fonts["body"])
    entry_rating.grid(row=1, column=1, padx=8, pady=8, sticky="w")

    ttk.Label(review_content, text="Comment:", style="Secondary.TLabel" if has_custom_theme else "").grid(
        row=2, column=0, padx=8, pady=8, sticky="nw")
    text_comment = scrolledtext.ScrolledText(review_content, width=30, height=5, wrap=tk.WORD, font=fonts["body"])
    text_comment.grid(row=2, column=1, padx=8, pady=8, sticky="ew")

    btn_frame = ttk.Frame(review_content)
    btn_frame.grid(row=3, column=1, pady=10, sticky="e")

    if has_custom_theme:
        btn_submit_review = ttk.Button(btn_frame, text="Submit Review", command=open_review_window, style="Secondary.TButton")
    else:
        btn_submit_review = ttk.Button(btn_frame, text="Submit Review", command=open_review_window)
    btn_submit_review.pack()

    # Hotel Update Card
    if has_custom_theme:
        update_frame = themes.create_card_frame(hotel_container)
        ttk.Label(update_frame, text="Update Hotel Information", style="Title.TLabel").pack(anchor="w", pady=(0, 10))
    else:
        update_frame = ttk.LabelFrame(hotel_container, text="Update Hotel Information")
    update_frame.pack(side=tk.RIGHT, fill="both", expand=True, padx=(5, 0), pady=5)

    update_content = ttk.Frame(update_frame, padding=10)
    update_content.pack(fill="both", expand=True)

    ttk.Label(update_content, text="City:", style="Secondary.TLabel" if has_custom_theme else "").grid(
        row=0, column=0, padx=8, pady=8, sticky="w")
    combo_upd_city = ttk.Combobox(update_content, values=["Cairo", "Aswan", "PortSaid"], width=28, state="readonly", font=fonts["body"])
    combo_upd_city.grid(row=0, column=1, padx=8, pady=8, sticky="ew")
    combo_upd_city.current(0)

    ttk.Label(update_content, text="Current Hotel Name:", style="Secondary.TLabel" if has_custom_theme else "").grid(
        row=1, column=0, padx=8, pady=8, sticky="w")
    entry_old_name = ttk.Entry(update_content, width=30, font=fonts["body"])
    entry_old_name.grid(row=1, column=1, padx=8, pady=8, sticky="ew")

    ttk.Label(update_content, text="New Hotel Name:", style="Secondary.TLabel" if has_custom_theme else "").grid(
        row=2, column=0, padx=8, pady=8, sticky="w")
    entry_new_name = ttk.Entry(update_content, width=30, font=fonts["body"])
    entry_new_name.grid(row=2, column=1, padx=8, pady=8, sticky="ew")

    ttk.Label(update_content, text="New Price (EGP):", style="Secondary.TLabel" if has_custom_theme else "").grid(
        row=3, column=0, padx=8, pady=8, sticky="w")
    entry_new_price = ttk.Entry(update_content, width=10, font=fonts["body"])
    entry_new_price.grid(row=3, column=1, padx=8, pady=8, sticky="w")

    btn_frame_update = ttk.Frame(update_content)
    btn_frame_update.grid(row=4, column=1, pady=10, sticky="e")

    if has_custom_theme:
        btn_update_hotel = ttk.Button(btn_frame_update, text="Update Hotel", command=open_update_hotel_window, style="Secondary.TButton")
    else:
        btn_update_hotel = ttk.Button(btn_frame_update, text="Update Hotel", command=open_update_hotel_window)
    btn_update_hotel.pack()

    # Status bar at the bottom
    status_bar = ttk.Frame(main_frame, relief=tk.SUNKEN, padding=(10, 5))
    status_bar.pack(side=tk.BOTTOM, fill=tk.X, pady=(10, 0))
    
    version_label = ttk.Label(status_bar, text="Egyptian Travel Planner v2.0", style="Secondary.TLabel" if has_custom_theme else "")
    version_label.pack(side=tk.LEFT)
    
    kbd_help = ttk.Label(status_bar, text="Keyboard Shortcuts: Ctrl+G (Generate), Ctrl+S (Save), Ctrl+P (Print)", 
                        style="Secondary.TLabel" if has_custom_theme else "")
    kbd_help.pack(side=tk.RIGHT)

    # Set up keyboard shortcuts
    setup_keyboard_shortcuts()
    
    # Initial welcome message
    results_area.insert(tk.END, welcome_text)

    # Close splash screen
    splash_progress.stop()
    splash.destroy()

# Simulate a delay to show the splash screen
root.after(2000, finish_setup)

# --- Run the Application ---
root.mainloop() 