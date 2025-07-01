import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) return null; // User canceled

      // Obtain the auth details from the request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }
}
