import 'package:cloud_firestore/cloud_firestore.dart';

class DonationEvents {
  final String? eventId;
  final String eventName;
  final String description;
  final DateTime dateAndTime;
  final DateTime createdAt;
  final String location;

  DonationEvents({
    this.eventId,
    required this.eventName,
    required this.description,
    required this.dateAndTime,
    required this.createdAt,
    required this.location,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'event_name': eventName,
      'description': description,
      'date': Timestamp.fromDate(dateAndTime),
      'created_at': DateTime.now(),
      'location': location,
    };
  }
}
