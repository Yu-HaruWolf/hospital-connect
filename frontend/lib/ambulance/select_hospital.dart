import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'hospital.dart';
import '../app_state.dart';
import '../custom_widgets/text_with_icon.dart';
import 'package:http/http.dart' as http;

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
        number: map.containsKey('call') ? map['call'] : 'No Number',
        distance: 0.0,
      ));
    }

    setState(() {
      hospitals = result;
    });
  }

  // 関数定義
  /*
  関数概要：病院を近い順にソート
  places 病院のドキュメントのリスト
  origin 現在地[緯度,経度]
  戻り値：ソートされた病院ドキュメントリスト
  */
  List<Hospital> getSortedHospitalList(places, origin) {
    const destinations = [];
    const hospitalList = []; //[[病院ドキュメント0,距離],[病院ドキュメント1,距離],]
    String apiKey =
        'AIzaSyABgyTTcc_NYhjY9yIbadCZYzcPkkDxCzA'; // ここにあなたのAPIキーを入力してください
    places.forEach((value) {
      double originLat = places.place.latitude;
      double originLng = places.place.longitude;
      double destLat = origin[0];
      double destLng = origin[1];
      String mode = 'driving';

      String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?'
          'origins=$originLat,$originLng'
          '&destinations=$destLat,$destLng'
          '&mode=$mode'
          '&key=$apiKey';
      final response = http.get(Uri.parse(url));
      // TODO : リンクから距離を取得してソートする
    });
    return [];
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
