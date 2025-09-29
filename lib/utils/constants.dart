// App Information
class AppConstants {
  static const String appName = 'SafeHer';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Women\'s Safety Mobile Application';

  // API & Firebase
  static const String baseUrl = 'https://api.safeher.com';
  static const String firebaseWebApiKey = 'your-firebase-web-api-key';

  // Database
  static const String databaseName = 'safeher.db';
  static const int databaseVersion = 1;

  // Shared Preferences Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userPhone = 'user_phone';
  static const String emergencyPin = 'emergency_pin';
  static const String isLocationEnabled = 'is_location_enabled';
  static const String isNotificationEnabled = 'is_notification_enabled';
  static const String lastKnownLatitude = 'last_known_latitude';
  static const String lastKnownLongitude = 'last_known_longitude';
  static const String darkMode = 'dark_mode';
  static const String language = 'language';

  // Emergency
  static const String emergencyNumber = '911';
  static const String policeNumber = '911';
  static const String ambulanceNumber = '911';
  static const String fireNumber = '911';

  // Country-specific emergency numbers
  static const Map<String, Map<String, String>> emergencyNumbers = {
    'US': {
      'emergency': '911',
      'police': '911',
      'ambulance': '911',
      'fire': '911',
    },
    'UK': {
      'emergency': '999',
      'police': '999',
      'ambulance': '999',
      'fire': '999',
    },
    'IN': {
      'emergency': '112',
      'police': '100',
      'ambulance': '102',
      'fire': '101',
    },
    'AU': {
      'emergency': '000',
      'police': '000',
      'ambulance': '000',
      'fire': '000',
    },
    'CA': {
      'emergency': '911',
      'police': '911',
      'ambulance': '911',
      'fire': '911',
    },
  };

  // Location
  static const double defaultLocationAccuracy = 10.0; // meters
  static const int locationUpdateInterval = 5000; // milliseconds
  static const int backgroundLocationInterval = 60000; // milliseconds
  static const double geofenceRadius = 100.0; // meters
  static const double dangerZoneRadius = 500.0; // meters

  // Journey
  static const int journeyTimeoutMinutes = 30;
  static const int journeyCheckInterval = 60; // seconds
  static const double routeDeviationThreshold = 200.0; // meters

  // Notifications
  static const int emergencyNotificationId = 1001;
  static const int safetyNotificationId = 1002;
  static const int journeyNotificationId = 1003;
  static const int communityNotificationId = 1004;
  static const int locationTrackingNotificationId = 1005;

  // File sizes and limits
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxAudioSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSizeBytes = 50 * 1024 * 1024; // 50MB
  static const int maxEmergencyContacts = 10;
  static const int maxSafePlaces = 50;

  // Timeouts
  static const int networkTimeoutSeconds = 30;
  static const int emergencyResponseTimeoutSeconds = 10;
  static const int locationTimeoutSeconds = 15;

  // Animation durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 500;
  static const int longAnimationDuration = 1000;

  // Security
  static const int pinLength = 4;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
}

// Route Names
class RouteNames {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String createPassword = '/create-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String emergencyContacts = '/emergency-contacts';
  static const String addContact = '/add-contact';
  static const String editContact = '/edit-contact';
  static const String sos = '/sos';
  static const String fakeCall = '/fake-call';
  static const String journey = '/journey';
  static const String startJourney = '/start-journey';
  static const String trackJourney = '/track-journey';
  static const String locationSharing = '/location-sharing';
  static const String safePlaces = '/safe-places';
  static const String addSafePlace = '/add-safe-place';
  static const String communityMap = '/community-map';
  static const String reportIncident = '/report-incident';
  static const String safetyTips = '/safety-tips';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String help = '/help';
  static const String about = '/about';
  static const String emergencyHistory = '/emergency-history';
  static const String notifications = '/notifications';
}

// Asset Paths
class AssetPaths {
  // Images
  static const String logo = 'assets/images/logo.png';
  static const String logoWhite = 'assets/images/logo_white.png';
  static const String splash = 'assets/images/splash.png';
  static const String onboarding1 = 'assets/images/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding_3.png';
  static const String onboarding4 = 'assets/images/onboarding_4.png';
  static const String sosButton = 'assets/images/sos_button.png';
  static const String fakeCallAvatar = 'assets/images/fake_call_avatar.png';
  static const String safetyTips = 'assets/images/safety_tips.png';
  static const String profilePlaceholder =
      'assets/images/profile_placeholder.png';

  // Icons
  static const String homeIcon = 'assets/icons/home.svg';
  static const String sosIcon = 'assets/icons/sos.svg';
  static const String contactsIcon = 'assets/icons/contacts.svg';
  static const String mapIcon = 'assets/icons/map.svg';
  static const String profileIcon = 'assets/icons/profile.svg';
  static const String emergencyIcon = 'assets/icons/emergency.svg';
  static const String locationIcon = 'assets/icons/location.svg';
  static const String phoneIcon = 'assets/icons/phone.svg';
  static const String shieldIcon = 'assets/icons/shield.svg';
  static const String alertIcon = 'assets/icons/alert.svg';

  // Animations
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String sosAnimation = 'assets/animations/sos.json';
  static const String safeAnimation = 'assets/animations/safe.json';
  static const String dangerAnimation = 'assets/animations/danger.json';
  static const String locationAnimation = 'assets/animations/location.json';

