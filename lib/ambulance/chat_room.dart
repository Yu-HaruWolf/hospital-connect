import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:hospital_connect/app_state.dart';
import 'package:provider/provider.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (index) => random.nextInt(255));
  return base64Encode(values);
}

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  late CollectionReference<Map<String, dynamic>> chatCollection;
  late StreamSubscription<QuerySnapshot> _chatMessageSubscription;
  List<types.TextMessage> _messages = [];
  final _user = types.User(id: FirebaseAuth.instance.currentUser!.uid);

  @override
  initState() {
    super.initState();
    chatCollection = FirebaseFirestore.instance
        .collection('request')
        .doc(context.read<ApplicationState>().selectedRequestId)
        .collection('chat');
    _chatMessageSubscription = chatCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _messages = [];
        for (final document in snapshot.docs) {
          _messages.add(types.TextMessage(
            author: types.User(id: document.data()['authorId']),
            id: document.id,
            createdAt: document.data()['createdAt'],
            text: document.data()['text'],
          ));
        }
      });
    });
  }

  @override
  void dispose() {
    _chatMessageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold を返す
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Chat Room'),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        showUserNames: true,
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: message.text);
    _addMessage(textMessage);
  }

  void _addMessage(types.TextMessage message) {
    Map<String, dynamic> data = {
      "authorId": message.author.id,
      "createdAt": message.createdAt,
      "text": message.text,
    };
    FirebaseFirestore.instance
        .collection('request')
        .doc(context.read<ApplicationState>().selectedRequestId)
        .update({
      "lastActionBy": context.read<ApplicationState>().userType == 1
          ? 'ambulance'
          : 'hospital'
    });
    chatCollection.add(data);
    updateLastChatTime();
    setState(() {
      _messages.insert(0, message);
    });
  }

  void updateLastChatTime() {
    String requestId = context.read<ApplicationState>().selectedRequestId;
    var now = FieldValue.serverTimestamp();
    DocumentReference requestRef =
        FirebaseFirestore.instance.collection('request').doc(requestId);
    requestRef.update({
      "timeOfLastChat": now,
    });
  }
}
