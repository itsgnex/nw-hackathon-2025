# Poki Buddy 🏡👹

Poki Buddy is a fun and gamified task management application designed to make chores and shared responsibilities more engaging. Built with Flutter, it combines a shared to-do list with a Pokémon-themed progression system, where users can earn XP, compete on a leaderboard, and evolve their partner Pokémon.

This app is designed as a frontend-only prototype, using an in-memory state management solution (`provider`) to simulate a live, multi-user environment without the need for a backend database or authentication service.

## ✨ Features

Poki Buddy is packed with features designed to encourage collaboration and friendly competition:

### Core Gameplay Loop
- **🏡 Shared Homes:** Users can create a new "Home" or join an existing one using a unique, shareable code.
- **✅ Quest System:** Assign tasks (Quests) to different members of the home, complete with XP rewards and due dates.
- **🏆 Leaderboard:** A live leaderboard ranks all home members by their "All-Time XP," fostering friendly competition. The board also displays each user's progress towards their next Pokémon evolution.
- **👹 Partner Pokémon:** New users choose a starter Pokémon that represents them throughout the app, including on the leaderboard and their profile icon.

### Character & Progression
- **📜 Full Pokédex Search:** The character selection screen features a dynamic search bar, allowing users to search the entire Pokédex by name or ID to choose their partner.
- **🐾 Pokémon Evolution:** By earning 500 XP from completing quests, users can evolve their partner Pokémon to its next stage. The evolution option appears automatically on their profile page when ready.
- **📊 Trainer Stats:** The profile page includes a "Trainer Stats" card showing a user's All-Time and Weekly XP.
- **📖 Task History:** Users can view a complete history of all the quests they have completed from their profile page.

### Shared Living Management
- **🛒 Shared Shopping List:** A collaborative grocery list where members can add items to be purchased.
- **💸 Bill Splitting:** A comprehensive bill management system where users can add a bill, specify the total amount, and select which members to split it with.
- **💰 Money Summary:** The profile page includes a "Money Summary" that automatically calculates and displays how much money you owe others and how much others owe you, based on the shared bills.

### User & Profile
- **✏️ Editable Profile:** Users can edit their trainer name directly from their profile page.
- **🎨 Themed UI:** The entire application features a consistent, Pokémon-inspired theme with a custom image background and themed UI elements.

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **API:** [PokéAPI](https://pokeapi.co/) (for Pokémon data and sprites)
- **Language:** [Dart](https://dart.dev/)

*Note: This project does not use any external databases or authentication services. All data is managed in-memory and will reset when the app is fully closed.*

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- You must have Flutter installed on your machine. For installation instructions, see the [official Flutter documentation](https://flutter.dev/docs/get-started/install).

### Installation

1. **Clone the repository:**
   