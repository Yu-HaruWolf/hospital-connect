import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/text_with_icon.dart';
import '../app_state.dart';

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
/*    button_style    */
    ButtonStyle backstyle = const ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Colors.white),
      foregroundColor: MaterialStatePropertyAll(Colors.black),
      side: MaterialStatePropertyAll(BorderSide(color: Colors.black, width: 2)),
    );

    ButtonStyle requeststyle = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Colors.white),
      foregroundColor: MaterialStatePropertyAll(Colors.black),
      side: MaterialStatePropertyAll(BorderSide(color: Colors.black, width: 2)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );

    ButtonStyle chatstyle = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Colors.white),
      foregroundColor: MaterialStatePropertyAll(Colors.black),
      side: MaterialStatePropertyAll(BorderSide(color: Colors.black, width: 2)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );

/*    text_style    */
    TextStyle nameStyle = const TextStyle(
      fontSize: 20,
    );

    TextStyle normalStyle = const TextStyle(
      fontSize: 20,
    );

    TextStyle status_style = const TextStyle(
      fontSize: 20,
    );

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
/*          hospital_info      */
              return Column(
                children: [
                  TextWithIcon(
                      textStyle: nameStyle,
                      iconData: Icons.local_hospital_sharp,
                      text: name),
                  TextWithIcon(
                      textStyle: normalStyle,
                      iconData: Icons.domain,
                      text: address),
                  TextWithIcon(
                      textStyle: normalStyle,
                      iconData: Icons.call,
                      text: number),
                ],
              );
            }),
        TextWithIcon(
          textStyle: status_style,
          iconData: Icons.send,
          text: ('Status: ${statusMessage[hospitalStatus]}'),
        ),

/*          ボタン配置          */
        ElevatedButton(
          onPressed: () {
            appState.screenId = 1;
          },
          child: const Text('Back'),
          style: backstyle,
        ),
        ElevatedButton(
          onPressed: () {
            changeStatus(hospitalStatus == 0 ? 1 : 0);
          },
          child: Text('Change Status'),
          style: requeststyle,
        ),
        ElevatedButton(
          onPressed: () {
            appState.screenId = 4;
          },
          //icon: const Icon(Icons.chat),
          child: Text('chat'),
          style: chatstyle,
        ),
      ],
    );
  }

  void changeStatus(int statusNum) {
    setState(() {
      hospitalStatus = statusNum;
    });
  }
}
