import 'dart:async';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  //関数作成
  void createRequest(String hospitalId) {}

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

    /*    text_style    */
    TextStyle nameStyle = const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );

    TextStyle normalStyle = const TextStyle(
      fontSize: 20,
    );

    TextStyle status_style = TextStyle(
      fontSize: 25,
      color: hospitalStatus == 0 ? Colors.red : Colors.green,
    );

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          appState.screenId = 2;
        },
        child: Column(children: [
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      name,
                      style: nameStyle,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: TextWithIcon(
                          textStyle: normalStyle,
                          iconData: Icons.domain,
                          text: address),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: TextWithIcon(
                          textStyle: normalStyle,
                          iconData: Icons.call,
                          text: number),
                    )
                  ],
                );
              }),
          Row(children: [
            // TODO: レイアウト確認 画面をオーバーすることあり
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: TextWithIcon(
                textStyle: status_style,
                iconData: Icons.send,
                text: ('Status: ${statusMessage[hospitalStatus]}'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 20),
              child: ElevatedButton(
                onPressed: () {
                  changeStatus(hospitalStatus == 0 ? 1 : 0);
                },
                child: Text(hospitalStatus == 0 ? 'Request' : 'cancel'),
                style: requeststyle,
              ),
            ),
          ])
        ]));
  }

  void changeStatus(int statusNum) {
    setState(() {
      hospitalStatus = statusNum;
    });
  }
}
