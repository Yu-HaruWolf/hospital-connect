import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_connect/custom_widgets/text_with_icon.dart';
import 'package:provider/provider.dart';

import 'ambulance/hospital_detail.dart';
import 'ambulance/select_department.dart';
import 'ambulance/select_hospital.dart';
import 'ambulance/chat_room.dart';
import 'hospital/setting_page.dart';
import 'top_page.dart';
import 'app_state.dart';
import 'request_list_page.dart';
import 'hospital/request_detail.dart';

Future<void> main() async {
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    String title;
    var appState = context.watch<ApplicationState>();
    String? userName;
    if (appState.loggedIn) {
      if (FirebaseAuth.instance.currentUser!.displayName == null ||
          FirebaseAuth.instance.currentUser!.displayName == "") {
        userName = FirebaseAuth.instance.currentUser!.email!.split(('@'))[0];
      } else {
        userName = FirebaseAuth.instance.currentUser!.displayName!;
      }
    }
    Widget insideWidget;
    switch (appState.screenId) {
      case 0:
        insideWidget = const TopPage();
        title = "Hospital Connect";
        break;
      case 1: /*  診療科選択  */
        insideWidget = const SelectDepartment();
        title = "Select Departments";
        break;
      case 2: /*  搬送先一覧  */
        insideWidget = const SelectHospital();
        title = "Select Hospital";
        break;
      case 3: /*  病院の詳細画面  */
        insideWidget = HospitalDetails();
        title = "Hospital Detail";
        break;
      case 4: /*  チャット  */
        insideWidget = const ChatRoom();
        title = "Chat Room";
        break;
      case 5: /*  診療科ごとの人数変更  */
        insideWidget = const SettingPage();
        title = "Setting";
        break;
      case 6: /*  リクエスト一覧  */
        insideWidget = const RequestListPage();
        title = "Request List";
        break;
      case 7: /*  リクエスト詳細画面  */
        insideWidget = RequestDetail();
        title = "Request Detail";
        break;
      default:
        insideWidget = const Text('正しいscreenIdを設定してください！');
        title = "Hospital Connect";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: insideWidget,
      ),
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Column(
                children: [
                  appState.loggedIn
                      ? Text('Hello, ${userName!}!')
                      : const Text('Please sign in.'),
                  if (appState.userType == -1)
                    const Text('You are unauthorized.'),
                  if (appState.userType == 1)
                    const Text('You are rescue team.'),
                  if (appState.userType == 2)
                    const Text('You are hospital staff.'),
                ],
              )),
          ListTile(
              title: const TextWithIcon(iconData: Icons.home, text: 'Home'),
              onTap: () {
                Navigator.pop(context);
                appState.screenId = 0;
              }),
          if (appState.userType == 1)
            ListTile(
              title: const TextWithIcon(iconData: Icons.search, text: 'Search'),
              onTap: () {
                Navigator.pop(context);
                appState.screenId = 1;
              },
            ),
          if (appState.userType == 2)
            ListTile(
              title: const TextWithIcon(
                  iconData: Icons.settings, text: 'Settings'),
              onTap: () {
                Navigator.pop(context);
                appState.screenId = 5;
              },
            ),
          if (appState.userType != -1)
            ListTile(
              title: const TextWithIcon(
                  iconData: Icons.fact_check, text: 'Requests'),
              onTap: () {
                Navigator.pop(context);
                appState.screenId = 6;
              },
            ),
        ]),
      ),
      bottomNavigationBar: appState.screenId == 3 || appState.screenId == 7
          ? BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.reply_outlined), label: '戻る'),
                if (appState.screenId == 3)
                  BottomNavigationBarItem(
                      icon: Icon(Icons.send), label: 'Request'),
                if (appState.screenId == 7)
                  BottomNavigationBarItem(
                      icon: Icon(Icons.chat), label: 'チャット'),
              ],
              selectedItemColor: Colors.black,
              selectedFontSize: 20,
              unselectedFontSize: 20,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: const IconThemeData(color: Colors.white),
              selectedLabelStyle: const TextStyle(color: Colors.black),
              unselectedLabelStyle: const TextStyle(color: Colors.black),
              backgroundColor: Colors.red,
              onTap: onTapped,
            )
          : null,
    );
  }

  Future<void> onTapped(int index) async {
    var appState = context
        .read<ApplicationState>(); // context.watch() を context.read() に変更

    if (index == 0) {
      appState.screenId = appState.oldscreenId;
    } else if (index == 1) {
      if (appState.screenId == 3) {
        appState.isLoading = true;
        await createRequest(
            appState.selectedHospitalId, appState.selectedDepartments);
        appState.isLoading = false;
      } else if (appState.screenId == 7) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ChatRoom()));
      }
    }
  }

  Future<void> createRequest(
      String hospitalId, List<String> patientsName) async {
    var now = FieldValue.serverTimestamp();
    final List<DocumentReference<Map<String, dynamic>>> patientDocumentRefs =
        [];
    for (var value in patientsName) {
      patientDocumentRefs
          .add(FirebaseFirestore.instance.collection('department').doc(value));
    }
    final doc = await FirebaseFirestore.instance.collection('request').add({
      "ambulance": FirebaseAuth.instance.currentUser!.uid,
      "hospital": hospitalId,
      "status": 'pending',
      "patient": patientDocumentRefs,
      "lastActionBy": 'ambulance',
      "timeOfCreatingRequest": now,
      "timeOfLastChat": now,
      "timeOfResponse": now,
    });
    context.read<ApplicationState>().selectedRequestId = doc.id;
    context.read<ApplicationState>().oldscreenId = 6;
    context.read<ApplicationState>().screenId = 7;
  }
}
