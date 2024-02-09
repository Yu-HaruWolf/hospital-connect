import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:frontend/app_state.dart';
import 'package:provider/provider.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (index) => random.nextInt(255));
  return base64Encode(values);
}

class ChatRoom extends StatefulWidget {
  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final List<types.Message> _messages = [];
  final _user = const types.User(firstName: 'test', id: '00000001');
  final _other = const types.User(firstName: 'test2', id: '0000002');
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => appState.screenId = 3,
      child: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _other,
        showUserNames: true,
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
        author: _other,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: message.text);
    _addMessage(textMessage);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }
}
