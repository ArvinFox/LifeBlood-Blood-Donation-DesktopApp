import 'package:flutter/material.dart';

class RequestDonorsPage extends StatefulWidget {
  const RequestDonorsPage({Key? key}) : super(key: key);

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
  String? selectedTargetDonorAge;

  final List<String> bloodTypes = ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'];
  final List<String> urgencyLevels = ['Low', 'Medium', 'High'];
  final List<String> bloodquantity = ['1 Pint', '2 Pints', '3 Pints'];
  final List<String> donorAges = ['18-25', '26-35', '36-45', '46-60', '60+'];

  @override
  void dispose() {
    patientNameController.dispose();
    requestedByController.dispose();
    super.dispose();
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Request Donors",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    runSpacing: 32,
                    spacing: 40,
                    children: [
                      _inputBox(_buildTextField(label: "Patient Name", controller: patientNameController)),
                      _inputBox(_buildDropdown(
                        label: "Urgency Level",
                        items: urgencyLevels,
                        onChanged: (val) => setState(() => selectedUrgency = val),
                      )),
                      _inputBox(_buildDropdown(
                        label: "Target Donor Age",
                        items: donorAges,
                        onChanged: (val) => setState(() => selectedTargetDonorAge = val),
                      )),
                      _inputBox(_buildDropdown(
                        label: "Required Quantity",
                        items: bloodquantity,
                        onChanged: (val) => setState(() => selectedQuantity = val),
                      )),
                      _inputBox(_buildTextField(label: "Requested By", controller: requestedByController)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Blood Type",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: bloodTypes.map((type) {
                      final selected = selectedBloodType == type;
                      return GestureDetector(
                        onTap: () => setState(() => selectedBloodType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? Colors.redAccent : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? Colors.red : Colors.grey,
                              width: 2,
                            ),
                            boxShadow: [
                              if (selected)
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.6),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
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
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print("Urgency: $selectedUrgency");
                        print("Blood Type: $selectedBloodType");
                        print("Quantity: $selectedQuantity");
                        print("Target Donor Age: $selectedTargetDonorAge");
                        print("Patient Name: ${patientNameController.text}");
                        print("Requested By: ${requestedByController.text}");
                      }
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _inputBox(Widget child) {
    return SizedBox(width: 320, child: child);
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
