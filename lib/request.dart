import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  Request({
    required this.id,
    required this.status,
    required this.hospital,
    required this.ambulance,
    required this.patient,
    required this.ambulanceName,
    required this.createTime,
    required this.lastChatTime,
    required this.responseTime,
  });

  final String id;
  final String status;
  final String hospital;
  final String ambulance;
  final List<dynamic> patient;
  final String ambulanceName;
  final Timestamp createTime;
  final Timestamp lastChatTime;
  final Timestamp responseTime;
}
