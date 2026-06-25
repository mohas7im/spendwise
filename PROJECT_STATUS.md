# Spendwise Frontend - Project Status & Handover

This document summarizes the current state of the Spendwise Flutter frontend application to allow seamless handover to another developer or AI assistant.

## 🏗️ Architecture & Stack
- **Framework**: Flutter (Dart)
- **State Management**: `provider` (currently used for `ThemeProvider` to toggle Light/Dark mode).
- **Design System**: Completely custom UI matching a set of premium reference images. It utilizes a deep dark mode (`0xFF0F0F0F` background) and a clean light mode, with an Emerald Green (`0xFF10B981`) primary color.

## 📂 Folder Structure
The `lib/` directory is organized as follows:
- `models/`: Contains `transaction.dart` and `income_source.dart`.
- `services/`: Contains `dummy_data_service.dart` providing hardcoded mock data.
- `theme/`: Contains `app_theme.dart` defining our custom light/dark color palettes and typography.
- `screens/`: Contains the main feature views.
- `widgets/`: Contains highly reusable, beautifully styled UI components.

## ✅ What Has Been Completed

### 1. Main Navigation & Routing (`main_screen.dart`)
- Created a `MainScreen` wrapper acting as the app's root layout.
- Built a custom, pill-shaped, floating `BottomNavigationBar` with 5 tabs: Home, Stats, Add (+), Cards, Profile.

### 2. Dashboard Screen (`dashboard_screen.dart`)
- **Header**: User avatar, greeting, theme toggle, and notification bell.
- **Balance Section**: A dark, sleek card displaying total balance, income, and expenses (located in `balance_section.dart`).
- **Action Buttons**: "Send", "Request", and "QR Code" pills (located in `action_buttons.dart`).
- **AI Insights Banner**: A container alerting the user about spending patterns (e.g., exceeding dining budget).
- **Spending by Category**: A horizontally scrolling list of emoji-driven category cards.
- **Grouped Transactions**: A list of recent transactions grouped by "Today" and "Yesterday", featuring cute UI tags (e.g., `✦ Food`) located in `transaction_card.dart`.

### 3. Add Transaction Flow (`add_transaction_modal.dart`)
- Instead of a dedicated screen, tapping the center `+` icon opens a full-screen `ModalBottomSheet`.
- **Features**: 
  - Expense/Income toggle switch.
  - Large numeric input field for the amount.
  - An interactive 4x2 grid of emoji-based Categories.
  - A text field for notes.
- *Note: The UI is complete, but it is not yet hooked up to write data to a database or local state.*


5. **Backend Integration**:
   - Define the JSON structures and write an `API_Requirements.md` document to guide backend development.
   - Replace local state with HTTP calls.
