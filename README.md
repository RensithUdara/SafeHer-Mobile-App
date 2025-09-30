# SafeHer Mobile App 🛡️👩

A comprehensive women's safety mobile application built with Flutter, designed to provide emergency assistance, location tracking, and community support features.

## 📱 About SafeHer

SafeHer is a mobile safety application specifically designed for women's security and emergency assistance. The app provides real-time location tracking, emergency alerts, safe journey monitoring, and community support features to enhance personal safety.

## ✨ Features

### 🚨 Emergency Features
- **SOS Alert System**: Instant emergency alerts with location sharing
- **Panic Button**: Quick access emergency activation
- **Emergency Contacts**: Automated notifications to trusted contacts
- **Live Location Sharing**: Real-time location broadcasting during emergencies
- **Audio/Video Recording**: Automatic evidence collection during panic situations

### 🗺️ Location & Journey
- **Safe Journey Tracking**: Monitor and share travel routes with trusted contacts
- **Safe Places**: Mark and navigate to verified safe locations
- **Real-time GPS Tracking**: Continuous location monitoring
- **Geo-fencing**: Alerts when entering/leaving designated safe zones
- **Route Planning**: Safe route suggestions and navigation

### 👥 Community & Social
- **Community Alerts**: Share and receive safety warnings from nearby users
- **Safe Network**: Connect with trusted friends and family
- **Emergency Contact Management**: Organize and manage emergency contacts
- **Group Safety**: Coordinate safety with groups during events or travel

### 🔐 Security & Privacy
- **Biometric Authentication**: Secure app access with fingerprint/face ID
- **Data Encryption**: All sensitive data encrypted locally and in transit
- **Anonymous Reporting**: Option to report incidents anonymously
- **Privacy Controls**: Granular privacy settings for location sharing

### 📱 Smart Features
- **Background Monitoring**: Continuous safety monitoring even when app is closed
- **Smart Notifications**: Intelligent alert system with customizable settings
- **Offline Functionality**: Core safety features work without internet connection
- **Multi-language Support**: Accessible in multiple languages

## 🛠️ Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile development framework
- **Dart** - Programming language
- **Material Design** - UI/UX components
- **Provider & GetX** - State management

### Backend & Services
- **Firebase Core** - Backend infrastructure
- **Firebase Authentication** - User authentication
- **Firebase Firestore** - Real-time database
- **Firebase Cloud Messaging** - Push notifications
- **Firebase Storage** - File storage
- **Firebase Analytics** - Usage analytics
- **Firebase Crashlytics** - Crash reporting

### Location & Maps
- **Google Maps Flutter** - Interactive maps
- **Geolocator** - GPS location services
- **Geocoding** - Address conversion

### Local Storage
- **SQLite (sqflite)** - Local database
- **Shared Preferences** - Key-value storage
- **Flutter Secure Storage** - Encrypted storage

### Device Features
- **Camera & Image Picker** - Photo/video capture
- **Local Notifications** - Background notifications
- **Vibration** - Haptic feedback
- **Torch Light** - Flashlight control
- **Sensors Plus** - Device sensors
- **Battery Plus** - Battery monitoring

## 📋 Prerequisites

Before running the application, ensure you have:

- Flutter SDK (^3.5.3)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)
- Firebase project configured

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/RensithUdara/SafeHer-Mobile-App.git
cd safeher_mobile_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration

#### Android
1. Add your `google-services.json` file to `android/app/`
2. Update `android/build.gradle` with Firebase classpath
3. Update `android/app/build.gradle` with Firebase plugins

#### iOS
1. Add your `GoogleService-Info.plist` file to `ios/Runner/`
2. Update `ios/Runner/Info.plist` with required permissions

### 4. Configure Permissions

#### Android Permissions (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.FLASHLIGHT" />
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

#### iOS Permissions (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to provide safety features and emergency assistance.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs background location access to monitor your safety and provide emergency assistance.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture evidence during emergency situations.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio during emergency situations.</string>
```

### 5. Google Maps Setup

#### Android
Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_API_KEY_HERE"/>
```

