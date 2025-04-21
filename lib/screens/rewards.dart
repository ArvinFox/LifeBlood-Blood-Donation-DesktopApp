import 'dart:convert';
import 'package:blood_donation_app/components/add_data.dart';
import 'package:blood_donation_app/models/reward_model.dart';
import 'package:blood_donation_app/services/reward_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Rewardscreen extends StatelessWidget {
  const Rewardscreen({super.key});

  Future<void> createReward(BuildContext context, Map<String,dynamic> data) async{
    final rewardService = RewardService();

    try{
      final dateFormat = DateFormat('d-M-yyyy');
      
      final Rewards reward = Rewards(
        rewardName: data['title'], 
        description: data['description'], 
        startDate: dateFormat.parse(data['startDate']), 
        endDate: dateFormat.parse(data['endDate']),
        createdAt: DateTime.now()
      );

      final rewardId = await rewardService.addReward(reward);

      if(data['poster'] != null && data['poster'].toString().isNotEmpty){
        await uploadRewardImage(context, data['poster'], rewardId);
      }

      Helpers.showSucess(context, 'Reward added sucessfully');
    } catch(e){
      Helpers.showError(context, 'Error.....');
      Helpers.debugPrintWithBorder('Error : $e');
    }
  }

  Future<String?> uploadRewardImage(BuildContext context,String base64Image, String rewardId) async {
    try {
      final imageBytes = base64Decode(base64Image);

      final imageName = 'reward_image_$rewardId.jpg';
      final imagePath = '$rewardId/$imageName';

      final response = await Supabase.instance.client.storage
          .from('rewards')
          .uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'), 
          );

      if (response != null) {
        final publicUrl = Supabase.instance.client.storage
            .from('rewards')
            .getPublicUrl(imagePath);

        Helpers.debugPrintWithBorder('Reward image uploaded to: $publicUrl');
        return publicUrl;
      } else {
        Helpers.showError(context, "Failed to upload reward image.");
        return null;
      }
    } catch (e) {
      Helpers.debugPrintWithBorder('Image upload error: $e');
      Helpers.showError(context, "Error uploading reward image.");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: const Text(
              'Manage Rewards',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddData(
                      formType: FormType.rewards, 
                      onSubmit: (data) async{
                        await createReward(context, data);
                      }
                    ),
                  );
                },
                icon: Icon(Icons.add_circle, color: Colors.redAccent),
                label: Text(
                  'Add Reward',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}