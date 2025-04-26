import 'dart:convert';
import 'package:blood_donation_app/components/add_data.dart';
import 'package:blood_donation_app/components/table.dart';
import 'package:blood_donation_app/models/reward_model.dart';
import 'package:blood_donation_app/services/reward_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Rewardscreen extends StatefulWidget {
  const Rewardscreen({super.key});

  @override
  State<Rewardscreen> createState() => _RewardscreenState();
}

class _RewardscreenState extends State<Rewardscreen> {
  final rewardService = RewardService();
  final TextEditingController rewardNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  List<Map<String, dynamic>> rewards = [];

  @override
  void initState() {
    super.initState();
    fetchRewards();
  }

  Future<void> createReward(BuildContext context,Map<String, dynamic> data) async {
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

  Future<String?> uploadRewardImage(BuildContext context,String base64Image,String rewardId) async {
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

  Future<void> fetchRewards({bool applyFilters = false}) async {
    try {
      final query = await FirebaseFirestore.instance.collection('rewards');

      final snapshot = await query.get();

      final inputDate = startDateController.text.isNotEmpty
        ? DateFormat('d-M-yyyy').parse(startDateController.text)
        : null;
    
      final filtered = snapshot.docs.where((item) {
        final rewardName = item['reward_name']?.toString().toLowerCase() ?? '';
        final startDateTimestamp = item['start_date'] as Timestamp?;

        final nameMatch = rewardNameController.text.isEmpty || rewardName.contains(rewardNameController.text.toLowerCase());

        final dateMatch = inputDate == null || (
          startDateTimestamp != null &&
          startDateTimestamp.toDate().year == inputDate.year &&
          startDateTimestamp.toDate().month == inputDate.month &&
          startDateTimestamp.toDate().day == inputDate.day
        );

        return nameMatch && dateMatch;
      }).toList();

      setState(() {
        rewards = filtered.map((doc) {
          final docData = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'reward_name': (docData['reward_name'] ?? '').toString(),
            'description': (docData['description'] ?? '').toString(),
            'start_date': docData['start_date'],
            'end_date': docData['end_date'],

          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching rewards: $e');
      Helpers.showError(context, 'Failed to load rewards');
    }
  }

  Future<void> editRewardDialog(BuildContext context,String docId,Map<String, dynamic> data) async {
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
      builder: (_) => AlertDialog(
        title: const Text('Edit Reward'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _styledInput(rewardNameController, 'Reward Name'),
                const SizedBox(height: 10),
                _styledInput(descriptionController, 'Description'),
                const SizedBox(height: 10),
                _buildDateField(context, startDateController, 'Start Date'),
                const SizedBox(height: 10),
                _buildDateField(context, endDateController, 'End Date'),
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
                final updatedData = {
                  'reward_name': rewardNameController.text,
                  'description': descriptionController.text,
                  'start_date': DateFormat('d-M-yyyy').parse(startDateController.text),
                  'end_date': DateFormat('d-M-yyyy').parse(endDateController.text),
                };
                rewardService.updateReward(docId, updatedData);
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

  void searchReward() {
    fetchRewards();
  }

  void resetFilters() {
    rewardNameController.clear();
    startDateController.clear();
    fetchRewards();
  }

  void _showDeleteConfirmation(BuildContext context, String docId, String rewardName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Delete Confirmation",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete this reward?',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {
                  0: FixedColumnWidth(120),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Reward Name:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(rewardName),
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); 
              await rewardService.deleteRewardImage(docId);
              await rewardService.deleteReward(context, docId);
              Helpers.showSucess(context, 'Reward deleted successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white),)
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                      builder:(_) => AddData(
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
                    style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.redAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            //search and filter
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildSearchAndFilter(),
                    const SizedBox(height: 20),
                    // Display message if no rewards
                    if (rewards.isEmpty) 
                      Center(
                        child: Text(
                          'No Rewards Available.',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      )
                    else 
                      DynamicTable(
                        columns: [
                          'Name',
                          'Description',
                          'Start Date',
                          'End Date',
                          'Action',
                        ],
                        rows:rewards.map((reward) {
                          final startDate = (reward['start_date'] as Timestamp).toDate();
                          final endDate = (reward['end_date'] as Timestamp).toDate();
                          final formattedStartDate = DateFormat('d MMM yyyy').format(startDate);
                          final formattedEndDate = DateFormat('d MMM yyyy').format(endDate);

                          return [
                            reward['reward_name'],
                            reward['description'],
                            formattedStartDate,
                            formattedEndDate,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    editRewardDialog(context, reward['id'],reward);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow[800],
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5), 
                                    ),
                                  ),
                                  child: Text("Edit"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _showDeleteConfirmation(context, reward['id']!, reward['reward_name']!);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5), 
                                    ),
                                  ),
                                  child: Text("Delete"),
                                ),
                              ],
                            )
                          ];
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return ExpansionTile(
      title: const Text(
        'Search & Filter',
        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.redAccent),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: const Color.fromARGB(33, 158, 158, 158),
      collapsedBackgroundColor: const Color(0xFFF5F5F5),
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: rewardNameController,
                      keyboardType: TextInputType.text,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
                      decoration: InputDecoration(
                        labelText: "Reward Name",
                        prefixIcon: Icon(Icons.card_giftcard),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        labelStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: startDateController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          String formattedDate = DateFormat('d-M-yyyy').format(pickedDate);
                          setState(() {
                            startDateController.text = formattedDate;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Start Date",
                        prefixIcon: Icon(Icons.calendar_today),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        labelStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton.icon(
                      onPressed: resetFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        "Reset",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton.icon(
                      onPressed: searchReward,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text(
                        "Search",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              controller.text = DateFormat('d-M-yyyy').format(pickedDate);
            }
          },
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
