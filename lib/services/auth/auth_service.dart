import 'package:cirqle/services/database/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance; // getting instance

  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;

  // login
  Future<UserCredential> loginEmailPassword(String email, password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // register
  Future<UserCredential> registerEmailPassword(String email, password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //signout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // delete users
  Future<void> deleteAccount() async {
    User? user = getCurrentUser();

    if (user != null) {
      // delete users data from firestore
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);

      // delete the user's auth record
      await user.delete();
    }
  }
}
