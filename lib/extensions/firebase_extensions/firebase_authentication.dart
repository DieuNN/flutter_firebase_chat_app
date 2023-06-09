
import 'package:chat_app/extensions/firebase_extensions/firebase_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

extension FirebaseAuthenticationExtensions on FirebaseAuth {
  static Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    var user = FirebaseAuth.instance.currentUser;
    if (isNewUser(
        creationTime: user?.metadata.creationTime?.millisecondsSinceEpoch,
        lastSignInTime:
            user?.metadata.lastSignInTime?.millisecondsSinceEpoch)) {
      await FirebaseFirestoreExtensions.initUserData(
        uid: user!.uid,
        email: user.email!,
        photoUrl: user.photoURL,
        name: user.displayName!,
      );
    }

    return user;
  }

  // If user created their account 3 seconds ago, so it's new account, otherwise not
  static bool isNewUser({int? creationTime, int? lastSignInTime}) {
    return (lastSignInTime! - creationTime!) <
        const Duration(seconds: 3).inMilliseconds;
  }

  static Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    var user = FirebaseAuth.instance.currentUser;

    return user;
  }

  static void signOut() {
    FirebaseAuth.instance.signOut();
  }

  static Future<void> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    var user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestoreExtensions.initUserData(
      name: name,
      email: user!.email!,
      uid: user.uid,
    );
  }

  static Future<void> updateUserCredential(
      {required String email,
      required String displayName,
      required String password,
      String? profileUrl}) async {
    assert(FirebaseAuth.instance.currentUser != null);

    await FirebaseAuth.instance.currentUser!.updateEmail(email);
    await FirebaseAuth.instance.currentUser!.updateDisplayName(displayName);
    await FirebaseAuth.instance.currentUser!.updatePassword(password);
    if (profileUrl != null) {
      await FirebaseAuth.instance.currentUser!.updatePhotoURL(profileUrl);
    }
  }

  static Future<void> forgetPasswordByEmail({required String email}) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
