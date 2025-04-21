import 'package:blood_donation_app/models/reward_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  //create reward
  Future<String> addReward(Rewards reward) async {
    final docRef = _firestore.collection('rewards').doc(); 
    final newRewardData = {
      'reward_name': reward.rewardName,
      'description': reward.description,
      'start_date': reward.startDate,
      'end_date': reward.endDate,
      'created_at': reward.createdAt,
    };

    await docRef.set(newRewardData); 

    // get document id
    return docRef.id;
  }
}