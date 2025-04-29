import 'package:blood_donation_app/components/search_and_filter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_donation_app/components/table.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DonorsPage extends StatefulWidget {
  const DonorsPage({super.key});

  @override
  State<DonorsPage> createState() => _DonorsPageState();
}

class _DonorsPageState extends State<DonorsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? selectedBloodType;

  final List<String> bloodTypes = ['A+','A-','B+','B-','AB+','AB-','O+','O-'];
  List<Map<String, String>> donors = [];

  @override
  void initState() {
    super.initState();
    fetchDonors();
  }

  Future<void> fetchDonors({bool applyFilters = false}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('user');

      if (applyFilters) {
        if (selectedBloodType != null && selectedBloodType!.isNotEmpty) {
          query = query.where('bloodType', isEqualTo: selectedBloodType);
        }
      }

      final snapshot = await query.get();
      final searchContact = contactController.text.trim();
      final normalizedSearchContact = normalizePhoneNumber(searchContact);

      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final nameMatch = nameController.text.isEmpty || data['fullName']?.toString().toLowerCase().contains(nameController.text.toLowerCase()) == true;

        final contact = data['contactNumber']?.toString() ?? '';
        final normalizedContact = normalizePhoneNumber(contact);
        final contactMatch = contactController.text.isEmpty ||
            normalizedContact.contains(normalizedSearchContact) ||
            contact.contains(searchContact);

        final addressMatch = addressController.text.isEmpty || data['address']?.toString().toLowerCase().contains(addressController.text.toLowerCase()) == true;
        
        return nameMatch && contactMatch && addressMatch;
      }).toList();

      setState(() {
        donors =
            filteredDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'fullName': (data['fullName'] ?? '').toString(),
                'bloodType': (data['bloodType'] ?? '').toString(),
                'contactNumber': (data['contactNumber'] ?? '').toString(),
                'address': (data['address'] ?? '').toString(),
                'city': (data['city'] ?? '').toString(),
                'province': (data['province'] ?? '').toString(),
                'email': (data['email'] ?? '').toString(),
                'dob':
                    data['dob'] != null && data['dob'] is Timestamp
                        ? DateFormat(
                          'yyyy-MM-dd',
                        ).format((data['dob'] as Timestamp).toDate())
                        : '',
                'nic': (data['nic'] ?? '').toString(),
                'gender': (data['gender'] ?? '').toString(),
                'healthConditions': (data['healthConditions'] ?? '').toString(),
                'createdAt':
                    data['createdAt'] != null &&
                            data['createdAt'] is Timestamp
                        ? DateFormat(
                          'yyyy-MM-dd',
                        ).format((data['createdAt'] as Timestamp).toDate())
                        : '',
              };
            }).toList();
      });
    } catch (e) {
      print('Error filtering donors: $e');
    }
  }

  String normalizePhoneNumber(String input) {
    input = input.replaceAll(RegExp(r'\s+|-'), '');
    if (input.startsWith('0')) {
      return input.replaceFirst('0', '+94');
    }
    return input;
  }

  void searchDonors() {
    fetchDonors(applyFilters: true);
  }

  void resetFilters() {
    nameController.clear();
    contactController.clear();
    addressController.clear();
    setState(() {
      selectedBloodType = null;
    });
    fetchDonors();
  }

  void showDonorPopup(Map<String, String> donor) {
    final fieldLabels = {
      'fullName': 'Full Name',
      'bloodType': 'Blood Type',
      'contactNumber': 'Contact Number',
      'address': 'Address',
      'city': 'City',
      'province': 'Province',
      'email': 'Email',
      'dob': 'Date of Birth',
      'nic': 'NIC',
      'gender': 'Gender',
      'healthConditions': 'Health Conditions',
      'createdAt': 'Registered At',
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 247, 247),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 16,
          content: Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.redAccent, width: 1),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Donor Details",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: donor.entries.map((entry) {
                      final label = fieldLabels[entry.key] ?? entry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      entry.value.isNotEmpty ? entry.value : "-",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: entry.value));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('$label copied to clipboard!'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    tooltip: 'Copy',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Donors',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSearchAndFilter(),
                      const SizedBox(height: 20),

                      if (donors.isEmpty)
                        Center(
                          child: Text(
                            'No donors available.',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        )
                      else
                        DynamicTable(
                          columns: [
                            'Name',
                            'Blood Type',
                            'Contact',
                            'Address',
                            'Action',
                          ],
                          rows:
                            donors.map((donor) {
                              return [
                                donor['fullName'],
                                donor['bloodType'],
                                donor['contactNumber'],
                                donor['address'],
                                Center(
                                  child: SizedBox(
                                    width: 100,
                                    child: ElevatedButton(
                                      onPressed: () => showDonorPopup(donor),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFAE42),
                                        foregroundColor: Colors.white,
                                        textStyle: const TextStyle(fontSize: 16),
                                      ),
                                      child: const Text("Details"),
                                    ),
                                  ),
                                ),
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
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return SearchAndFilter(
      title: "Search & Filter",
      searchFields: [
        buildRoundedTextField(
          controller: nameController,
          label: "Name",
          icon: Icons.person,
          keyboardType: TextInputType.text,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
        ),
        buildRoundedTextField(
          controller: contactController,
          label: "Contact Number",
          icon: Icons.phone,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        buildRoundedTextField(
          controller: addressController,
          label: "Address",
          icon: Icons.home,
        ),
        SizedBox(
          width: 350,
          child: DropdownButtonFormField<String>(
            value: selectedBloodType,
            decoration: InputDecoration(
              labelText: "Blood Type",
              prefixIcon: Icon(Icons.bloodtype),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelStyle: TextStyle(fontSize: 16),
            ),
            items: bloodTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type, style: const TextStyle(fontSize: 16)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedBloodType = value;
              });
            },
          ),
        ),
      ],
      onSearch: searchDonors,
      onReset: resetFilters,
    );
  }
}
