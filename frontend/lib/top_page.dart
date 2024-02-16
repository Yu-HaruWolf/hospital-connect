import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'app_state.dart';
import 'sign_in_page.dart';

class TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    if (appState.loggedIn) {
      Widget signOutButton = ElevatedButton.icon(
          onPressed: () => logout(),
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'));
      switch (appState.userType) {
        case -1:
          return Column(
            children: [
              Text('You are unauthorized.'),
              signOutButton,
            ],
          );
        case 1:
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 80,
                    child: ElevatedButton(
                        onPressed: () {
                          appState.screenId = 6;
                        },
                        child: Text('リクエスト一覧'))),
              ),
              signOutButton,
            ],
          );
        case 2:
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 80,
                    child: ElevatedButton(
                        onPressed: () {
                          appState.screenId = 6;
                        },
                        child: Text('リクエスト一覧'))),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: () {
                      appState.screenId = 5;
                    },
                    child: Text('人数変更'),
                  ),
                ),
              ),
              signOutButton,
            ],
          );
      }
      return Text('Unknown Screen');
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
