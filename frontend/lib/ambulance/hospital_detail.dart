import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      "timeOfCreatingRequest" : now,
      "timeOfLastChat" : FieldValue.delete(),
      "timeOfResponse" : FieldValue.delete()
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        appState.screenId = 2;
      },
      child: Column(
        children: [
          FutureBuilder(
              future: docRef,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error!');
                }
                if (!snapshot.hasData) {
                  return Row(
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
                final GeoPoint geopoint =
                    snapshot.data!.data()!.containsKey('place')
                        ? snapshot.data!.data()!['place']
                        : null;
                late Marker marker;
                late LatLng latLng;
                if (geopoint != null) {
                  latLng = LatLng(geopoint.latitude, geopoint.longitude);
                  marker = Marker(
                    markerId: MarkerId('0'),
                    position: latLng,
                  );
                } else {
                  latLng = LatLng(0, 0);
                  marker = Marker(markerId: MarkerId('0'), position: latLng);
                }
                Set<Marker> markers = {};
                markers.add(marker);
                /*          hospital_info      */
                return Column(
                  children: [
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
                      ),
                    ),
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
              appState.screenId = 2;
            },
            child: const Text('Back'),
            style: backstyle,
          ),
          ElevatedButton(
            onPressed: () {
              changeStatus(hospitalStatus == 0 ? 1 : 0);
              createRequest(
                  appState.selectedHospitalId,
                  appState
                      .selectedDepartments); // 診療科(複数こ)、病院のドキュメントID,救急車のUserUID、progress
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
      ),
    );
  }

  void changeStatus(int statusNum) {
    setState(() {
      hospitalStatus = statusNum;
    });
  }
}
