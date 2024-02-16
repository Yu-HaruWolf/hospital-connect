import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hospital.dart';
import '../app_state.dart';
import '../custom_widgets/text_with_icon.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectHospital extends StatefulWidget {
  const SelectHospital({super.key});

  @override
  State<SelectHospital> createState() => _SelectHospitalState();
}

class _SelectHospitalState extends State<SelectHospital> {
  List<Hospital> hospitals = [];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        context.read<ApplicationState>().screenId = 1;
      },
      child: SingleChildScrollView(
        child: FutureBuilder(
          future: getSortedHospitalList([35.73550690100909, 139.8005679376201]),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error!');
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return Column(
              // TODO : 表示したい内容を変更（距離とか）
              children: [
                for (dynamic value in snapshot.data!)
                  HospitalCard(
                    id: '0',
                    name: 'name',
                    address: 'address',
                    number: value['distance'].toString(),
                  )
              ],
            );
            /*
            return Column(
              children: [
                for (Hospital hospital in hospitals)
                  HospitalCard(
                    name: hospital.name,
                    address: hospital.address,
                    number: hospital.number,
                    id: hospital.id,
                  ),
              ],
            );
            */
          },
        ),
      ),
    );
  }

  Future<bool> loadHospitals() async {
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
    return true;
  }

  // 関数定義
  /*
  関数概要：病院を近い順にソート
  places 病院のドキュメントのリスト
  origin 現在地[緯度,経度]
  戻り値：ソートされた病院ドキュメントリスト
  */
  Future<List<dynamic>> getSortedHospitalList(origin) async {
    var snapshot =
        await FirebaseFirestore.instance.collection('hospital').get();
    List<Map<String, dynamic>> hospitalList = [];
    String apiKey = 'AIzaSyABgyTTcc_NYhjY9yIbadCZYzcPkkDxCzA';
    await Future.forEach(snapshot.docs, (value) async {
      double originLat = value['place'].latitude;
      double originLng = value['place'].longitude;
      double destLat = origin[0];
      double destLng = origin[1];
      String mode = 'driving';

      String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?'
          'origins=$originLat,$originLng'
          '&destinations=$destLat,$destLng'
          '&mode=$mode'
          '&key=$apiKey';
      final response = await http.get(Uri.parse(url));
      final responseBody = response.body;
      // リンクから距離を取得してソートする
      Map<String, dynamic> responseData = json.decode(responseBody);
      int distanceValue = responseData['rows'][0]['elements'][0]['distance']
          ['value']; // TODO: 到達不能の時どうするか
      hospitalList.add({'place': value, 'distance': distanceValue});
    });
    //ソート
    hospitalList.sort((a, b) => a['distance'].compareTo(b['distance']));
    return hospitalList;
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
