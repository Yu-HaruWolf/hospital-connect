import 'dart:async';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/text_with_icon.dart';
import '../app_state.dart';

class HospitalDetails extends StatefulWidget {
  @override
  State<HospitalDetails> createState() => _HospitalDetailsState();
}

class _HospitalDetailsState extends State<HospitalDetails> {
  Position? currentPosition;
  late StreamSubscription<Position> positionStream;

  int hospitalStatus = 0;
  List<String> statusMessage = ['リクエスト未作成', 'リクエスト作成済み'];

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
    Future(() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    });

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      currentPosition = position;
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
  }

  //関数作成 // 診療科(複数個)、病院のドキュメントID、progress
  void createRequest(String hospitalId, List<String> patientsName) {
    var now = FieldValue.serverTimestamp();
    //Timestamp now = Timestamp.fromDate()
    //DateTime now = DateTime.now(); //現在の日時を取得
    /* マップで管理した方が見やすい？　ただ、クエリで検索するときできるか不安
    Map<String, dynamic> timeData = {
      'lastChatTime' : now,
      'createRequestTime' : now,
      'responseTime' : '',
    };
    */
    final List<DocumentReference<Map<String, dynamic>>> patientDocumentRefs =
        [];
    for (var value in patientsName) {
      patientDocumentRefs
          .add(FirebaseFirestore.instance.collection('department').doc(value));
    }
    FirebaseFirestore.instance.collection('request').add({
      "ambulance": FirebaseAuth.instance.currentUser!.uid,
      "hospital": hospitalId,
      "status": 'pending',
      "patient": patientDocumentRefs,
      "timeOfCreatingRequest": now,
      "timeOfLastChat": now,
      "timeOfResponse": now,
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    var docRef = FirebaseFirestore.instance
        .collection('hospital')
        .doc(appState.selectedHospitalId)
        .get();

    /*    button_style    */
    ButtonStyle requeststyle = ButtonStyle(
      backgroundColor: const MaterialStatePropertyAll(Colors.white),
      foregroundColor: const MaterialStatePropertyAll(Colors.black),
      side: const MaterialStatePropertyAll(
          BorderSide(color: Colors.black, width: 2)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );

    /*    Text Style    */
    TextStyle nameStyle = const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );

    TextStyle normalStyle = const TextStyle(
      fontSize: 20,
    );

    TextStyle statusStyle = TextStyle(
      fontSize: 25,
      color: hospitalStatus == 0 ? Colors.red : Colors.green,
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        appState.screenId = 2;
      },
      child: SingleChildScrollView(
        child: FutureBuilder(
            future: docRef,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error!');
              }
              if (!snapshot.hasData) {
                return const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                );
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
              final GeoPoint? geopoint =
                  snapshot.data!.data()!.containsKey('place')
                      ? snapshot.data!.data()!['place']
                      : null;
              late Marker marker;
              late LatLng latLng;
              Set<Marker> markers = {};
              if (geopoint != null) {
                latLng = LatLng(geopoint.latitude, geopoint.longitude);
                marker = Marker(
                  markerId: const MarkerId('0'),
                  position: latLng,
                );
                markers.add(marker);
              }
              /*          hospital_info      */
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (geopoint != null)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: latLng,
                          zoom: 15.0,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        markers: markers,
                        gestureRecognizers: {
                          Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer())
                        },
                      ),
                    ),
                  Text(
                    name,
                    style: nameStyle,
                  ),
                  TextWithIcon(
                    textStyle: normalStyle,
                    iconData: Icons.domain,
                    text: address,
                  ),
                  TextWithIcon(
                    textStyle: normalStyle,
                    iconData: Icons.call,
                    text: number,
                  ),
                  TextWithIcon(
                    textStyle: statusStyle,
                    iconData: Icons.send,
                    text: ('Status: ${statusMessage[hospitalStatus]}'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      changeStatus(hospitalStatus == 0 ? 1 : 0);
                      createRequest(appState.selectedHospitalId,
                          appState.selectedDepartments);
                    },
                    style: requeststyle,
                    child: Text(hospitalStatus == 0 ? 'Request' : 'cancel'),
                  ),
                ],
              );
            }),
      ),
    );
  }

  void changeStatus(int statusNum) {
    setState(() {
      hospitalStatus = statusNum;
    });
  }
}
