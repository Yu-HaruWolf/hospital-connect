import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hospital.dart';
import '../app_state.dart';
import '../custom_widgets/text_with_icon.dart';

class SelectHospital extends StatefulWidget {
  const SelectHospital({super.key});

  @override
  State<SelectHospital> createState() => _SelectHospitalState();
}

class _SelectHospitalState extends State<SelectHospital> {
  List<Hospital> hospitals = [];

  @override
  initState() {
    super.initState();
    loadHospitals();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (Hospital hospital in hospitals)
            HospitalCard(
              name: hospital.name,
              address: hospital.address,
              number: hospital.number,
              id: hospital.id,
            ),
        ],
      ),
    );
  }

  Future<void> loadHospitals() async {
    List<Hospital> result = [];
    var value = await FirebaseFirestore.instance.collection('hospital').get();

    for (var docSnapshot in value.docs) {
      Map<String, dynamic> map = docSnapshot.data();
      result.add(Hospital(
          id: docSnapshot.id,
          name: map.containsKey('name') ? map['name'] : 'No Name',
          address: map.containsKey('address') ? map['address'] : 'No Address',
          number: map.containsKey('call') ? map['call'] : 'No Number'));
    }

    setState(() {
      hospitals = result;
    });
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
          appState.screenId = 3;
          // Firebaseにアクセスするのはこんな感じ？
          /*
          FirebaseFirestore.instance.collection('hospital').get().then(
            (value) {
              print("Successfully completed");
              for (var docSnapshot in value.docs) {
                print('${docSnapshot.id} => ${docSnapshot.data()}');
              }
            },
            onError: (e) => print("Error getting document: $e"),
          );
          */
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
