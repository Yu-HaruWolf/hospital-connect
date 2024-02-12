import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/text_with_icon.dart';
import 'package:provider/provider.dart';

import 'ambulance/hospital_detail.dart';
import 'ambulance/select_department.dart';
import 'ambulance/select_hospital.dart';
import 'ambulance/chat_room.dart';
import 'top_page.dart';
import 'app_state.dart';

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
    print(appState.selectedHospitalId);
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    Widget insideWidget;
    switch (appState.screenId) {
      case 0:
        insideWidget = TopPage();
        break;
      case 1:
        insideWidget = const SelectDepartment();
        break;
      case 2:
        insideWidget = const SelectHospital();
        break;
      case 3:
        insideWidget = HospitalDetails();
        break;
      case 4:
        insideWidget = ChatRoom();
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
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.red,
              )),
          ListTile(
            title: TextWithIcon(iconData: Icons.home, text: 'Home'),
            onTap: () {
              appState.screenId = 0;
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: TextWithIcon(iconData: Icons.search, text: 'Search'),
            onTap: () {
              appState.screenId = 1;
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }
}
