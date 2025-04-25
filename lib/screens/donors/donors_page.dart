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
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final nameMatch = nameController.text.isEmpty || data['fullName']?.toString().toLowerCase().contains(nameController.text.toLowerCase()) == true;
        final contactMatch =  contactController.text.isEmpty || data['contactNumber']?.toString().toLowerCase().contains(contactController.text.toLowerCase()) == true;
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
                'created_at':
                    data['created_at'] != null &&
                            data['created_at'] is Timestamp
                        ? DateFormat(
                          'yyyy-MM-dd',
                        ).format((data['created_at'] as Timestamp).toDate())
                        : '',
              };
            }).toList();
      });
    } catch (e) {
      print('Error filtering donors: $e');
    }
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
      'created_at': 'Registered At',
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Donor Details",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: donor.entries.map((entry) {
                  final label = fieldLabels[entry.key] ?? entry.key;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      controller: TextEditingController(text: entry.value),
                      decoration: InputDecoration(
                        labelText: label,
                        border: const OutlineInputBorder(),
                        labelStyle: TextStyle(
                          fontSize: 16,
                        ), // Font size for dialog field labels
                      ),
                      readOnly: true,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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
                      ExpansionTile(
                        title: const Text(
                          'Search & Filter',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.redAccent,
                          ),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color.fromARGB(33,158,158,158),
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
                                      child: _buildRoundedTextField(
                                        controller: nameController,
                                        label: "Name",
                                        icon: Icons.person,
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[a-zA-Z ]'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 350,
                                      child: _buildRoundedTextField(
                                        controller: contactController,
                                        label: "Contact Number",
                                        icon: Icons.phone,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 350,
                                      child: _buildRoundedTextField(
                                        controller: addressController,
                                        label: "Address",
                                        icon: Icons.home,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 350,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedBloodType,
                                        decoration: InputDecoration(
                                          labelText: "Blood Type",
                                          prefixIcon: const Icon(Icons.bloodtype),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16,vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          labelStyle: TextStyle(fontSize: 16), // Font size for label
                                        ),
                                        items:
                                          bloodTypes.map((type) {
                                            return DropdownMenuItem(
                                              value: type,
                                              child: Text(
                                                type,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
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
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
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
                                        onPressed: searchDonors,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
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
                      ),
                      const SizedBox(height: 20),
                      // Display message if no donors
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
}
