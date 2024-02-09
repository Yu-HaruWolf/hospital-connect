import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app_state.dart';
import 'package:provider/provider.dart';

class HospitalDetails extends StatefulWidget {
  @override
  State<HospitalDetails> createState() => _HospitalDetailsState();
}

class _HospitalDetailsState extends State<HospitalDetails> {
  int hospitalStatus = 0;
  List<String> statusMessage = ['リクエスト未作成', 'リクエスト作成済み'];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    var docRef = FirebaseFirestore.instance
        .collection('hospital')
        .doc(appState.selectedHospitalId)
        .get();
    return Column(
      children: [
        FutureBuilder(
            future: docRef,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error!');
              }
              if (!snapshot.hasData) {
                return const Text('Loading');
              }

              final name = snapshot.data!.data()!.containsKey('name')
                  ? snapshot.data!.data()!['name']
                  : 'No Name';
              final address = snapshot.data!.data()!.containsKey('address')
                  ? snapshot.data!.data()!['address']
                  : 'No Address';
              final number = snapshot.data!.data()!.containsKey('call')
                  ? snapshot.data!.data()!['call']
                  : 'No call';
              return Column(
                children: [
                  Text(name),
                  Text(address),
                  Text(number),
                ],
              );
            }),
        Text('Status: ${statusMessage[hospitalStatus]}'),
        ElevatedButton(
            onPressed: () {
              appState.screenId = 1;
            },
            child: const Text('Back')),
        ElevatedButton(
            onPressed: () {
              changeStatus(hospitalStatus == 0 ? 1 : 0);
            },
            child: Text('Change Status')),
        ElevatedButton(
            onPressed: () {
              appState.screenId = 4;
            },
            child: Text('Chat')),
      ],
    );
  }

  void changeStatus(int statusNum) {
    setState(() {
      hospitalStatus = statusNum;
    });
  }
}
