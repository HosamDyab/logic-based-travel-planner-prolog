# Logic-based Travel Planner 🚀

![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)  
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![SWI-Prolog](https://img.shields.io/badge/SWI--Prolog-8.0+-orange.svg)](https://www.swi-prolog.org/)

**Welcome to the Logic-based Travel Planner**, an innovative solution leveraging **Prolog** to revolutionize travel planning with personalized, budget-friendly itineraries. Developed by the *TravelLogic Crew* for the *Logic Programming Course* at **Modern University for Technology & Information**, this project showcases modern logic programming techniques applied to real-world challenges.

---

## 🌟 Project Overview

The **Logic-based Travel Planner** automates travel planning by integrating **budget estimation**, **hotel recommendations**, **destination insights**, **transportation assistance**, and **activity discovery**. Built with **Prolog's declarative programming**, it offers a scalable, rule-based system that adapts to user preferences and constraints, transforming a traditionally tedious process into an efficient experience.

---

## 📋 Table of Contents

- [Problem Definition](#-problem-definition)
- [Project Description](#-project-description)
- [System Components](#-system-components)
- [Technical Features](#-technical-features)
- [Installation](#-installation)
- [How to Use](#-how-to-use)
- [Keyboard Shortcuts](#-keyboard-shortcuts)
- [Technical Details](#-technical-details)
- [References](#-references)
- [License](#-license)

---

## 🧩 Problem Definition

Before **logic-based systems** like *Prolog*, travel planning was a daunting task. Travelers struggled with **trustworthy recommendations**, **accurate budgeting**, and accessing **destination details** (e.g., landmarks, cultural sites). Upon arrival, challenges like selecting **budget-friendly hotels**, arranging **transportation**, and planning **activities** (e.g., shopping, cinema, museum tours) added complexity. The **Logic-based Travel Planner** addresses these pain points with an **automated**, *intelligent framework* that optimizes decision-making and enhances the travel experience.

---

## 📝 Project Description

The **Logic-based Travel Planner** redefines travel planning with **customized itineraries** powered by **Prolog**. It calculates **budgets**, recommends **hotels**, and provides **destination insights**, all while ensuring a *seamless* user experience through a Python GUI interface.

---

## ✨ System Components

- **Knowledge Base**:  
  - `city/1`: e.g., `cairo`, `aswan`.  
  - `attraction/2`: e.g., `attraction(cairo, pyramids)`.  
  - `hotel/4`: e.g., `hotel(cairo, 'four_seasons', 2000, 4.8)`.  
  - `transport/3`: e.g., `transport(cairo, car, 500)`.  
  - `activity/3`: e.g., `activity(cairo, shopping, 300)`.  
  - *Scalable* with modular design for future enhancements (e.g., user reviews).

- **Inference Engine**:  
  - Uses **Prolog's unification** and *backtracking* for efficient rule execution.

- **Interface Layer**:  
  - Modern **GUI** built with Python and Tkinter.

---

## 🚀 Technical Features

1. **Budget Estimation**: Aggregates costs (hotel, transport, food, activities).  
2. **Hotel Recommendations**: Filters hotels by budget and rating.
3. **Destination Information**: Provides details about landmarks and cultural sites.
4. **Transportation Assistance**: Matches transportation options to cities with cost optimization.
5. **Personalized Recommendations**: Creates tailored travel plans.
6. **Activity Discovery**: Maps activities to user interests.

---

## 📥 Installation

### Prerequisites

- Python 3.8+
- SWI-Prolog 8.0+
- Tkinter (usually included with Python)
- PIL (Pillow)
- PySwip (Python interface to SWI-Prolog)

### Setup Instructions

1. **Clone the repository**
   ```
   git clone https://github.com/HosamDyab/logic-based-travel-planner-prolog.git
   cd logic-based-travel-planner-prolog
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

---

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

4. Save or print your plan using the buttons or keyboard shortcuts

### Managing Hotels

Use the "Hotel Management" tab to:

- **Submit Reviews**: Share your experience at hotels with ratings and comments
- **Update Hotel Information**: Update hotel data such as names and prices (admin feature)

---

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

---

## 🧠 Technical Details

The Logic-based Travel Planner uses a hybrid architecture:

- **Frontend**: Python with Tkinter for the graphical user interface
- **Backend**: SWI-Prolog for the logical reasoning and travel planning algorithms
- **Integration**: PySwip library to connect Python with Prolog

The application uses declarative logic programming to match travel preferences with available options and constraints.

---

## 📚 References

* Booch, G., Rumbaugh, J., & Jacobson, I. (2005). The Unified Modeling Language User Guide (2nd ed.). Addison-Wesley.
* Bratko, I. (2012). Prolog Programming for Artificial Intelligence (4th ed.). Addison-Wesley.
* Object Management Group (OMG). (2023). UML Specification, Version 2.5.1\. <https://www.omg.org/spec/UML/2.5.1>
* SWI-Prolog. (2023). Documentation. <https://www.swi-prolog.org/>
* Sommerville, I. (2015). Software Engineering (10th ed.). Pearson.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Happy Travels!* 🐪✨
