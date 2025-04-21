import 'package:cloud_firestore/cloud_firestore.dart';

class Rewards {
  final String? rewardId;
  final String rewardName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  Rewards({
    this.rewardId,
    required this.rewardName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'reward_name': rewardName,
      'description': description,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'created_at': DateTime.now()
    };
  }
}