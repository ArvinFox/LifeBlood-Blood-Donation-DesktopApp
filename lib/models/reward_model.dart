import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  String? rewardId;
  final String rewardName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? imageName;

  Reward({
    this.rewardId,
    required this.rewardName,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.createdAt,
    this.updatedAt,
    this.imageName,
  });

  factory Reward.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Reward(
      rewardId: doc.id,
      rewardName: data['reward_name'] ?? '', 
      description: data['description'] ?? '', 
      startDate: (data['start_date'] as Timestamp).toDate(), 
      endDate: (data['end_date'] as Timestamp).toDate(), 
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null, 
      updatedAt: data['updated_at'] != null ? (data['updated_at'] as Timestamp).toDate() : null, 
      imageName: data['image'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reward_name': rewardName,
      'description': description,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'image': imageName,
    };
  }
}