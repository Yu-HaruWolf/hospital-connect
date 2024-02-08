import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app_state.dart';
import 'package:frontend/main.dart';
import 'package:provider/provider.dart';

class SelectHospital extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < 10; i++)
            HospitalCard(
              name: 'name',
              address: 'Address',
              number: 'Number',
              id: i.toString(),
            ),
        ],
      ),
    );
  }
}

class HospitalCard extends StatelessWidget {
  const HospitalCard({
    super.key,
    required this.name,
    required this.address,
    required this.number,
    required this.id,
  });

  final String name;
  final String address;
  final String number;
  final String id;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    TextStyle nameStyle = const TextStyle(
      fontSize: 20,
    );
    TextStyle normalStyle = const TextStyle();
    return Card(
      child: InkWell(
        onTap: () {
          appState.selectedHospitalId = id;
          appState.screenId = 1;
          // Firebaseにアクセスするのはこんな感じ？
          FirebaseFirestore.instance.collection('hospital').get().then(
            (value) {
              print("Successfully completed");
              for (var docSnapshot in value.docs) {
                print('${docSnapshot.id} => ${docSnapshot.data()}');
              }
            },
            onError: (e) => print("Error getting document: $e"),
          );
          //
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWithIcon(
                    iconData: Icons.local_hospital,
                    text: name,
                    textStyle: nameStyle),
                TextWithIcon(
                    textStyle: normalStyle,
                    iconData: Icons.domain,
                    text: address),
                TextWithIcon(
                    textStyle: normalStyle, iconData: Icons.call, text: number),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextWithIcon extends StatelessWidget {
  const TextWithIcon({
    super.key,
    required this.textStyle,
    required this.iconData,
    required this.text,
  });

  final TextStyle textStyle;
  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          iconData,
          color: Colors.black38,
        ),
        Text(
          text,
          style: textStyle,
        ),
      ],
    );
  }
}
