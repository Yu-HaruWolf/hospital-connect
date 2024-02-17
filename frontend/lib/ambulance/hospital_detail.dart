import 'dart:async';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
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
      backgroundColor: const MaterialStatePropertyAll(Colors.white),
      foregroundColor: const MaterialStatePropertyAll(Colors.black),
      side:const  MaterialStatePropertyAll(BorderSide(color: Colors.black, width: 2)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );

    ButtonStyle chatstyle = ButtonStyle(
      backgroundColor: const MaterialStatePropertyAll(Colors.white),
      foregroundColor: const MaterialStatePropertyAll(Colors.black),
      side: const MaterialStatePropertyAll(BorderSide(color: Colors.black, width: 2)),
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

    return Column(
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
                    const CircularProgressIndicator(),
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
              late LatLng latlng;
              if (geopoint != null) {
                marker = Marker(
                  markerId: MarkerId('0'),
                  position: LatLng(geopoint.latitude, geopoint.longitude),
                );
              } else {
                marker =
                    Marker(markerId: MarkerId('0'), position: LatLng(0, 0));
              }
              Set<Marker> markers = {};
              markers.add(marker);

/*          hospital_info      */
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(45, -122),
                        zoom: 11.0,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: markers,
                    ),
                  ),
                  /*
                  TextWithIcon(
                      textStyle: nameStyle,
                      iconData: Icons.local_hospital_sharp,
                      text: name),*/
                  Text(name,style: nameStyle,),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child:
                  TextWithIcon(
                      textStyle: normalStyle,
                      iconData: Icons.domain,
                      text: address),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child:
                  TextWithIcon(
                      textStyle: normalStyle,
                      iconData: Icons.call,
                      text: number),
                  ),
                ],
              );
            }),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:EdgeInsets.only(top: 10),
              child:
              TextWithIcon(
                textStyle: status_style,
                iconData: Icons.send,
                text: ('${statusMessage[hospitalStatus]}'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10,left: 20),
              child:
            ElevatedButton(
              onPressed: () {
                changeStatus(hospitalStatus == 0 ? 1 : 0);
              },
              child: Text(hospitalStatus == 0 ?'Request' :'cancel'),
              style: requeststyle,
            ),
            ),
          ],
        ),
/*          ボタン配置          */
/*
        ElevatedButton(
          onPressed: () {
            appState.screenId = 1;
          },
          child: const Text('Back'),
          style: backstyle,
        ),
        
        ElevatedButton(
          onPressed: () {
            appState.screenId = 4;
          },
          //icon: const Icon(Icons.chat),
          child: Text('chat'),
          style: chatstyle,
        ),
        */
    ],
  );

  }

  void changeStatus(int statusNum) {
    setState(() {
      hospitalStatus = statusNum;
    });
  }
}