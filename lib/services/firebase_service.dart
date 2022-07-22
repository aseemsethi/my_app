import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'parse_claims.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> signInwithGoogle() async {
    try {
      print('signInwithGoogle..');
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      print('signInwithGoogle...done');

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
      print("My id token claims:...");
      print(parseJwt(googleSignInAuthentication.idToken.toString()));
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }

  Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
