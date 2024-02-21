import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'hospital.dart';
import '../app_state.dart';
import '../custom_widgets/text_with_icon.dart';
import '../env/env.dart';

class SelectHospital extends StatefulWidget {
  const SelectHospital({super.key});

  @override
  State<SelectHospital> createState() => _SelectHospitalState();
}

class _SelectHospitalState extends State<SelectHospital> {
  List<Hospital> hospitals = [];

  @override
  Widget build(BuildContext context) {
    Position position = context.read<ApplicationState>().currentPosition != null
        ? context.read<ApplicationState>().currentPosition!
        : Position(
            longitude: 0.0,
            latitude: 0.0,
            timestamp: DateTime.fromMillisecondsSinceEpoch(0),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        context.read<ApplicationState>().screenId = 1;
      },
      child: SingleChildScrollView(
        child: FutureBuilder(
          future: getSortedHospitalList(
              position, context.read<ApplicationState>().selectedDepartments),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error!');
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return Column(
              children: [
                if (snapshot.data!.isEmpty) const Text('No Result'),
                for (Hospital hospital in snapshot.data!)
                  HospitalCard(
                    id: hospital.id,
                    name: hospital.name,
                    address: hospital.address,
                    number: hospital.number,
                    distance: hospital.distance,
                    duration: hospital.duration,
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  // 関数定義
  /*
  関数概要：病院を近い順にソート
  origin 現在地[緯度,経度]
  戻り値：ソートされた病院ドキュメントリスト
  */
  Future<List<Hospital>> getSortedHospitalList(
      Position origin, List<String> selectedDepartments) async {
    int distanceValue; //現在地から病院までの距離
    int durationValue;
    String distanceText;
    String durationText;
    List filteredHospitals = [];

    var snapshot =
        await FirebaseFirestore.instance.collection('hospital').get();
    var documents = snapshot.docs;
    for (var document in documents) {
      bool allDepartmentsSelected = true;

      //selectedDepartmentsがtrueであるかをチェック
      for (var department in selectedDepartments) {
        if (document.data()['department'][department]['accepted'] == false ||
            document.data()['department'][department]['numOfAccepted'] <= 0) {
          allDepartmentsSelected = false;
          break;
        }
      }
      if (allDepartmentsSelected) {
        filteredHospitals.add(document);
      }
    }
    List<Hospital> hospitalList = [];
    final String apiKey = Env.key;
    await Future.forEach(filteredHospitals, (value) async {
      //filterHospitalsは選択された診療科すべて満たす病院ドキュメントのリスト
      dynamic data = value.data();
      String name = data.containsKey('name') ? data['name'] : 'No Name';
      String address =
          data.containsKey('address') ? data['address'] : 'No Name';
      String call = data.containsKey('call') ? data['call'] : 'No Call Number';
      if (!value.data().containsKey('place') ||
          origin.timestamp == DateTime.fromMillisecondsSinceEpoch(0)) {
        hospitalList.add(Hospital(
            id: value.id,
            name: name,
            address: address,
            number: call,
            distance: 'No Result',
            duration: 'No Result',
            distanceValue: 99999,
            durationValue: 99999));
      } else {
        double originLat = value['place'].latitude;
        double originLng = value['place'].longitude;
        double destLat = origin.latitude;
        double destLng = origin.longitude;
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
        if (responseData['rows'][0]['elements'][0]['status'] ==
            "ZERO_RESULTS") {
          distanceValue = 999999;
          hospitalList.add(Hospital(
              id: value.id,
              name: name,
              address: address,
              number: call,
              distance: 'Unreachable',
              duration: '',
              distanceValue: 999999,
              durationValue: 999999));
        } else {
          distanceValue =
              responseData['rows'][0]['elements'][0]['distance']['value'];
          durationValue =
              responseData['rows'][0]['elements'][0]['duration']['value'];
          distanceText =
              responseData['rows'][0]['elements'][0]['distance']['text'];
          durationText =
              responseData['rows'][0]['elements'][0]['duration']['text'];
          hospitalList.add(Hospital(
              id: value.id,
              name: name,
              address: address,
              number: call,
              distance: distanceText,
              duration: durationText,
              distanceValue: distanceValue,
              durationValue: durationValue));
        }
      }
    });
    //ソート
    hospitalList.sort((a, b) => a.distanceValue.compareTo(b.distanceValue));
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
    required this.distance,
    required this.duration,
  });

  final String name;
  final String address;
  final String number;
  final String id;
  final String distance;
  final String duration;
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    TextStyle nameStyle = const TextStyle(
      fontSize: 20,
    );
    TextStyle normalStyle = const TextStyle();
    appState.oldscreenId = appState.screenId;
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
                TextWithIcon(
                    iconData: Icons.directions, text: '$distance($duration)'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
