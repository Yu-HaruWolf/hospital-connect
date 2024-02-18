import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../custom_widgets/text_with_icon.dart';

class RequestDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextWithIcon(iconData: Icons.phone, text: '000000000'),
        const TextWithIcon(iconData: Icons.domain, text: 'Departments'),
        ElevatedButton(onPressed: () {}, child: const Text('Approve')),
        ElevatedButton(onPressed: () {}, child: const Text('Chat')),
      ],
    );
  }
}

//関数：requestのstatusを変更する approve, pedding, reject
void updateRequestStatus(String requestId, String status){
  var now = FieldValue.serverTimestamp();
  DocumentReference requestRef = FirebaseFirestore.instance
        .collection('request')
        .doc(requestId);
  requestRef.update({
    'status' : status,
    "timeOfResponse" : now
  });
}

// チャットのやりとり、最終更新日時を更新する関数。引数requestID
void updateLastChatTime(String requestId){
  // FlutterのDateTime.now()だと端末情報の時間を取得してしまう
  //サーバー環境に依存した時間を取り出したい場合
  var now = FieldValue.serverTimestamp();
  DocumentReference requestRef = FirebaseFirestore.instance
        .collection('request')
        .doc(requestId);
  requestRef.update({
    "timeOfLastChat" : now,
  });
}