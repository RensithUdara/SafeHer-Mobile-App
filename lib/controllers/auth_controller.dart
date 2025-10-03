import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  User? _currentUser;
  UserModel? _currentUserModel;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFirstTime = true;

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFirstTime => _isFirstTime;
  bool get isLoggedIn => _currentUser != null;

  AuthController() {
    _initializeAuth();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      // Check if user is already logged in
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        await _loadUserModel();
      }

      // Check if it's first time opening the app
      final prefs = await SharedPreferences.getInstance();
      _isFirstTime = prefs.getBool('is_first_time') ?? true;
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserModel() async {
    if (_currentUser == null) return;

    try {
      // First try to load from Firestore
      final userData = await _firebaseService.getUser(_currentUser!.uid);
      if (userData != null) {
        _currentUserModel = userData;
        // Save to local database
        await _databaseHelper.insert('users_table', _currentUserModel!.toMap());
      } else {
        // Try to load from local database
        final userMap = await _databaseHelper.queryFirst(
          'users_table',
          where: 'id = ?',
          whereArgs: [_currentUser!.uid],
        );
        if (userMap != null) {
          _currentUserModel = UserModel.fromMap(userMap);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  // Alias method for registration
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    return await registerWithEmailPassword(
      name: name,
      email: email,
      password: password,
      phone: phoneNumber,
    );
  }

  // Email/Password Registration
  Future<bool> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Direct Firebase Auth call to avoid AuthService complications
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        _currentUser = userCredential.user;

        // Update display name
        await _currentUser!.updateDisplayName(name);

        // Create user model
        final userModel = UserModel(
          id: _currentUser!.uid,
          name: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save to Firestore
        await _firebaseService.saveUser(userModel);

        // Save to local database
        await _databaseHelper.insert('users_table', userModel.toMap());

        _currentUserModel = userModel;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'weak-password':
          _setError('Password is too weak. Please choose a stronger password.');
          break;
        case 'email-already-in-use':
          _setError('An account already exists with this email address.');
          break;
        case 'invalid-email':
          _setError('Invalid email address format.');
          break;
        case 'operation-not-allowed':
          _setError('Email/password accounts are not enabled.');
          break;
        case 'network-request-failed':
          _setError('Network error. Please check your internet connection.');
          break;
        default:
          _setError('Registration failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('Registration Error: $e');
      // Handle the specific PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        _setError('Authentication service temporarily unavailable. Please try again.');
      } else {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        _setError(errorMessage);
      }
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // Email/Password Login
  Future<bool> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Direct Firebase Auth call to avoid AuthService complications
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        _currentUser = userCredential.user;
        await _loadUserModel();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          _setError('No account found with this email address.');
          break;
        case 'wrong-password':
          _setError('Incorrect password. Please try again.');
          break;
        case 'invalid-email':
          _setError('Invalid email address format.');
          break;
        case 'user-disabled':
          _setError('This account has been disabled.');
          break;
        case 'too-many-requests':
          _setError('Too many failed attempts. Please try again later.');
          break;
        case 'network-request-failed':
          _setError('Network error. Please check your internet connection.');
          break;
        case 'invalid-credential':
          _setError('Invalid email or password. Please check your credentials.');
          break;
        default:
          _setError('Sign in failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      // Handle the specific PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        _setError('Authentication service temporarily unavailable. Please try again.');
      } else {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        _setError(errorMessage);
      }
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      // First sign out any existing Google Sign In session
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _setError('Failed to get Google authentication tokens');
        _setLoading(false);
        return false;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        _currentUser = userCredential.user;

        // Check if user exists in database
        await _loadUserModel();

        // If new user, create user model
        if (_currentUserModel == null) {
          final userModel = UserModel(
            id: _currentUser!.uid,
            name: _currentUser!.displayName ?? 'Unknown User',
            email: _currentUser!.email ?? '',
            phone: _currentUser!.phoneNumber,
            profilePhotoPath: _currentUser!.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _firebaseService.saveUser(userModel);
          await _databaseHelper.insert('users_table', userModel.toMap());
          _currentUserModel = userModel;
        }

        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'account-exists-with-different-credential':
          _setError(
              'An account already exists with a different sign-in method.');
          break;
        case 'invalid-credential':
          _setError('Invalid credentials. Please try again.');
          break;
        case 'user-disabled':
          _setError('This account has been disabled.');
          break;
        default:
          _setError('Sign in failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      if (e.toString().contains('PigeonUserDetails')) {
        // Handle the specific type casting error
        _setError(
            'Google Sign In is temporarily unavailable. Please try email login instead.');
      } else if (e.toString().contains('network_error')) {
        _setError('Network error. Please check your internet connection.');
      } else {
        _setError('Sign in failed. Please try again.');
      }
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // Facebook Sign In
  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    _setError(null);

    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success && result.accessToken != null) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        final userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        if (userCredential.user != null) {
          _currentUser = userCredential.user;

          await _loadUserModel();

          if (_currentUserModel == null) {
            final userModel = UserModel(
              id: _currentUser!.uid,
              name: _currentUser!.displayName ?? 'Facebook User',
              email: _currentUser!.email ?? '',
              phone: _currentUser!.phoneNumber,
              profilePhotoPath: _currentUser!.photoURL,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            await _firebaseService.saveUser(userModel);
            await _databaseHelper.insert('users_table', userModel.toMap());
            _currentUserModel = userModel;
          }

          notifyListeners();
          return true;
        }
      } else if (result.status == LoginStatus.cancelled) {
        // User cancelled the login
        return false;
      } else {
        _setError(
            'Facebook login failed: ${result.message ?? 'Unknown error'}');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'account-exists-with-different-credential':
          _setError(
              'An account already exists with a different sign-in method.');
          break;
        case 'invalid-credential':
          _setError('Invalid Facebook credentials. Please try again.');
          break;
        case 'user-disabled':
          _setError('This account has been disabled.');
          break;
        default:
          _setError('Facebook sign in failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('Facebook Sign In Error: $e');
      _setError('Facebook sign in failed. Please try again.');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // Password Reset
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // Update Profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profilePhotoPath,
  }) async {
    if (_currentUserModel == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      final updatedUser = UserModel(
        id: _currentUserModel!.id,
        name: name ?? _currentUserModel!.name,
        email: _currentUserModel!.email,
        phone: phone ?? _currentUserModel!.phone,
        profilePhotoPath:
            profilePhotoPath ?? _currentUserModel!.profilePhotoPath,
        emergencyPin: _currentUserModel!.emergencyPin,
        createdAt: _currentUserModel!.createdAt,
        updatedAt: DateTime.now(),
        isActive: _currentUserModel!.isActive,
      );

      // Update in Firestore
      await _firebaseService.updateUser(updatedUser);

      // Update in local database
      await _databaseHelper.update(
        'users_table',
        updatedUser.toMap(),
        where: 'id = ?',
        whereArgs: [updatedUser.id],
      );

      _currentUserModel = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // Set Emergency PIN
  Future<bool> setEmergencyPin(String pin) async {
    if (_currentUserModel == null) return false;

    try {
      final updatedUser = UserModel(
        id: _currentUserModel!.id,
        name: _currentUserModel!.name,
        email: _currentUserModel!.email,
        phone: _currentUserModel!.phone,
        profilePhotoPath: _currentUserModel!.profilePhotoPath,
        emergencyPin: pin,
        createdAt: _currentUserModel!.createdAt,
        updatedAt: DateTime.now(),
        isActive: _currentUserModel!.isActive,
      );

      await _firebaseService.updateUser(updatedUser);
      await _databaseHelper.update(
        'users_table',
        updatedUser.toMap(),
        where: 'id = ?',
        whereArgs: [updatedUser.id],
      );

      _currentUserModel = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();

      _currentUser = null;
      _currentUserModel = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
    _isFirstTime = false;
    notifyListeners();
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      final userId = _currentUser!.uid;

      // Delete user data from Firestore
      await _firebaseService.deleteUser(userId);

      // Delete from local database
      await _databaseHelper.delete(
        'users_table',
        where: 'id = ?',
        whereArgs: [userId],
      );

      // Delete Firebase Auth account
      await _currentUser!.delete();

      _currentUser = null;
      _currentUserModel = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return false;
  }

  void clearError() {
    _setError(null);
  }
}
