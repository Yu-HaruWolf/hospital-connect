import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    return ElevatedButton(
        onPressed: () {
          signInWithGoogle();
        },
        child: Text('Login'));
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
