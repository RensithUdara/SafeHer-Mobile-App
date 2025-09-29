import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ValidationHelper {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegExp = RegExp(ValidationPatterns.email);
    if (!emailRegExp.hasMatch(value.trim())) {
      return ErrorMessages.invalidEmail;
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    final passwordRegExp = RegExp(ValidationPatterns.password);
    if (!passwordRegExp.hasMatch(value)) {
      return ErrorMessages.weakPassword;
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }
    
    if (password != confirmPassword) {
      return ErrorMessages.passwordMismatch;
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegExp = RegExp(ValidationPatterns.phone);
    if (!phoneRegExp.hasMatch(value.trim())) {
      return ErrorMessages.invalidPhone;
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    final nameRegExp = RegExp(ValidationPatterns.name);
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }

  // PIN validation
  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    
    final pinRegExp = RegExp(ValidationPatterns.pin);
    if (!pinRegExp.hasMatch(value)) {
      return ErrorMessages.invalidPin;
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  // Emergency contact validation
  static String? validateEmergencyContact(String? name, String? phone) {
    final nameError = validateName(name);
    if (nameError != null) return nameError;
    
    final phoneError = validatePhone(phone);
    if (phoneError != null) return phoneError;
    
    return null;
  }
}

class FormatHelper {
  // Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length == 10) {
      // US format: (123) 456-7890
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      // US format with country code: +1 (123) 456-7890
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    
    return phoneNumber; // Return original if no standard format applies
  }

  // Format date
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Format time
  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} at ${formatTime(dateTime)}';
  }

  // Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Format distance
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  // Format emergency contact relationship
  static String formatRelationship(String relationship) {
    return relationship.substring(0, 1).toUpperCase() + relationship.substring(1).toLowerCase();
  }

  // Format coordinates
  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

class PermissionHelper {
  // Check if all required permissions are granted
  static Future<bool> checkRequiredPermissions() async {
    // This would check all required permissions
    // Implementation depends on the permission_handler package
    return true; // Placeholder
  }

  // Request all required permissions
  static Future<void> requestRequiredPermissions() async {
    // This would request all required permissions
    // Implementation depends on the permission_handler package
  }

  // Show permission rationale dialog
  static Future<void> showPermissionRationale(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Open app settings
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }
}

class DeviceHelper {
  // Get device type
  static String getDeviceType() {
    // This would determine device type (phone, tablet, etc.)
    return 'phone'; // Placeholder
  }

  // Check if device has specific features
  static Future<bool> hasCamera() async {
    // Check if device has camera
    return true; // Placeholder
  }

  static Future<bool> hasFlashlight() async {
    // Check if device has flashlight
    return true; // Placeholder
  }

  static Future<bool> hasVibration() async {
    // Check if device supports vibration
    return true; // Placeholder
  }

  // Get device info
  static Future<Map<String, String>> getDeviceInfo() async {
    return {
      'platform': 'Android', // or iOS
      'version': '12',
      'model': 'Pixel 6',
      'brand': 'Google',
    };
  }
}

class NetworkHelper {
  // Check network connectivity
  static Future<bool> isConnected() async {
    // Check if device is connected to internet
    return true; // Placeholder
  }

  // Get network type
  static Future<String> getNetworkType() async {
    // Get network type (wifi, mobile, none)
    return 'wifi'; // Placeholder
  }

  // Show network error dialog
  static Future<void> showNetworkError(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Network Error'),
          content: const Text(ErrorMessages.networkError),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Retry action
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }
}

class SecurityHelper {
  // Generate secure random string
  static String generateSecureId() {
    // Generate a secure random string for IDs
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Hash sensitive data
  static String hashData(String data) {
    // Hash sensitive data (implement proper hashing)
    return data.hashCode.toString();
  }

  // Check if app is running in debug mode
  static bool isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  // Validate app integrity
  static Future<bool> validateAppIntegrity() async {
    // Check app integrity/tampering
    return true; // Placeholder
  }
}

class LocationHelper {
  // Check if coordinates are valid
  static bool isValidCoordinate(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }

  // Calculate distance between two points
  static double calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    // Haversine formula implementation would go here
    return 0.0; // Placeholder
  }

  // Check if location is within bounds
  static bool isWithinBounds(
    double latitude, double longitude,
    double centerLat, double centerLon,
    double radiusMeters
  ) {
    final distance = calculateDistance(latitude, longitude, centerLat, centerLon);
    return distance <= radiusMeters;
  }

  // Get location accuracy description
  static String getAccuracyDescription(double accuracy) {
    if (accuracy <= 5) return 'Excellent';
    if (accuracy <= 10) return 'Good';
    if (accuracy <= 20) return 'Fair';
    if (accuracy <= 50) return 'Poor';
    return 'Very Poor';
  }
}

class DialogHelper {
  // Show loading dialog
  static Future<void> showLoadingDialog(BuildContext context, {String? message}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(message ?? 'Loading...'),
            ],
          ),
        );
      },
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog
  static Future<void> showSuccessDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}