import 'package:cloud_firestore/cloud_firestore.dart';

class DonationEvent {
  String? eventId;
  final String eventName;
  final String description;
  final String location;
  final DateTime dateAndTime;
  DateTime? createdAt;
  DateTime? updatedAt;

  DonationEvent({
    this.eventId,
    required this.eventName,
    required this.description,
    required this.location,
    required this.dateAndTime,
    this.createdAt,
    this.updatedAt,
  });

  factory DonationEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return DonationEvent(
      eventId: doc.id,
      eventName: data['event_name'] ?? '', 
      description: data['description'] ?? '', 
      location: data['location'] ?? '', 
      dateAndTime: (data['date_and_time'] as Timestamp).toDate(), 
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
      updatedAt: data['updated_at'] != null ? (data['updated_at'] as Timestamp).toDate() : null, 
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'event_name': eventName,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(dateAndTime),
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
