# AppVeg

AppVeg is a mobile application designed to help users discover vegan and vegetarian-friendly restaurants in their area. 
It provides a user-friendly interface for browsing restaurants, viewing details, and saving favorites.

## Features

- **Restaurant Discovery:**  Browse a comprehensive list of vegan and vegetarian restaurants.
- **Detailed Information:** View restaurant details, including address, contact information, cuisine type, and user ratings.
- **Favorites:** Save your favorite restaurants for quick access.
- **User Accounts:** Create an account to personalize your experience and manage your favorites.
- **Search and Filters:** Easily find restaurants based on keywords and dietary preferences.

## Technologies

- **Frontend:** Flutter 
- **Backend:** Go
- **Data Synchronization:** Python (for syncing with a third-party restaurant API)

## Project Structure

The repository is organized as follows:
```
AppVeg/
├── appveg_flutter/  # Flutter frontend application
├── backend/       # Backend services
│   ├── go/        # Go backend 
│   └── python/    # Python scripts for data synchronization
└── README.md      # This file
```
### Frontend (Flutter)

The `appveg_flutter/` directory contains the Flutter application.  Key directories and files include:

- `lib/`:  Main application code.
    - `main.dart`:  Entry point of the Flutter application.
    - `views/`:  User interface screens (e.g., `home_view.dart`, `restaurant_list_view.dart`, `restaurant_detail_view.dart`).
    - `controllers/`:  Business logic controllers (e.g., `restaurant_controller.dart`, `auth_controller.dart`).
    - `models/`:  Data models (e.g., `restaurant_model.dart`, `user_model.dart`).
    - `services/`:  API and other service integrations (e.g., `api_service.dart`, `location_service.dart`).
- `assets/`:  Static assets such as images and icons.
- `android/`, `ios/`, `web/`: Platform-specific build configurations.

To run the Flutter application:

1. Ensure you have Flutter installed and configured.  See the official Flutter documentation for instructions: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
2. Navigate to the `appveg_flutter/` directory in your terminal.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` to launch the app on a connected device or emulator.


### Backend (Go & Python)

The `backend/` directory contains the backend services.

**Go Backend (`backend/go/`)**

The Go backend handles API requests from the Flutter app.  Key files and directories include:

- `main.go`: Entry point for the Go server.
- `handlers/`:  Request handlers for different API endpoints (e.g., authentication, restaurant data).
- `models/`:  Data structures representing application data.
- `middleware/`:  Middleware functions for tasks like authentication.

To run the Go backend:

1. Ensure you have Go installed.
2. Navigate to the `backend/go/` directory in your terminal.
3. Run `go run main.go`

**Data Synchronization (Python, `backend/python/`)**

The Python scripts in `backend/python/` are responsible for synchronizing restaurant data from a third-party API into the application's database.  

- `main.py`:  Likely the main script for running the synchronization process.
-  Other files might include modules for database interaction, API communication, and data transformation.

To run the data synchronization script:

1. Ensure you have Python 3 installed.
2. Navigate to the `backend/python/` directory in your terminal.
3.  You may need to install dependencies. If a `requirements.txt` file exists, run: `pip install -r requirements.txt`
4. Run the script, likely with: `python main.py` (or similar, depending on the script's entry point).

**Note:** The specific commands to run the backend and data synchronization scripts may vary depending on the project's setup and any build processes involved.  Refer to any additional documentation within the `backend/` directory for more precise instructions.

## Database

The application uses a database to store restaurant information, user accounts, and favorites.  The specific database technology used (e.g., SQLite, PostgreSQL) and its schema are not detailed here but would typically be defined within the backend code (Go and/or Python).
