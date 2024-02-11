import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app_state.dart';
import 'package:frontend/sign_in_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    return Column(
      children: [
        SignInButton(Buttons.email,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignInPage('Email')))),
        SignInButton(Buttons.google,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignInPage('Google')))),
        if (appState.loggedIn) Text('Logged In!'),
        SignOutButton(),
      ],
    );
  }
}
