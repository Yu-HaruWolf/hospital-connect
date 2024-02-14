import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ambulance/department.dart';
import 'package:geolocator/geolocator.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  // Firebase Auth関係
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  // Firebase Firestore関係
  StreamSubscription<QuerySnapshot>? _departmentSubscription;
  List<Department> _departments = [];
  List<Department> get departments => _departments;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _departmentSubscription = FirebaseFirestore.instance
            .collection('department')
            .snapshots()
            .listen((snapshot) {
          _departments = [];
          for (final document in snapshot.docs) {
            _departments
                .add(Department(id: document.id, name: document.data()['ja']));
          }
        });
      } else {
        _loggedIn = false;
        _departmentSubscription?.cancel();
      }
      notifyListeners();
    });

    // 位置情報取得権限確認
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  // 表示画面選択
  int _screenId = 7;
  int get screenId => _screenId;
  set screenId(int value) {
    _screenId = value;
    notifyListeners();
  }

  // 診療科選択ステート
  List<String> _selectedDepartments = [];
  List<String> get selectedDepartments => _selectedDepartments;
  set selectedDepartments(List<String> departments) {
    _selectedDepartments = departments;
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
