# Travel Companion

A Flutter application that helps users track and share their travel locations with features like:
- Interactive map with custom markers
- Real-time location tracking
- Route planning between locations
- Photo uploads for places
- User profiles with avatars
- Place details and descriptions

## Features

- **Map Integration**: Google Maps with custom markers and routing
- **Location Services**: Real-time location tracking and updates
- **Place Management**: Add, view, and delete travel locations
- **Photo Integration**: Upload and store photos for places
- **User Profiles**: Customizable profiles with photo uploads
- **Route Planning**: Get directions and estimated travel times between locations

## Getting Started

### Prerequisites
- Flutter SDK 
- Dart SDK 
- Firebase account
- Google Maps API key
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development)

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication (Google Signin & Email/Password)
3. Create Cloud Firestore database
4. Enable Storage
5. Download and add configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS

### Configuration

Before running the app, you need to set up configuration files with your API keys:

1. Create the following files from their templates:
   ```bash
   # Create config directory
   mkdir -p lib/config
   
   # Create template files
   cp android/app/src/main/AndroidManifest.xml.template android/app/src/main/AndroidManifest.xml
   cp lib/config/maps_config.dart.template lib/config/maps_config.dart
   cp lib/firebase_options.dart.template lib/firebase_options.dart
   ```

2. Replace placeholder values in each file with your actual API keys.

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure API keys as described above
4. Run the app using `flutter run`

## Project Structure

```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # Business logic
├── widgets/        # Reusable widgets
└── config/         # Configuration files
```

## Dependencies

- google_maps_flutter: ^2.x.x
- firebase_core: ^2.x.x
- firebase_auth: ^4.x.x
- cloud_firestore: ^4.x.x
- firebase_storage: ^11.x.x
- provider: ^6.x.x
- image_picker: ^0.8.x

## Troubleshooting

Common issues and solutions:

1. **Black screen on map**: Check if Google Maps API key is properly configured
2. **Image upload fails**: Verify Firebase Storage rules
3. **Location not updating**: Check location permissions in device settings

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details
