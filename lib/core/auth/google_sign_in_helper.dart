import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thrown when the user backs out of the native Google account picker.
/// Not an error — callers should treat this as a silent no-op, not show
/// an error banner.
class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
}

/// Runs the native Google Sign-In flow, exchanges the resulting Google
/// credential for a Firebase session, and returns a fresh Firebase ID
/// token — the one value the backend's `/auth/firebase/exchange` and
/// `/auth/legacy/link/verify` endpoints actually need.
///
/// Shared by `google_sign_in_screen.dart` (Phase 13 primary login) and
/// `legacy_account_link_screen.dart` (Phase 13 recovery flow, step 2) so
/// the two screens can't drift on how a Firebase session gets created.
///
/// Throws [GoogleSignInCancelled] if the user backs out of the picker.
/// Any other failure (no Play Services, network, misconfigured
/// `google-services.json`) propagates as whatever `google_sign_in`/
/// `firebase_auth` themselves throw — callers show a generic error.
Future<String> signInWithGoogleGetIdToken() async {
  final googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) {
    throw const GoogleSignInCancelled();
  }

  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    idToken: googleAuth.idToken,
    accessToken: googleAuth.accessToken,
  );

  final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
  final idToken = await userCredential.user?.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw StateError('Firebase did not return an ID token after sign-in');
  }
  return idToken;
}
