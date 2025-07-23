import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Check if email is already registered
  static Future<List<String>> getSignInMethodsForEmail(String email) async {
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        email,
      );
      return methods;
    } catch (e) {
      print('Error checking sign-in methods: $e');
      return [];
    }
  }

  // Check if email exists and return provider info
  static Future<EmailStatus> checkEmailStatus(String email) async {
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        email,
      );

      if (methods.isEmpty) {
        return EmailStatus.available;
      } else if (methods.contains('password')) {
        return EmailStatus.registeredWithPassword;
      } else if (methods.contains('google.com')) {
        return EmailStatus.registeredWithGoogle;
      } else {
        return EmailStatus.registeredWithOther;
      }
    } catch (e) {
      print('Error checking email status: $e');
      return EmailStatus.unknown;
    }
  }

  // Sign up with email and password (with email conflict check)
  static Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // First check if email is already registered
    final emailStatus = await checkEmailStatus(email);

    switch (emailStatus) {
      case EmailStatus.registeredWithPassword:
        throw EmailAlreadyExistsException(
          'This email is already registered. Please sign in with your password.',
          SignInMethod.password,
        );
      case EmailStatus.registeredWithGoogle:
        throw EmailAlreadyExistsException(
          'This email is already registered with Google. Please sign in with Google.',
          SignInMethod.google,
        );
      case EmailStatus.registeredWithOther:
        throw EmailAlreadyExistsException(
          'This email is already registered with another provider.',
          SignInMethod.other,
        );
      case EmailStatus.available:
        // Email is available, proceed with registration
        break;
      case EmailStatus.unknown:
        // Continue anyway if we can't check
        break;
    }

    try {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Double-check the provider if our initial check missed it
        final emailStatus = await checkEmailStatus(email);
        if (emailStatus == EmailStatus.registeredWithGoogle) {
          throw EmailAlreadyExistsException(
            'This email is already registered with Google. Please sign in with Google.',
            SignInMethod.google,
          );
        } else {
          throw EmailAlreadyExistsException(
            'This email is already registered. Please sign in with your password.',
            SignInMethod.password,
          );
        }
      }
      rethrow;
    }
  }

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google (with email conflict check)
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out from any existing Google session to force account picker
      await _googleSignIn.signOut();

      // Attempt to sign in
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      // If user cancels the sign-in process
      if (gUser == null) {
        print('Google Sign-In cancelled by user');
        return null;
      }

      // Check if this email is already registered with password
      final emailStatus = await checkEmailStatus(gUser.email);

      if (emailStatus == EmailStatus.registeredWithPassword) {
        // Sign out from Google since we can't proceed
        await _googleSignIn.signOut();
        throw EmailAlreadyExistsException(
          'This email is already registered with a password. Please sign in with your email and password instead.',
          SignInMethod.password,
        );
      }

      // Get authentication details
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Check if we have the required tokens
      if (gAuth.accessToken == null || gAuth.idToken == null) {
        throw Exception('Failed to get authentication tokens from Google');
      }

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      print('Google Sign-In successful for: ${userCredential.user?.email}');
      return userCredential;
    } on EmailAlreadyExistsException {
      // Re-throw our custom exception
      rethrow;
    } on PlatformException catch (e) {
      print(
        'PlatformException during Google Sign-In: ${e.code} - ${e.message}',
      );

      switch (e.code) {
        case 'sign_in_failed':
          throw Exception(
            'Google Sign-In configuration error. Please check your setup.',
          );
        case 'network_error':
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        case 'sign_in_canceled':
          return null;
        default:
          throw Exception('Google Sign-In failed: ${e.message}');
      }
    } catch (e) {
      print('General error during Google Sign-In: $e');
      rethrow;
    }
  }

  // Complete sign out from both Firebase and Google
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
      print('Successfully signed out from all services');
    } catch (e) {
      print('Error during sign out: $e');
      await FirebaseAuth.instance.signOut();
    }
  }

  // Check if Google Play Services is available
  static Future<bool> isGooglePlayServicesAvailable() async {
    try {
      await _googleSignIn.signInSilently();
      return true;
    } catch (e) {
      print('Google Play Services not available: $e');
      return false;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  // Check if user is signed in
  static bool isSignedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete user account
  static Future<void> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Re-authenticate user (required for sensitive operations)
  static Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  static Future<void> changePassword(String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Verify email
  static Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Check if email is verified
  static bool isEmailVerified() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.emailVerified ?? false;
  }

  // Reload user to get updated information
  static Future<void> reloadUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Enum for email status
enum EmailStatus {
  available,
  registeredWithPassword,
  registeredWithGoogle,
  registeredWithOther,
  unknown,
}

// Enum for sign-in methods
enum SignInMethod { password, google, other }

// Custom exception for email conflicts
class EmailAlreadyExistsException implements Exception {
  final String message;
  final SignInMethod signInMethod;

  EmailAlreadyExistsException(this.message, this.signInMethod);

  @override
  String toString() => message;
}

// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, this.code);

  @override
  String toString() => message;
}
