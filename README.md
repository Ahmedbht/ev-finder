# EV Finder

A Flutter app for finding nearby EV charging stations, using real-time data from the Open Charge Map API.

## Features
- Live map (OpenStreetMap tiles) showing nearby EV charging stations
- Tap a station marker to view details: address, connector types, number of charging points
- Save stations to Favorites (persisted locally)
- Bottom navigation between Map and Favorites

## Tech Stack
- Flutter / Dart
- `flutter_map` + OpenStreetMap (no Google Maps billing required)
- Open Charge Map API for station data
- `provider` for state management
- `shared_preferences` for local favorites storage

## Getting Started
1. Clone the repo
2. Get a free API key from [openchargemap.org](https://openchargemap.org/site/develop/api)
3. Create `lib/config/api_config.dart`:
```dart
   class ApiConfig {
     static const String ocmApiKey = 'YOUR_KEY_HERE';
   }
```
4. Run `flutter pub get`
5. Run `flutter run`