import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../database/database_helper.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  firstTime,
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseService _firebaseService = FirebaseService();

  AuthService._internal();

  factory AuthService() => _instance;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Current auth status
  AuthStatus get authStatus {
    final user = currentUser;
    if (user == null) return AuthStatus.unauthenticated;
    return AuthStatus.authenticated;
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      // Create user with Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Save user to local database
      final userModel = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveUserToDatabase(userModel);

      // Save user to Firestore
      await _firebaseService.saveUser(userModel);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Load user data from Firestore
      await _loadUserFromFirestore(userCredential.user!.uid);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Save new user to database
        final userModel = UserModel(
          id: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? '',
          email: userCredential.user!.email ?? '',
          profilePhotoPath: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _saveUserToDatabase(userModel);
        await _firebaseService.saveUser(userModel);
      } else {
        // Load existing user data
        await _loadUserFromFirestore(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Sign in with Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status != LoginStatus.success) {
        return null;
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Sign in to Firebase with the Facebook credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(facebookAuthCredential);

      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Get additional user data from Facebook
        final userData = await FacebookAuth.instance.getUserData();

        // Save new user to database
        final userModel = UserModel(
          id: userCredential.user!.uid,
          name: userData['name'] ?? '',
          email: userData['email'] ?? userCredential.user!.email ?? '',
          profilePhotoPath: userData['picture']?['data']?['url'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _saveUserToDatabase(userModel);
        await _firebaseService.saveUser(userModel);
      } else {
        // Load existing user data
        await _loadUserFromFirestore(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Facebook sign in failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update Firebase Auth profile
      await user.updateDisplayName(name);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Update local database
      final existingUser = await getUserFromDatabase(user.uid);
      if (existingUser != null) {
        final updatedUser = existingUser.copyWith(
          name: name ?? existingUser.name,
          phone: phone ?? existingUser.phone,
          profilePhotoPath: photoURL ?? existingUser.profilePhotoPath,
          updatedAt: DateTime.now(),
        );

        await _updateUserInDatabase(updatedUser);
        await _firebaseService.saveUser(updatedUser);
      }
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  // Set emergency PIN
  Future<void> setEmergencyPin(String pin) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Hash the PIN for security
      final hashedPin = _hashPin(pin);

      // Update local database
      final existingUser = await getUserFromDatabase(user.uid);
      if (existingUser != null) {
        final updatedUser = existingUser.copyWith(
          emergencyPin: hashedPin,
          updatedAt: DateTime.now(),
        );

        await _updateUserInDatabase(updatedUser);
        await _firebaseService.saveUser(updatedUser);
      }
    } catch (e) {
      throw Exception('Emergency PIN setup failed: $e');
    }
  }

  // Verify emergency PIN
  Future<bool> verifyEmergencyPin(String pin) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final userData = await getUserFromDatabase(user.uid);
      if (userData?.emergencyPin == null) return false;

      final hashedPin = _hashPin(pin);
      return userData!.emergencyPin == hashedPin;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from all providers
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      await _auth.signOut();

      // Clear local data
      await _clearLocalUserData();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Delete user data from Firestore
      await _firebaseService.deleteUser(user.uid);

      // Clear local data
      await _clearLocalUserData();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  // Get user from local database
  Future<UserModel?> getUserFromDatabase(String userId) async {
    try {
      final userData = await _dbHelper.queryFirst(
        'users_table',
        where: 'id = ?',
        whereArgs: [userId],
      );

      return userData != null ? UserModel.fromMap(userData) : null;
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  Future<void> _saveUserToDatabase(UserModel user) async {
    await _dbHelper.insert('users_table', user.toMap());
  }

  Future<void> _updateUserInDatabase(UserModel user) async {
    await _dbHelper.update(
      'users_table',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> _loadUserFromFirestore(String userId) async {
    try {
      final userData = await _firebaseService.getUser(userId);
      if (userData != null) {
        await _saveUserToDatabase(userData);
      }
    } catch (e) {
      // If we can't load from Firestore, continue with local data
    }
  }

  Future<void> _clearLocalUserData() async {
    await _dbHelper.clearAllData();
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
