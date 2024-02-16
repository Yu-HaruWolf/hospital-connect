import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:frontend/app_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  SignInPage(this.signInMethod, {super.key});
  String signInMethod;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    if (appState.loggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pop(context);
      });
    }
    Widget insideWidget;
    switch (signInMethod) {
      case 'Google':
        signInWithGoogle();
        insideWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            const Text('Loading')
          ],
        );
      case 'Email':
        insideWidget = SignInScreen(
          providers: [EmailAuthProvider()],
        );
      default:
        insideWidget = const Text('Unknown Sign-in method');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in($signInMethod)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: insideWidget,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    try {
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
    }

    return;
  }
}
