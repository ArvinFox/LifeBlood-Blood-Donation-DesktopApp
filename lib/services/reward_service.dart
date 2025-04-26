import 'package:blood_donation_app/models/reward_model.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  //create reward
  Future<String> addReward(Reward reward) async {
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

  //delete reward
  Future<void> deleteReward(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('rewards').doc(docId).delete();
      Helpers.showSucess(context, 'Reward deleted successfully');
    } catch (e) {
      Helpers.showError(context, 'Failed to delete reward');
      Helpers.debugPrintWithBorder('Delete error: $e');
    }
  }

  //delete reward poster from supabase when deleting a rewad
  Future<void> deleteRewardImage(String rewardId) async {
    try {
      final imageName = 'reward_image_$rewardId.jpg';
      final imagePath = '$rewardId/$imageName';

      final response = await Supabase.instance.client.storage
          .from('rewards')
          .remove([imagePath]);

      if (response.isEmpty) {
        print('Image deleted successfully from Supabase Storage.');
      } else {
        print('Some files were not deleted: $response');
      }
    } catch (e) {
      print('Error deleting image from Supabase Storage: $e');
    }
  }

  //update reward
  Future<void> updateReward(String rewardId,Map<String, dynamic> updatedData) async{
    await FirebaseFirestore.instance.collection('rewards').doc(rewardId).update(updatedData);
  }
}