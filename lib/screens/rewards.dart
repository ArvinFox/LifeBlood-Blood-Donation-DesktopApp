import 'dart:convert';
import 'package:blood_donation_app/components/add_data.dart';
import 'package:blood_donation_app/models/reward_model.dart';
import 'package:blood_donation_app/services/reward_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Rewardscreen extends StatelessWidget {
  const Rewardscreen({super.key});

  Future<void> createReward(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final rewardService = RewardService();
    try {
      final dateFormat = DateFormat('d-M-yyyy');
      final Rewards reward = Rewards(
        rewardName: data['title'],
        description: data['description'],
        startDate: dateFormat.parse(data['startDate']),
        endDate: dateFormat.parse(data['endDate']),
        createdAt: DateTime.now(),
      );
      final rewardId = await rewardService.addReward(reward);

      if (data['poster'] != null && data['poster'].toString().isNotEmpty) {
        await uploadRewardImage(context, data['poster'], rewardId);
      }

      Helpers.showSucess(context, 'Reward added successfully');
    } catch (e) {
      Helpers.showError(context, 'Error.....');
      Helpers.debugPrintWithBorder('Error : $e');
    }
  }

  Future<String?> uploadRewardImage(
    BuildContext context,
    String base64Image,
    String rewardId,
  ) async {
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

  Future<void> deleteReward(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rewards')
          .doc(docId)
          .delete();
      Helpers.showSucess(context, 'Reward deleted successfully');
    } catch (e) {
      Helpers.showError(context, 'Failed to delete reward');
      Helpers.debugPrintWithBorder('Delete error: $e');
    }
  }

  Future<void> editRewardDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final TextEditingController rewardNameController = TextEditingController(
      text: data['reward_name'],
    );
    final TextEditingController descriptionController = TextEditingController(
      text: data['description'],
    );
    final TextEditingController startDateController = TextEditingController(
      text: DateFormat('d-M-yyyy').format(data['start_date'].toDate()),
    );
    final TextEditingController endDateController = TextEditingController(
      text: DateFormat('d-M-yyyy').format(data['end_date'].toDate()),
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Reward'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _styledInput(rewardNameController, 'Reward Name'),
                    const SizedBox(height: 10),
                    _styledInput(descriptionController, 'Description'),
                    const SizedBox(height: 10),
                    _styledInput(startDateController, 'Start Date (d-M-yyyy)'),
                    const SizedBox(height: 10),
                    _styledInput(endDateController, 'End Date (d-M-yyyy)'),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final dateFormat = DateFormat('d-M-yyyy');
                    await FirebaseFirestore.instance
                        .collection('rewards')
                        .doc(docId)
                        .update({
                          'reward_name': rewardNameController.text.trim(),
                          'description': descriptionController.text.trim(),
                          'start_date': dateFormat.parse(
                            startDateController.text.trim(),
                          ),
                          'end_date': dateFormat.parse(
                            endDateController.text.trim(),
                          ),
                        });
                    Navigator.of(context).pop();
                    Helpers.showSucess(context, 'Reward updated successfully');
                  } catch (e) {
                    Helpers.showError(context, 'Failed to update reward');
                    Helpers.debugPrintWithBorder('Edit error: $e');
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  Widget _styledInput(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Center(
            child: Text(
              'Manage Rewards',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AddData(
                          formType: FormType.rewards,
                          onSubmit: (data) async {
                            await createReward(context, data);
                          },
                        ),
                  );
                },
                icon: const Icon(Icons.add_circle, color: Colors.redAccent),
                label: const Text(
                  'Add Reward',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              double tableWidth = constraints.maxWidth * 0.95;
              double columnWidth = tableWidth / 4;

              return StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('rewards')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No rewards found.');
                  }

                  final docs = snapshot.data!.docs;

                  return SizedBox(
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                        (states) => const Color(0xFFE0E0E0),
                      ),
                      dataRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.shade100,
                      ),
                      dataRowHeight: 60,
                      columnSpacing: 0,
                      border: TableBorder.all(color: Colors.black54),
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Center(
                              child: const Text(
                                'ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Center(
                              child: const Text(
                                'Reward Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Center(
                              child: const Text(
                                'Description',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Center(
                              child: const Text(
                                'Actions',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: List.generate(docs.length, (index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Center(child: Text('${index + 1}')),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Center(
                                  child: Text(data['reward_name'] ?? ''),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Center(
                                  child: Text(data['description'] ?? ''),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed:
                                            () => editRewardDialog(
                                              context,
                                              doc.id,
                                              data,
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 15,
                                          ),
                                          backgroundColor: Colors.yellow[800],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Edit'),
                                      ),
                                      const SizedBox(width: 18),
                                      ElevatedButton(
                                        onPressed:
                                            () => deleteReward(context, doc.id),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 25,
                                            vertical: 15,
                                          ),
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),

                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}