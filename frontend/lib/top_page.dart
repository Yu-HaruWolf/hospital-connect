import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ambulance/select_department.dart';
import 'package:frontend/app_state.dart';
import 'package:frontend/sign_in_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    if (appState.loggedIn) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 80,
                child: ElevatedButton(
                    onPressed: () {
                      appState.screenId = 1;
                    },
                    child: Text('病院を検索'))),
          ),
          ElevatedButton.icon(
              onPressed: () => logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out')),
        ],
      );
    } else {
      // 未ログイン時
      return Column(
        children: [
          SignInButton(Buttons.email,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignInPage('Email')))),
          SignInButton(Buttons.google,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignInPage('Google')))),
        ],
      );
    }
  }

  Future<void> logout() async {
    final googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    return FirebaseAuth.instance.signOut();
  }
}
