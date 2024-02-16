import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/text_with_icon.dart';
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

void main() {
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
    var appState = context.watch<ApplicationState>();
    //print(appState.selectedHospitalId);
    return MaterialApp(
      title: 'TCU Rescue',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'TCU Rescue'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  void onTapped(int index) {
    var appState = context
        .read<ApplicationState>(); // context.watch() を context.read() に変更

    // _selectedIndex の値に応じて screenId を変更
    if (index == 0) {
      appState.screenId = 2;
    } else if (index == 1) {
      appState.screenId = 4;
    }

    print(appState.screenId); // デバッグ用に screenId を出力
  }

  @override
  Widget build(BuildContext context) {
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
        insideWidget = TopPage();
        break;
      case 1: /*  診療科選択  */
        insideWidget = const SelectDepartment();
        break;
      case 2: /*  搬送先一覧  */
        insideWidget = const SelectHospital();
        break;
      case 3: /*  病院の詳細画面  */
        insideWidget = HospitalDetails();
        break;
      case 4: /*  チャット  */
        insideWidget = ChatRoom();
        break;
      case 5: /*  診療科ごとの人数変更  */
        insideWidget = SettingPage();
        break;
      case 6: /*  リクエスト一覧  */
        insideWidget = RequestListPage();
        break;
      case 7: /*  リクエスト詳細画面  */
        insideWidget = RequestDetail();
        break;
      default:
        insideWidget = const Text('正しいscreenIdを設定してください！');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: insideWidget,
      ),
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Column(
                children: [
                  appState.loggedIn
                      ? Text('Hello, ${userName!}!')
                      : Text('Please sign in.'),
                  if (appState.userType == -1) Text('You are unauthorized.'),
                  if (appState.userType == 1) Text('You are rescue team.'),
                  if (appState.userType == 2) Text('You are hospital staff.'),
                ],
              )),
          ListTile(
              title: TextWithIcon(iconData: Icons.home, text: 'Home'),
              onTap: () {
                Navigator.pop(context);
                appState.screenId = 0;
              }),
          if (appState.userType == 1)
            ListTile(
              title: TextWithIcon(iconData: Icons.search, text: 'Search'),
              onTap: () {
                Navigator.pop(context);
                appState.screenId = 1;
              },
            ),
          if (appState.userType == 2)
            ListTile(
              title: TextWithIcon(iconData: Icons.settings, text: 'Settings'),
              onTap: () {
                Navigator.pop(context);
                appState.screenId = 5;
              },
            ),
          if (appState.userType != -1)
            ListTile(
              title: TextWithIcon(iconData: Icons.fact_check, text: 'Requests'),
              onTap: () {
                Navigator.pop(context);
                appState.screenId = 6;
              },
            ),
        ]),
      ),
      bottomNavigationBar: appState.screenId == 3
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.reply_outlined), label: '戻る'),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'チャット'),
              ],
              currentIndex: _selectedIndex,
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
}
