import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  // Firebase Auth関係
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }

  // 表示画面選択
  int _screenId = -1;
  int get screenId => _screenId;
  set screenId(int value) {
    _screenId = value;
    notifyListeners();
  }

  // 病院選択ステート
  var _selectedHospitalId = "";
  String get selectedHospitalId => _selectedHospitalId;
  set selectedHospitalId(String id) {
    _selectedHospitalId = id;
    notifyListeners();
  }
}
