import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'app_state.dart';
import 'sign_in_page.dart';

class TopPage extends StatefulWidget {
  const TopPage({super.key});

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  int numOfPending = 0;
  @override
  void initState() {
    super.initState();
    if (context.read<ApplicationState>().userType == 2) getNumOfPending();
  }

  void getNumOfPending() async {
    final count = await FirebaseFirestore.instance
        .collection('request')
        .where('hospital',
            isEqualTo: context.read<ApplicationState>().loggedInHospital)
        .count()
        .get();
    setState(() {
      numOfPending = count.count!;
    });
  }

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
              const Text('You are unauthorized.'),
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
                        child: const Text('Search the hospitals'))),
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
                        child: const Text('Request List'))),
              ),
              signOutButton,
              Text('GPS: ${appState.isReadyGPS ? 'Ready.' : 'Not Ready.'}'),
            ],
          );
        case 2:
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Badge(
                  alignment: Alignment.topLeft,
                  label: Text(appState.pendingRequest.toString()),
                  isLabelVisible: true,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 80,
                    child: ElevatedButton(
                        onPressed: () {
                          appState.screenId = 6;
                        },
                        child: const Text('Request List')),
                  ),
                ),
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
                    child: const Text(
                        'Change the number of people who can be accepted'),
                  ),
                ),
              ),
              signOutButton,
            ],
          );
      }
      return const Text('Unknown Screen');
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
