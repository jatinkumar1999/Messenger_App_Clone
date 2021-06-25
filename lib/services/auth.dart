import 'package:barbar_app/helper/sharepreference.dart';
import 'package:barbar_app/services/database.dart';
import 'package:barbar_app/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  getCurrentUser() async {
    return await auth.currentUser;
  }

  Future signWithGoogle(BuildContext context) async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );
    UserCredential result = await auth.signInWithCredential(credential);
    User user = result.user;
    if (result != null) {
      SharePreferenceHelper().saveUserEmail(user.email);
      SharePreferenceHelper().saveUserdId(user.uid);
      SharePreferenceHelper().saveUserName(user.displayName);
      SharePreferenceHelper().saveUserProfile(user.photoURL);

      Map<String, dynamic> userMap = {
        "uid": user.uid,
        "name": user.displayName,
        "imgurl": user.photoURL,
        "email": user.email,
      };
      DatabaseServices().uploadUserInfo(user.uid, userMap).then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      });
    }
  }

  signout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    await googleSignIn.disconnect();
    await auth.signOut();
  }
}
