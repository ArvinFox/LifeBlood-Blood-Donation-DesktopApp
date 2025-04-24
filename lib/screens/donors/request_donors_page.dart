import 'package:flutter/material.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:blood_donation_app/models/donor_request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestDonorsPage extends StatefulWidget {
  const RequestDonorsPage({super.key});

  @override
  State<RequestDonorsPage> createState() => _RequestDonorsPageState();
}

class _RequestDonorsPageState extends State<RequestDonorsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController requestedByController = TextEditingController();

  String? selectedBloodType;
  String? selectedUrgency;
  String? selectedQuantity;
  String? selectedProvince;
  String? selectedCity;
  String? selectedHospital;

  final List<String> bloodTypes = [
    'A+',
    'B+',
    'O+',
    'AB+',
    'A-',
    'B-',
    'O-',
    'AB-',
  ];
  final List<String> urgencyLevels = ['Low', 'Medium', 'High'];
  final List<String> bloodquantity = ['1 Pint', '2 Pints', '3 Pints'];

  final Map<String, List<String>> provinceCities = {
    'Western': ['Colombo', 'Gampaha', 'Kalutara'],
    'Central': ['Kandy', 'Matale', 'Nuwara Eliya'],
    'Southern': ['Galle', 'Matara', 'Hambantota'],
    'Northern': ['Jaffna', 'Kilinochchi', 'Mannar'],
    'Eastern': ['Trincomalee', 'Batticaloa', 'Ampara'],
    'North Western': ['Kurunegala', 'Puttalam'],
    'North Central': ['Anuradhapura', 'Polonnaruwa'],
    'Uva': ['Badulla', 'Monaragala'],
    'Sabaragamuwa': ['Ratnapura', 'Kegalle'],
  };

  final Map<String, List<String>> cityHospitals = {
    'Colombo': [
      'Jayawardenapura Genral Hospital',
      'Castle Ladies Hospital',
      'National Hospital Colombo',
      'Asiri Surgical',
      'Lanka Hospitals',
      'Nawaloka Hospital',
    ],
    'Gampaha': ['Gampaha General Hospital', 'Nawaloka Negombo'],
    'Kalutara': ['Kalutara General Hospital', 'Nagoda Hospital', 'Horana General Hospital'],
    'Kandy': ['Kandy General Hospital', 'Suwasevana Hospital'],
    'Matale': ['Matale District Hospital'],
    'Nuwara Eliya': ['Nuwara Eliya Base Hospital'],
    'Galle': ['Karapitiya Teaching Hospital', 'Mahamodara Hospital'],
    'Matara': ['Matara General Hospital'],
    'Hambantota': ['Hambantota District General Hospital'],
    'Jaffna': ['Jaffna Teaching Hospital'],
    'Kilinochchi': ['Kilinochchi District Hospital'],
    'Mannar': ['Mannar District Hospital'],
    'Trincomalee': ['Trincomalee General Hospital'],
    'Batticaloa': ['Batticaloa Teaching Hospital'],
    'Ampara': ['Ampara General Hospital'],
    'Kurunegala': ['Kurunegala Teaching Hospital'],
    'Puttalam': ['Puttalam District Hospital'],
    'Anuradhapura': ['Anuradhapura Teaching Hospital'],
    'Polonnaruwa': ['Polonnaruwa General Hospital'],
    'Badulla': ['Badulla General Hospital'],
    'Monaragala': ['Monaragala District Hospital'],
    'Ratnapura': ['Ratnapura General Hospital'],
    'Kegalle': ['Kegalle General Hospital'],
  };

  @override
  void dispose() {
    patientNameController.dispose();
    requestedByController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        selectedUrgency != null &&
        selectedQuantity != null &&
        selectedProvince != null &&
        selectedCity != null &&
        selectedHospital != null &&
        selectedBloodType != null) {
      _showConfirmationDialog();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Please Confirm Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: 500.0,
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  columnWidths: const {
                    0: FixedColumnWidth(150),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    buildTableRow("Patient Name", patientNameController.text),
                    buildTableRow("Requested By", requestedByController.text),
                    buildTableRow("Blood Type", selectedBloodType!),
                    buildTableRow("Urgency Level", selectedUrgency!),
                    buildTableRow("Quantity", selectedQuantity!),
                    buildTableRow("Province", selectedProvince!),
                    buildTableRow("City", selectedCity!),
                    buildTableRow("Hospital", selectedHospital!),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Create a BloodRequest object
                  BloodRequest request = BloodRequest(
                    patientName: patientNameController.text,
                    requestedBy: requestedByController.text,
                    requestBloodType: selectedBloodType!,
                    urgencyLevel: selectedUrgency!,
                    requestQuantity: selectedQuantity!,
                    province: selectedProvince!,
                    city: selectedCity!,
                    hospitalName: selectedHospital!,
                    createdAt: Timestamp.fromDate(DateTime.now()),
                  );

                  // Save the request to Firestore
                  try {
                    await request.saveRequest();
                    print("Request saved successfully!");

                    // Reset the form to its original state
                    _resetForm();

                    // Dismiss the dialog after data is saved
                    Navigator.pop(context);

                    // Show the snackbar after the data is saved successfully
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Request submitted!")),
                    );
                  } catch (e) {
                    print("Error saving request: $e");
                    // Optionally, show an error snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to submit request")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text("Submit"),
              ),
            ],
          ),
    );
  }

  void _resetForm() {
    patientNameController.clear();
    requestedByController.clear();
    setState(() {
      selectedBloodType = null;
      selectedUrgency = null;
      selectedQuantity = null;
      selectedProvince = null;
      selectedCity = null;
      selectedHospital = null;
    });
  }

  Widget _inputBox(Widget child) => SizedBox(width: 320, child: child);

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            if (RegExp(r'\d').hasMatch(value)) return 'Cannot contain numbers';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: value,
          style: const TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items:
              items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Required' : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  const Text(
                    "Request Donors",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 40,
                    runSpacing: 32,
                    children: [
                      _inputBox(
                        _buildTextField(
                          label: "Patient Name",
                          controller: patientNameController,
                        ),
                      ),
                      _inputBox(
                        _buildDropdown(
                          label: "Urgency Level",
                          items: urgencyLevels,
                          value: selectedUrgency,
                          onChanged:
                              (val) => setState(() => selectedUrgency = val),
                        ),
                      ),
                      _inputBox(
                        _buildDropdown(
                          label: "Required Quantity",
                          items: bloodquantity,
                          value: selectedQuantity,
                          onChanged:
                              (val) => setState(() => selectedQuantity = val),
                        ),
                      ),
                      _inputBox(
                        _buildTextField(
                          label: "Requested By",
                          controller: requestedByController,
                        ),
                      ),
                      _inputBox(
                        _buildDropdown(
                          label: "Province",
                          items: provinceCities.keys.toList(),
                          value: selectedProvince,
                          onChanged: (val) {
                            setState(() {
                              selectedProvince = val;
                              selectedCity = null;
                              selectedHospital = null;
                            });
                          },
                        ),
                      ),
                      if (selectedProvince != null)
                        _inputBox(
                          _buildDropdown(
                            label: "City",
                            items: provinceCities[selectedProvince]!,
                            value: selectedCity,
                            onChanged: (val) {
                              setState(() {
                                selectedCity = val;
                                selectedHospital = null;
                              });
                            },
                          ),
                        ),
                      if (selectedCity != null)
                        _inputBox(
                          _buildDropdown(
                            label: "Hospital",
                            items: cityHospitals[selectedCity]!,
                            value: selectedHospital,
                            onChanged:
                                (val) => setState(() => selectedHospital = val),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Blood Type",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children:
                        bloodTypes.map((type) {
                          final selected = selectedBloodType == type;
                          return GestureDetector(
                            onTap:
                                () => setState(() => selectedBloodType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    selected ? Colors.redAccent : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? Colors.red : Colors.grey,
                                  width: 2,
                                ),
                                boxShadow:
                                    selected
                                        ? [
                                          BoxShadow(
                                            color: Colors.redAccent.withOpacity(
                                              0.6,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                        : [],
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: selected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 18,
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
