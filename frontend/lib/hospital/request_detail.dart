import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../custom_widgets/text_with_icon.dart';

class RequestDetail extends StatelessWidget {
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();

    var docRef_request = FirebaseFirestore.instance
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
    ButtonStyle approvebutton = ButtonStyle(
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
            future: docRef_request,
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
              final timeOfLastChat =
                  snapshot.data!.data()!.containsKey('timeOfLastChat')
                      ? snapshot.data!.data()!['timeOfLastChat']
                      : 'No timeOfLastChat';
              Timestamp timeOfResponse =
                  snapshot.data!.data()!.containsKey('timeOfResponse')
                      ? snapshot.data!.data()!['timeOfResponse']
                      : 'No timeOfResponse';
              final hospitalId = snapshot.data!.data()!['hospital'];

              var docRef_hospital = FirebaseFirestore.instance
                  .collection('hospital')
                  .doc(hospitalId)
                  .get();

              return Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        return Column(
                          children: [
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
                        if (appState.userType == 1)
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
                          '<最終チャット日時>',
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
                          '<最終更新日時>',
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
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: appState.userType == 2 && status == 'pending'
                                ? ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Approve'),
                                    style: approvebutton,
                                  )
                                : null),
                      ]),
                ],
              );
            }),
      ),
    );
  }
}

//関数：requestのstatusを変更する approve, pedding, reject
void updateRequestStatus(String requestId, String status) {
  var now = FieldValue.serverTimestamp();
  DocumentReference requestRef =
      FirebaseFirestore.instance.collection('request').doc(requestId);
  requestRef.update({'status': status, "timeOfResponse": now});
}

// チャットのやりとり、最終更新日時を更新する関数。引数requestID
void updateLastChatTime(String requestId) {
  // FlutterのDateTime.now()だと端末情報の時間を取得してしまう
  //サーバー環境に依存した時間を取り出したい場合
  var now = FieldValue.serverTimestamp();
  DocumentReference requestRef =
      FirebaseFirestore.instance.collection('request').doc(requestId);
  requestRef.update({
    "timeOfLastChat": now,
  });
}
