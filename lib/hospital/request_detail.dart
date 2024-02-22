import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hospital_connect/request_settings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../custom_widgets/text_with_icon.dart';

class RequestDetail extends StatefulWidget {
  const RequestDetail({super.key});

  @override
  State<RequestDetail> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
  DateTime nowTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        nowTime = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();

    var docRefRequest = FirebaseFirestore.instance
        .collection('request')
        .doc(appState.selectedRequestId)
        .get();

/*  テキストスタイル  */
    TextStyle normalStyle = const TextStyle(fontSize: 20);
    TextStyle titleStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
    );
    TextStyle nameStyle = const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );
    ButtonStyle responseButtonStyle = ButtonStyle(
      backgroundColor: const MaterialStatePropertyAll(Colors.white),
      foregroundColor: const MaterialStatePropertyAll(Colors.red),
      side: const MaterialStatePropertyAll(
          BorderSide(color: Colors.black, width: 2)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        appState.screenId = 6;
      },
      child: SingleChildScrollView(
        child: FutureBuilder(
            future: docRefRequest,
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

              final timeOfCreatingRequest =
                  snapshot.data!.data()!.containsKey('timeOfCreatingRequest')
                      ? snapshot.data!.data()!['timeOfCreatingRequest']
                      : 'No timeOfCreatingRequest';
              final status = snapshot.data!.data()!.containsKey('status')
                  ? snapshot.data!.data()!['status']
                  : 'No timeOfLastChat';
              final Timestamp timeOfLastChat =
                  snapshot.data!.data()!.containsKey('timeOfLastChat')
                      ? snapshot.data!.data()!['timeOfLastChat']
                      : 'No timeOfLastChat';
              Timestamp timeOfResponse =
                  snapshot.data!.data()!.containsKey('timeOfResponse')
                      ? snapshot.data!.data()!['timeOfResponse']
                      : 'No timeOfResponse';
              final hospitalId = snapshot.data!.data()!['hospital'];
              List<String> requestedDepartments = [];
              final departments = snapshot.data!.data()!.containsKey('patient')
                  ? snapshot.data!.data()!['patient']
                  : [];
              for (DocumentReference<Map<String, dynamic>> department
                  in departments) {
                requestedDepartments.add(department.id);
              }

              var docRef_hospital = FirebaseFirestore.instance
                  .collection('hospital')
                  .doc(hospitalId)
                  .get();

              return Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (DateTime.now().millisecondsSinceEpoch -
                          timeOfLastChat.toDate().millisecondsSinceEpoch >=
                      60000)
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                          child: Text(
                              'Please Response!${((nowTime.millisecondsSinceEpoch - timeOfLastChat.toDate().millisecondsSinceEpoch) / 1000).toInt()}s')),
                    ),
                  FutureBuilder(
                      future: docRef_hospital,
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
                        final address =
                            snapshot.data!.data()!.containsKey('address')
                                ? snapshot.data!.data()!['address']
                                : 'No Address';
                        final number =
                            snapshot.data!.data()!.containsKey('call')
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
                          latLng =
                              LatLng(geopoint.latitude, geopoint.longitude);
                          marker = Marker(
                            markerId: const MarkerId('0'),
                            position: latLng,
                          );
                          markers.add(marker);
                        }
                        return Column(
                          children: [
                            if (geopoint != null)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
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
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '<リクエスト送信日時>',
                          style: titleStyle,
                        ),
                        TextWithIcon(
                          iconData: Icons.send,
                          textStyle: normalStyle,
                          text: timeOfCreatingRequest.toDate().toString(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '<最終更新日時>',
                          style: titleStyle,
                        ),
                        TextWithIcon(
                            iconData: Icons.schedule,
                            textStyle: normalStyle,
                            text: timeOfResponse.toDate().toString()),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '<最終チャット日時>',
                          style: titleStyle,
                        ),
                        TextWithIcon(
                            iconData: Icons.chat,
                            textStyle: normalStyle,
                            text: timeOfLastChat.toDate().toString()),
                      ],
                    ),
                  ),
                  //if(appState.userType ==2)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'リクエスト状況:  ${status}',
                          style: TextStyle(
                            fontSize: 25,
                            color:
                                status == 'pending' ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.all(10),
                                child: appState.userType == 2 &&
                                        status == 'pending'
                                    ? ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RequestSettingPage(
                                                      requestedDepartments,
                                                      departments:
                                                          requestedDepartments,
                                                    )),
                                          );
                                          updateRequestStatus(
                                              appState.selectedRequestId,
                                              'accepted');
                                        },
                                        child: const Text('Accept'),
                                        style: responseButtonStyle,
                                      )
                                    : null),
                            Padding(
                                padding: EdgeInsets.all(10),
                                child: appState.userType == 2 &&
                                        status == 'pending'
                                    ? ElevatedButton(
                                        onPressed: () {
                                          updateRequestStatus(
                                              appState.selectedRequestId,
                                              'denied');
                                        },
                                        child: const Text('Deny'),
                                        style: responseButtonStyle,
                                      )
                                    : null),
                          ],
                        ),
                      ]),
                ],
              );
            }),
      ),
    );
  }
}

void updateRequestStatus(String requestId, String status) {
  var now = FieldValue.serverTimestamp();
  DocumentReference requestRef =
      FirebaseFirestore.instance.collection('request').doc(requestId);
  requestRef.update({'status': status, "timeOfResponse": now});
}

void updateLastChatTime(String requestId) {
  var now = FieldValue.serverTimestamp();
  DocumentReference requestRef =
      FirebaseFirestore.instance.collection('request').doc(requestId);
  requestRef.update({
    "timeOfResponse": now,
    "timeOfLastChat": now,
  });
}
