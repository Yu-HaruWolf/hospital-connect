import 'dart:async';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_widgets/text_with_icon.dart';
import '../app_state.dart';

class HospitalDetails extends StatefulWidget {
  const HospitalDetails({super.key});

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
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    var docRef = FirebaseFirestore.instance
        .collection('hospital')
        .doc(appState.selectedHospitalId)
        .get();

    /*    Text Style    */
    TextStyle nameStyle = const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );

    TextStyle normalStyle = const TextStyle(
      fontSize: 20,
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        appState.screenId = 2;
      },
      child: Stack(
        children: [
          SingleChildScrollView(
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
                      InkWell(
                        onTap: () async {
                          final Uri callLaunchUri = Uri(
                            scheme: 'tel',
                            path: number,
                          );
                          if (await canLaunchUrl(callLaunchUri)) {
                            await launchUrl(callLaunchUri);
                          } else {
                            final Error error = ArgumentError(
                                'Could not launch $callLaunchUri');
                            throw error;
                          }
                        },
                        child: TextWithIcon(
                          textStyle: TextStyle(
                              fontSize: 20,
                              decoration: TextDecoration.underline),
                          iconData: Icons.call,
                          text: number,
                        ),
                      ),
                    ],
                  );
                }),
          ),
          if (appState.isLoading)
            const Opacity(
              opacity: 0.7,
              child: ModalBarrier(
                dismissible: true,
                color: Colors.black,
              ),
            ),
          if (appState.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
