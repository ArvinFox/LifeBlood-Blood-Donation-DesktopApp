import 'package:flutter/material.dart';
import 'package:blood_donation_app/components/table.dart';

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

  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<Map<String, String>> donors = [
    {
      'id': '1',
      'name': 'John Doe',
      'bloodType': 'A+',
      'contact': '0771234567',
      'address': '123 Main Street, Colombo',
      'city': 'Colombo',
      'province': 'Western',
      'email': 'john@example.com',
      'dob': '1990-01-01',
      'nic': '901234567V',
      'gender': 'Male',
      'health': 'Healthy',
      'report': 'None',
      'registeredDate': '2024-05-10',
    },
    {
      'id': '2',
      'name': 'Alice Smith',
      'bloodType': 'B-',
      'contact': '0787654321',
      'address': '456 Beach Road, Galle',
      'city': 'Galle',
      'province': 'Southern',
      'email': 'alice@example.com',
      'dob': '1987-11-15',
      'nic': '871234567V',
      'gender': 'Female',
      'health': 'Minor allergies',
      'report': 'Allergy noted',
      'registeredDate': '2023-10-20',
    },
  ];

  void resetFilters() {
    nameController.clear();
    contactController.clear();
    addressController.clear();
    setState(() {
      selectedBloodType = null;
    });
  }

  void searchDonors() {
    print('Searching with filters...');
  }

  void showDonorPopup(Map<String, String> donor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Donor Details"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: SingleChildScrollView(
              child: Column(
                children:
                    donor.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: entry.key,
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          controller: TextEditingController(text: entry.value),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ExpansionTile(
                        title: const Text(
                          'Filter Options',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: "Name",
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: contactController,
                                  decoration: const InputDecoration(
                                    labelText: "Contact No",
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: addressController,
                                  decoration: const InputDecoration(
                                    labelText: "Address",
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: selectedBloodType,
                                  decoration: const InputDecoration(
                                    labelText: "Blood Type",
                                  ),
                                  items:
                                      bloodTypes.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBloodType = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: resetFilters,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orangeAccent,
                                        ),
                                        child: const Text("Reset Filters"),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: searchDonors,
                                        child: const Text("Search"),
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
                      DynamicTable(
                        columns: [
                          'ID',
                          'Name',
                          'Blood Type',
                          'Contact',
                          'Address',
                          'Action',
                        ],
                        rows:
                            donors.map((donor) {
                              return [
                                donor['id'],
                                donor['name'],
                                donor['bloodType'],
                                donor['contact'],
                                donor['address'],
                                Center(
                                  child: SizedBox(
                                    width: 100,
                                    child: ElevatedButton(
                                      onPressed: () => showDonorPopup(donor),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFFFAE42,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("View"),
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
