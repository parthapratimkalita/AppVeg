# AppVeg Flutter

A modern Flutter application for finding vegetarian restaurants near you. This is the frontend part of the AppVeg project.

## Features

- User authentication (login/register)
- Browse vegetarian restaurants
- Search and filter restaurants by cuisine
- View restaurant details (menu, opening hours, contact info)
- Save favorite restaurants
- View restaurants on a map
- Get directions to restaurants
- User profile management

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Flutter SDK (3.7.2 or higher)
- Dart SDK (3.7.2 or higher)
- Android Studio / Xcode (for running on emulators/simulators)
- A Google Maps API key (for map functionality)

## Getting Started

1. Clone the repository:
```bash
git clone <repository-url>
cd appveg_flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Google Maps:
   - Get a Google Maps API key from the [Google Cloud Console](https://console.cloud.google.com/)
   - For Android: Add your API key to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY"/>
     ```
   - For iOS: Add your API key to `ios/Runner/AppDelegate.swift`:
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY")
     ```

4. Configure the backend URL:
   - Open `lib/services/api_service.dart`
   - Update the `baseUrl` constant with your backend server URL

5. Run the app:
```bash
flutter run
```

## Architecture

The app follows a clean architecture pattern with:

- Models: Data classes representing the domain entities
- Controllers: Business logic and state management using Provider
- Views: UI components and screens
- Services: API communication and platform services

## Dependencies

- provider: ^6.1.1 - State management
- http: ^1.2.0 - HTTP client for API calls
- google_maps_flutter: ^2.5.3 - Google Maps integration
- geolocator: ^11.0.0 - Location services
- flutter_secure_storage: ^9.0.0 - Secure storage for auth tokens
- cached_network_image: ^3.3.1 - Image caching
- flutter_rating_bar: ^4.0.1 - Rating display
- url_launcher: ^6.2.5 - Opening URLs and making calls
- intl: ^0.19.0 - Internationalization and formatting

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
