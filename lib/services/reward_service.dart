import 'package:blood_donation_app/models/reward_model.dart';
import 'package:blood_donation_app/services/supabase_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RewardService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseService _supabaseService = SupabaseService();
  
  // Create reward
  Future<void> _createReward(Reward reward) async {
    try {
      await _firestore.collection('rewards').doc(reward.rewardId).set(reward.toFirestore());
    } catch (e) {
      Helpers.debugPrintWithBorder("Error adding reward: $e");
    }
  }

  // Get next ID
  String _getNextRewardDocId() {
    return _firestore.collection('rewards').doc().id;
  }

  // Get reward by ID
  Future<Reward?> getRewardById(String rewardId) async {
    try {
      DocumentSnapshot rewardDoc = await _firestore.collection("rewards").doc(rewardId).get();
      if (!rewardDoc.exists) return null;

      return Reward.fromFirestore(rewardDoc);
      
    } catch (e) {
      throw Exception("Failed to get reward by id: $e");
    }
  }

  // Update reward
  Future<void> _updateReward(Reward reward) async {
    try {
      await _firestore.collection('rewards').doc(reward.rewardId).update(reward.toFirestore());
    } catch (e) {
      throw Exception("Failed to update reward: $e");
    }
  }

  // Add/Edit reward
  Future<void> manageReward(BuildContext context, Map<String, dynamic> data, {String? rewardId, bool isEdit = false, Future<void> Function()? onRewardManaged}) async {
    try {
      final Reward reward = Reward(
        rewardName: data['title'],
        description: data['description'],
        startDate: DateFormat('d-M-yyyy').parse(data['startDate']),
        endDate: DateFormat('d-M-yyyy').parse(data['endDate']),
      );

      if (!isEdit) {
        final now = DateTime.now();
        reward.createdAt = now;
        reward.updatedAt = now;

        final newRewardId = _getNextRewardDocId();
        reward.rewardId = newRewardId;

        if (data['poster'] != null && data['poster'].toString().isNotEmpty) {
          final imageName = await _uploadRewardImage(context, data['poster'], newRewardId);
          reward.imageName = imageName;
        }

        await _createReward(reward);
        
      } else {
        reward.rewardId = rewardId;
        reward.createdAt = data['createdAt'];
        reward.updatedAt = DateTime.now();

        if (data['poster'] != null && data['poster'].toString().isNotEmpty) {
          final imageName = await _uploadRewardImage(context, data['poster'], rewardId!);
          reward.imageName = imageName;
        }

        await _updateReward(reward);
      }

      Helpers.showSucess(context, 'Reward ${isEdit ? 'updated' : 'added'} successfully');
      
      if (onRewardManaged != null) {
        await onRewardManaged();
      }
      
    } catch (e) {
      Helpers.showError(context, 'Error ${isEdit ? 'updating' : 'adding'} reward');
      Helpers.debugPrintWithBorder('Error ${isEdit ? 'updating' : 'creating'} reward: $e');
    }
  }

  Future<String?> _uploadRewardImage(BuildContext context, String base64Image, String rewardId) async {
    try {
      final imageName = await _supabaseService.uploadImage('reward', base64Image, rewardId);
      return imageName;

    } catch (e) {
      Helpers.debugPrintWithBorder('Image upload error: $e');
      Helpers.showError(context, "Error uploading reward image.");
      return null;
    }
  }

  // Delete reward
  Future<void> deleteReward(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('rewards').doc(docId).delete();
    } catch (e) {
      Helpers.showError(context, 'Failed to delete reward');
      Helpers.debugPrintWithBorder('Error deleting reward: $e');
    }
  }
}