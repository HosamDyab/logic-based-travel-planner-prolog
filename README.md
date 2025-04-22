# 🏛️ Egyptian Travel Planner

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![SWI-Prolog](https://img.shields.io/badge/SWI--Prolog-8.0+-orange.svg)](https://www.swi-prolog.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern desktop application for planning your perfect Egyptian vacation. Using advanced AI techniques through Prolog, this app creates personalized travel itineraries based on your preferences.

![Egyptian Travel Planner Screenshot](screenshot.png) *(Add your screenshot here)*

## ✨ Features

- 🗺️ **Smart Trip Planning**: Generate customized travel plans for major Egyptian cities
- 🏨 **Hotel Recommendations**: Get hotel suggestions based on your budget and preferences
- 🚗 **Transportation Options**: Find the best ways to get around at your destination
- 🏛️ **Activity Scheduling**: Discover the best attractions with optimized daily itineraries
- 💰 **Budget Management**: Keep your travel expenses within your specified budget
- 📝 **Hotel Reviews**: Submit and view hotel reviews to make informed decisions
- 💾 **Plan Saving**: Save and print your travel plans for offline reference

## 🚀 Installation

### Prerequisites

- Python 3.8+
- SWI-Prolog 8.0+
- Tkinter (usually included with Python)
- PIL (Pillow)
- PySwip (Python interface to SWI-Prolog)

### Setup Instructions

1. **Clone the repository**
   ```
   git clone https://github.com/yourusername/egyptian-travel-planner.git
   cd egyptian-travel-planner
   ```

2. **Install Python dependencies**
   ```
   pip install -r requirements.txt
   ```

3. **Ensure SWI-Prolog is installed**
   - Download from [SWI-Prolog website](https://www.swi-prolog.org/download/stable)
   - Make sure it's added to your system PATH

4. **Run the application**
   ```
   python travel_gui.py
   ```

## 📖 How to Use

### Planning a Trip

1. Fill in your travel details in the main form:
   - Your name
   - Destination city
   - Trip duration
   - Travel month
   - Daily activity hours
   - Group size
   - Budget range

2. Click "Generate Plan" or press Ctrl+G

3. Review your personalized travel plan, including:
   - Hotel recommendations
   - Transportation options
   - Daily activities with times and costs
   - Total budget breakdown

4. Save or print your plan using the buttons or keyboard shortcuts (Ctrl+S to save, Ctrl+P to print)

### Managing Hotels

Use the "Hotel Management" tab to:

- **Submit Reviews**: Share your experience at Egyptian hotels with ratings and comments
- **Update Hotel Information**: Update hotel data such as names and prices (admin feature)

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Ctrl+G   | Generate plan |
| Ctrl+S   | Save plan to file |
| Ctrl+P   | Print plan |
| Ctrl+Tab | Switch tabs |
| Alt+R    | Submit review |
| Alt+U    | Update hotel |
| Esc      | Exit application |

## 🧠 Technical Details

The Egyptian Travel Planner uses a hybrid architecture:

- **Frontend**: Python with Tkinter for the graphical user interface
- **Backend**: SWI-Prolog for the logical reasoning and travel planning algorithms
- **Integration**: PySwip library to connect Python with Prolog

The application uses declarative logic programming to match travel preferences with available options and constraints.

## 📋 Requirements

See [requirements.txt](requirements.txt) for a complete list of dependencies.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



*Happy Travels!* 🐪✨ 