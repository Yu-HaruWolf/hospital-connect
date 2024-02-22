import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_connect/request.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'custom_widgets/text_with_icon.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({super.key});

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  List<Request> requests = [];
  late StreamSubscription<QuerySnapshot> documentSubscription;

  @override
  void initState() {
    super.initState();
    getRequestList();
  }

  @override
  void dispose() {
    super.dispose();
    documentSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        context.read<ApplicationState>().screenId = 0;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (Request request in requests)
              RequestCard(
                  title: request.patient,
                  department: request.hospital,
                  lastUpdateTime: request.lastChatTime.toDate().toString(),
                  status: request.status,
                  id: request.id),
          ],
        ),
      ),
    );
  }

  Future<void> getRequestList() async {
    Query<Map<String, dynamic>> query;
    if (context.read<ApplicationState>().userType == 2) {
      query = FirebaseFirestore.instance.collection('request').where('hospital',
          isEqualTo: context.read<ApplicationState>().loggedInHospital);
    } else {
      query = FirebaseFirestore.instance.collection('request').where(
          'ambulance',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    }
    documentSubscription = query
        .orderBy('timeOfLastChat', descending: true)
        .snapshots()
        .listen((event) {
      setState(() {
        requests = [];
        for (var doc in event.docs) {
          requests.add(Request(
              id: doc.id,
              status: doc.data()['status'],
              hospital: doc.data()['hospital'],
              ambulance: doc.data()['ambulance'],
              patient: doc.data()['patient'],
              createTime: doc.data()['timeOfCreatingRequest'],
              lastChatTime: doc.data()['timeOfLastChat'],
              responseTime: doc.data()['timeOfResponse']));
        }
      });
    });
    return;
  }
}

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.title,
    required this.department,
    required this.lastUpdateTime,
    required this.status,
    required this.id,
  });

  final List<dynamic> title;
  final String department;
  final String lastUpdateTime;
  final String status;
  final String id;

  Future<String> getDepartmentsName(List<dynamic> docs) async {
    String result = "";
    for (DocumentReference<Map<String, dynamic>> doc in docs) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();
      String name = snapshot.data()!['ja'];
      if (result != "") {
        result += ",$name";
      } else {
        result += name;
      }
    }
    if (result == "") result = "No Department";
    return result;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    var hospital =
        FirebaseFirestore.instance.collection('hospital').doc(department).get();
    TextStyle nameStyle = const TextStyle(
      fontSize: 20,
    );
    TextStyle normalStyle = const TextStyle();
    late Color cardColor;
    switch (status) {
      case 'pending':
        cardColor = Theme.of(context).cardColor;
        break;
      case 'accepted':
        cardColor = Theme.of(context).cardColor;
        break;
      case 'denied':
        cardColor = Colors.grey;
        break;
      default:
        cardColor = Theme.of(context).cardColor;
        break;
    }

    appState.oldscreenId = appState.screenId;
    return Card(
      color: cardColor,
      child: InkWell(
        onTap: () {
          appState.selectedRequestId = id;
          appState.screenId = 7;
        },
        child: Badge(
          alignment: Alignment.topLeft,
          label: Text('Pending'),
          isLabelVisible: status == 'pending',
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: getDepartmentsName(title),
                      builder: (context, snapshot) {
                        return TextWithIcon(
                            iconData: Icons.fact_check,
                            text: snapshot.hasData ? snapshot.data! : '',
                            textStyle: nameStyle);
                      }),
                  FutureBuilder(
                      future: hospital,
                      builder: (context, snapshot) {
                        return TextWithIcon(
                            textStyle: normalStyle,
                            iconData: Icons.domain,
                            text:
                                snapshot.hasData ? snapshot.data!['name'] : '');
                      }),
                  TextWithIcon(
                      textStyle: normalStyle,
                      iconData: Icons.schedule,
                      text: lastUpdateTime),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