#### iOS
Add your Google Maps API key to `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

## 🏃‍♀️ Running the App

### Development Mode
```bash
# Run on connected device/emulator
flutter run

# Run with specific flavor
flutter run --flavor development
flutter run --flavor production

# Run with verbose logging
flutter run --verbose
```

### Build for Production

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

#### iOS
```bash
# Build for iOS
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── main.dart                   # App entry point
├── controllers/                # Business logic controllers
├── database/
│   └── database_helper.dart    # SQLite database helper
├── models/                     # Data models
│   ├── emergency_alert_model.dart
│   ├── emergency_contact_model.dart
│   ├── journey_model.dart
│   ├── safe_place_model.dart
│   └── user_model.dart
├── services/                   # External services
│   ├── auth_service.dart       # Authentication service
│   ├── emergency_service.dart  # Emergency handling service
│   ├── firebase_service.dart   # Firebase integration
│   ├── location_service.dart   # Location tracking service
│   └── notification_service.dart # Push notifications
├── utils/                      # Utility functions
│   ├── constants.dart          # App constants
│   ├── helpers.dart           # Helper functions
│   └── theme.dart             # App theming
├── views/                      # UI screens
└── widgets/
    └── common_widgets.dart     # Reusable UI components
```

## 🔧 Configuration

### Environment Variables
Create environment-specific configuration files:

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String appName = 'SafeHer';
  static const String baseUrl = 'https://api.safeher.com';
  static const bool isProduction = true;
  
  // Firebase configuration
  static const String firebaseProjectId = 'your-project-id';
  
  // Google Maps
  static const String googleMapsApiKey = 'your-maps-api-key';
  
  // Emergency settings
  static const int emergencyTimeoutSeconds = 300;
  static const double safeZoneRadiusMeters = 100.0;
}
```

## 📱 Key Features Implementation

### Emergency Alert System
- Real-time alert broadcasting
- Automated contact notification
- Location-based emergency services
- Evidence collection (audio/video)

### Location Tracking
- Continuous GPS monitoring
- Battery-optimized tracking
- Offline location caching
- Safe route calculation

### Community Safety
- Peer-to-peer safety alerts
- Anonymous incident reporting
- Community-verified safe places
- Group coordination features

## 🔒 Security Features

### Data Protection
- End-to-end encryption for sensitive data
- Biometric authentication
- Secure local storage
- Privacy-first design

### Emergency Protocols
- Automatic emergency service contact
- Stealth mode operation
- False alarm prevention
- Emergency contact hierarchy

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Test Structure
```
test/
├── unit/                   # Unit tests
├── widget/                 # Widget tests
├── integration/            # Integration tests
└── fixtures/               # Test data
```

## 🚀 Deployment

### Android Deployment
1. Configure signing keys
2. Update version in `pubspec.yaml`
3. Build release APK/Bundle
4. Upload to Google Play Store

### iOS Deployment
1. Configure provisioning profiles
2. Update version and build number
3. Build for release
4. Upload to App Store Connect

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style Guidelines
- Follow Dart/Flutter style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting
- Write tests for new features

## 📞 Support & Contact

- **Email**: support@safeher.com
- **Website**: https://safeher.com
- **Documentation**: https://docs.safeher.com
- **Issues**: [GitHub Issues](https://github.com/RensithUdara/SafeHer-Mobile-App/issues)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Google Maps for location services
- Community contributors and testers
- Women's safety organizations for guidance and feedback

## 📊 Project Status

- **Version**: 1.0.0
- **Status**: Active Development
- **Platform**: Android, iOS
- **Minimum SDK**: Android 21+, iOS 12+

---

**SafeHer** - Empowering women's safety through technology 💪👩‍💻

*For detailed API documentation and advanced configuration, please refer to our [Wiki](https://github.com/RensithUdara/SafeHer-Mobile-App/wiki).*
