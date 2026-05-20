# Finance Tracker

A cross-platform mobile application built with Flutter for the Cross-Platform Mobile Development final project. The app demonstrates mastery of state management, local and cloud persistence, external API integration, and complex UI layouts following Clean Architecture principles.

## Team

| Member | Responsibilities |
|---|---|
| Amina | Project architecture, Drift database, Riverpod providers, go_router navigation, Dashboard screen, Household screen |
| Nazerke | FastForex API integration, Currency Repository, Currency Converter screen, Android network configuration |
| Erasyl | Expense and Budget repositories, Expenses screen, Add/Edit Expense screen, Settings screen, SharedPreferences |

## Features

- Track personal monthly expenses with categories
- Visual budget progress and spending breakdown by category (pie chart)
- Currency converter with real-time exchange rates
- Shared household expenses synced in real-time via Firebase Firestore
- Budget settings and dark mode toggle persisted via SharedPreferences
- Swipe to delete expenses
- Filter expenses by category

## Technical Stack

| Requirement | Implementation |
|---|---|
| State Management | Riverpod (AsyncNotifierProvider, StreamProvider, FutureProvider) |
| Navigation | go_router with ShellRoute and sub-routes (/expenses/add) |
| Local Database | Drift (SQLite) with DAO pattern and code generation |
| Lightweight Storage | SharedPreferences for budget limit, currency, theme, username |
| Networking | HTTP client with FastForex API for real-time currency rates |
| Cloud Database | Firebase Firestore for real-time shared household expenses |
| Architecture | Clean Architecture (Domain, Data, Presentation layers) |

## Architecture

The project follows Clean Architecture with strict separation of concerns across three layers.

```
lib/
├── core/
│   ├── constants/        # App-wide constants and category definitions
│   ├── router/           # go_router configuration and route definitions
│   ├── theme/            # Material 3 light and dark theme
│   └── utils/            # Currency and date formatters
├── data/
│   ├── local/
│   │   ├── database/     # Drift database definition and generated code
│   │   └── dao/          # Data Access Objects for SQLite queries
│   ├── remote/
│   │   ├── api/          # HTTP service for currency API
│   │   └/models/         # JSON response models
│   └── repositories/     # Concrete implementations of domain repositories
├── domain/
│   ├── models/           # Pure Dart models (ExpenseModel, BudgetSettings, SharedExpenseModel)
│   └── repositories/     # Abstract repository interfaces
└── presentation/
    ├── providers/         # All Riverpod providers
    └── screens/
        ├── dashboard/     # Main screen with budget card and pie chart
        ├── expenses/      # Expense list and add/edit form
        ├── converter/     # Currency converter
        ├── household/     # Shared expenses via Firestore
        └── settings/      # Budget, currency, and theme settings
```

## Setup Instructions

### Prerequisites

- Flutter 3.22 or higher
- Dart 3.0 or higher
- Android Studio or VS Code with Flutter extension
- Firebase account

### Step 1 - Clone the repository

```bash
git clone https://github.com/amina007-d/CrossPlatform_FInal.git
cd CrossPlatform_FInal
```

### Step 2 - Install dependencies

```bash
flutter pub get
```

### Step 3 - Configure Firebase

Install the FlutterFire CLI if you do not have it:

```bash
dart pub global activate flutterfire_cli
```

Run the configuration command and select the existing Firebase project:

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

This will generate or update the `lib/firebase_options.dart` file automatically. Make sure to select Android as the target platform.

### Step 4 - Generate code

Drift, Riverpod, and Chopper require code generation. Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 5 - Enable Developer Mode (Windows only)

Drift uses symlinks which require Developer Mode on Windows. Go to Settings, then Privacy and Security, then For Developers, and enable Developer Mode. Restart the terminal after enabling.

### Step 6 - Run the app

```bash
flutter run
```

To run on a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

Note: The app does not support Web due to Drift using dart:ffi which is unavailable in browser environments. Run on Android or Windows.

## API

Currency conversion is powered by the FastForex API (https://fastforex.io). The API key is included in the source code for demonstration purposes. The free trial plan supports 1 million requests per month.

Supported base currencies: USD, EUR, GBP, JPY, CAD, AUD, CHF, CNY
Supported target currencies: all of the above plus KZT and RUB

## Firebase Setup

The app requires a Firestore database to be created in the Firebase Console. After creating the project, navigate to Firestore Database and create a database in test mode. The following security rules are required for the app to function:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

Note: These rules are permissive and intended for development and demonstration only.

## Data Storage

The app uses two separate storage systems for different types of data.

Personal expenses are stored locally using Drift (SQLite). This means expense data is private to each device and does not require an internet connection. The database persists across app restarts.

Shared household expenses are stored in Firebase Firestore. All users who enter the same Household ID can see and add expenses in real time. Changes from any device are reflected immediately on all other devices connected to the same household.

Budget settings, default currency, theme preference, and username are stored using SharedPreferences as lightweight key-value pairs.

## Household Feature

To use the shared expenses feature, navigate to the Household tab and tap the group icon in the top right corner to set a Household ID. Any string can be used as an ID. Share the same ID with other household members so they can join the same household and see shared expenses in real time.

When adding a shared expense, enter the names of all members who are splitting the cost in the Split Between field, separated by commas. The app will calculate and display the per-person amount automatically.

## Project Requirements Checklist

- Clean Architecture with separated UI, Domain, and Data layers
- Riverpod for state management and dependency injection
- go_router with multiple sub-routes and back-stack management
- Drift (SQLite) for structured local data persistence
- SharedPreferences for lightweight settings storage
- External API integration via HTTP client for currency conversion
- Firebase Firestore for real-time cloud data synchronization
- Complex scrollable views using Slivers and GridView
- Interactive widgets including pie chart, filter chips, and slidable list items
- Loading and error state handling throughout the app
- Dark mode support
- README documentation