  // Sounds
  static const String emergencyAlarm = 'assets/sounds/emergency_alarm.mp3';
  static const String notificationSound = 'assets/sounds/notification.mp3';
  static const String buttonClick = 'assets/sounds/button_click.mp3';
  static const String fakeCallRingtone = 'assets/sounds/fake_call_ringtone.mp3';
}

// Error Messages
class ErrorMessages {
  static const String networkError =
      'Network connection failed. Please check your internet connection.';
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String unknownError =
      'An unknown error occurred. Please try again.';
  static const String locationError =
      'Unable to get your location. Please enable location services.';
  static const String permissionDenied =
      'Permission denied. Please grant the necessary permissions.';
  static const String authenticationFailed =
      'Authentication failed. Please check your credentials.';
  static const String userNotFound =
      'User not found. Please check your email address.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String invalidPhone = 'Please enter a valid phone number.';
  static const String weakPassword =
      'Password is too weak. Please choose a stronger password.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String invalidPin = 'Invalid PIN. Please enter a 4-digit PIN.';
  static const String emergencyContactLimit =
      'You can only add up to 10 emergency contacts.';
  static const String safePlaceLimit =
      'You can only save up to 50 safe places.';
  static const String fileTooBig =
      'File size is too large. Please choose a smaller file.';
  static const String invalidFileType =
      'Invalid file type. Please choose a valid file.';
}

// Success Messages
class SuccessMessages {
  static const String loginSuccess = 'Login successful!';
  static const String registrationSuccess = 'Registration successful!';
  static const String passwordResetSent =
      'Password reset link sent to your email.';
  static const String passwordChanged = 'Password changed successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
  static const String contactAdded = 'Emergency contact added successfully!';
  static const String contactUpdated =
      'Emergency contact updated successfully!';
  static const String contactDeleted =
      'Emergency contact deleted successfully!';
  static const String safePlaceAdded = 'Safe place added successfully!';
  static const String emergencyAlertSent =
      'Emergency alert sent to your contacts!';
  static const String journeyStarted = 'Safe journey tracking started!';
  static const String journeyCompleted = 'Journey completed successfully!';
  static const String locationShared = 'Location shared with your contacts!';
  static const String incidentReported = 'Incident reported successfully!';
}

// Validation Patterns
class ValidationPatterns {
  static const String email =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phone = r'^\+?[\d\s\-\(\)]{10,}$';
  static const String name = r'^[a-zA-Z\s]{2,50}$';
  static const String pin = r'^\d{4}$';
  static const String password =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
}

// API Endpoints
class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/update';
  static const String deleteAccount = '/user/delete';
  static const String emergencyContacts = '/user/emergency-contacts';
  static const String emergencyAlerts = '/emergency/alerts';
  static const String safePlaces = '/places/safe';
  static const String nearbyPlaces = '/places/nearby';
  static const String communityReports = '/community/reports';
  static const String shareLocation = '/location/share';
  static const String stopSharing = '/location/stop';
  static const String journeys = '/journey';
  static const String startJourney = '/journey/start';
  static const String updateJourney = '/journey/update';
  static const String endJourney = '/journey/end';
}

// Firebase Collections
class FirebaseCollections {
  static const String users = 'users';
  static const String emergencyAlerts = 'emergency_alerts';
  static const String communityReports = 'community_reports';
  static const String sharedLocations = 'shared_locations';
  static const String safePlaces = 'safe_places';
  static const String journeys = 'journeys';
  static const String notificationRequests = 'notification_requests';
  static const String appSettings = 'app_settings';
  static const String feedbacks = 'feedbacks';
}

// Notification Topics
class NotificationTopics {
  static const String emergencyAlerts = 'emergency_alerts';
  static const String communityAlerts = 'community_alerts';
  static const String safetyTips = 'safety_tips';
  static const String appUpdates = 'app_updates';
}

// Emergency Contact Relationships
class ContactRelationships {
  static const List<String> relationships = [
    'Mother',
    'Father',
    'Spouse',
    'Partner',
    'Sister',
    'Brother',
    'Daughter',
    'Son',
    'Friend',
    'Colleague',
    'Neighbor',
    'Guardian',
    'Other',
  ];
}

// Safe Place Types
class SafePlaceTypes {
  static const List<String> types = [
    'Police Station',
    'Hospital',
    'Fire Station',
    'Pharmacy',
    'Government Office',
    'Public Transport',
    'Hotel',
    'Restaurant',
    'Shopping Mall',
    'School',
    'University',
    'Religious Place',
    'Other',
  ];
}

// Incident Types
class IncidentTypes {
  static const List<String> types = [
    'Harassment',
    'Assault',
    'Theft',
    'Stalking',
    'Suspicious Activity',
    'Poor Lighting',
    'Unsafe Area',
    'Traffic Accident',
    'Medical Emergency',
    'Natural Disaster',
    'Other',
  ];
}

// Languages
class Languages {
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'it', 'name': 'Italiano'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'hi', 'name': 'हिन्दी'},
  ];
}

// Default Values
class DefaultValues {
  static const String defaultCountryCode = '+1';
  static const String defaultLanguage = 'en';
  static const String defaultTheme = 'light';
  static const double defaultLatitude = 37.7749; // San Francisco
  static const double defaultLongitude = -122.4194;
  static const int defaultJourneyTimeout = 60; // minutes
  static const String defaultEmergencyMessage =
      'I am in an emergency situation and need immediate help!';
  static const String defaultFakeCallerName = 'Mom';
  static const String defaultFakeCallerNumber = '+1-555-0123';
}
