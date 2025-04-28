import 'package:blood_donation_app/components/delete_confirmation_popup.dart';
import 'package:blood_donation_app/components/manage_data_form.dart';
import 'package:blood_donation_app/components/search_and_filter.dart';
import 'package:blood_donation_app/components/table.dart';
import 'package:blood_donation_app/models/reward_model.dart';
import 'package:blood_donation_app/services/reward_service.dart';
import 'package:blood_donation_app/services/supabase_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Rewardscreen extends StatefulWidget {
  const Rewardscreen({super.key});

  @override
  State<Rewardscreen> createState() => _RewardscreenState();
}

class _RewardscreenState extends State<Rewardscreen> {
  final rewardService = RewardService();
  final _supabaseService = SupabaseService();
  final TextEditingController rewardNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();

  List<Reward> rewards = [];

  @override
  void initState() {
    super.initState();
    fetchRewards();
  }

  @override
  void dispose() {
    rewardNameController.dispose();
    startDateController.dispose();
    super.dispose();
  }

  Future<void> fetchRewards({bool applyFilters = false}) async {
    try {
      final snapshots = await FirebaseFirestore.instance.collection('rewards').get();

      final inputDate = startDateController.text.isNotEmpty
        ? DateFormat('d-M-yyyy').parse(startDateController.text)
        : null;
    
      final filtered = snapshots.docs.where((item) {
        final rewardName = item['reward_name']?.toString().toLowerCase() ?? '';
        final startDateTimestamp = item['start_date'] as Timestamp?;

        final nameMatch = rewardNameController.text.isEmpty || rewardName.contains(rewardNameController.text.trim().toLowerCase());

        final dateMatch = inputDate == null || (
          startDateTimestamp != null &&
          startDateTimestamp.toDate().year == inputDate.year &&
          startDateTimestamp.toDate().month == inputDate.month &&
          startDateTimestamp.toDate().day == inputDate.day
        );

        return nameMatch && dateMatch;
      }).toList();

      setState(() {
        rewards = filtered.map((doc) => Reward.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error fetching rewards: $e');
      Helpers.showError(context, 'Failed to load rewards');
    }
  }

  void searchReward() {
    fetchRewards();
  }

  void resetFilters() {
    rewardNameController.clear();
    startDateController.clear();
    fetchRewards();
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
                      builder:(_) => ManageDataForm(
                        formType: FormType.rewards,
                        onSubmit: (data, isEdit) async {
                          await rewardService.manageReward(
                            context, 
                            data, 
                            onRewardManaged: fetchRewards,
                          );
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
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildSearchAndFilter(),
                    const SizedBox(height: 20),

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
                          final formattedStartDate = DateFormat('d MMM yyyy').format(reward.startDate);
                          final formattedEndDate = DateFormat('d MMM yyyy').format(reward.endDate);

                          return [
                            reward.rewardName,
                            reward.description,
                            formattedStartDate,
                            formattedEndDate,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:(_) => ManageDataForm(
                                        isEditMode: true,
                                        id: reward.rewardId,
                                        formType: FormType.rewards,
                                        onSubmit: (data, isEdit) async {
                                          await rewardService.manageReward(
                                            context, 
                                            data,  
                                            isEdit: true, 
                                            rewardId: reward.rewardId,
                                            onRewardManaged: fetchRewards,
                                          );
                                        },
                                      ),
                                    );
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
                                    showDialog(
                                      context: context,
                                      builder: (context) => DeleteConfirmationPopup(
                                        itemType: "reward",
                                        itemName: reward.rewardName,
                                        onDeleteConfirmed: () async {
                                          await _supabaseService.deleteImage('reward', reward.rewardId!);
                                          await rewardService.deleteReward(context, reward.rewardId!);
                                          Helpers.showSucess(context, 'Reward deleted successfully');
                                          fetchRewards();
                                        },
                                      ),
                                    );
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
    return SearchAndFilter(
      title: "Search & Filter",
      searchFields: [
        buildRoundedTextField(
          controller: rewardNameController,
          label: "Reward Name",
          icon: Icons.card_giftcard,
          keyboardType: TextInputType.text,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
        ),
        buildRoundedTextField(
          controller: startDateController,
          label: "Start Date",
          icon: Icons.calendar_today,
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
        ),
      ],
      onSearch: searchReward,
      onReset: resetFilters,
    );
  }
}
