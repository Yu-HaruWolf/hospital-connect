import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hospital_connect/ambulance/department.dart';
import 'package:geolocator/geolocator.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    firebaseInit();
  }

  // 位置情報関係
  bool _isReadyGPS = false;
  bool get isReadyGPS => _isReadyGPS;
  StreamSubscription<Position>? positionStream;
  Position? currentPosition;

  // Firebase Auth関係
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  // Firebase Firestore関係
  StreamSubscription<QuerySnapshot>? _departmentSubscription;
  StreamSubscription<QuerySnapshot>? _requestSubscription;
  int pendingRequest = 0;
  List<Department> _departments = [];
  List<Department> get departments => _departments;
  int userType = -1; // -1:未認証/未登録 1:救急隊 2:病院

  // 病院用関連付け
  String loggedInHospital = "";

  String _userName = "";
  String get userName => _userName;

  Future<void> firebaseInit() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseAuth.instance.userChanges().listen((user) async {
      positionStream?.cancel();
      if (user != null) {
        _loggedIn = true;
        DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!doc.exists) {
          userType = -1;
        } else if (doc.data()!['type'] == 'ambulance') {
          userType = 1;
          if (FirebaseAuth.instance.currentUser!.displayName == null ||
              FirebaseAuth.instance.currentUser!.displayName == "") {
            _userName =
                FirebaseAuth.instance.currentUser!.email!.split(('@'))[0];
          } else {
            _userName = FirebaseAuth.instance.currentUser!.displayName!;
          }
          gpsInit();
        } else if (doc.data()!['type'] == 'hospital') {
          userType = 2;
          loggedInHospital = doc.data()!['hospital'].id;
          var hospitalDoc = await FirebaseFirestore.instance
              .collection('hospital')
              .doc(loggedInHospital)
              .get();
          _userName = hospitalDoc.data()!['name'];
          _requestSubscription = FirebaseFirestore.instance
              .collection('request')
              .where('hospital', isEqualTo: loggedInHospital)
              .where('status', isEqualTo: 'pending')
              .snapshots()
              .listen((snapshot) {
            pendingRequest = snapshot.docs.length;
            notifyListeners();
          });
        }
        _departmentSubscription = FirebaseFirestore.instance
            .collection('department')
            .snapshots()
            .listen((snapshot) {
          _departments = [];
          for (final document in snapshot.docs) {
            _departments
                .add(Department(id: document.id, name: document.data()['en']));
          }
        });
      } else {
        _loggedIn = false;
        _departmentSubscription?.cancel();
        userType = -1;
        loggedInHospital = "";
        _userName = "";
      }
      notifyListeners();
    });
  }

  void gpsInit() async {
    // 位置情報取得権限確認
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      permission = await Geolocator.checkPermission();
    }
    if (permission != LocationPermission.denied) {
      positionStream =
          Geolocator.getPositionStream().listen((Position? position) {
        _isReadyGPS = true;
        currentPosition = position;
        notifyListeners();
      });
    }
  }

  // ローディング
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 表示画面選択
  int _screenId = 0;
  int oldscreenId = 0;
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
  String _selectedHospitalId = "";
  String get selectedHospitalId => _selectedHospitalId;
  set selectedHospitalId(String id) {
    _selectedHospitalId = id;
    notifyListeners();
  }

  // リクエスト選択ステート
  String _selectedRequestId = "";
  String get selectedRequestId => _selectedRequestId;
  set selectedRequestId(String id) {
    _selectedRequestId = id;
    notifyListeners();
  }
}
