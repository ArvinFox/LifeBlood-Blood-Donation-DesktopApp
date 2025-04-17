import 'package:flutter/material.dart';
import 'package:blood_donation_app/components/table.dart';

class DonorsPage extends StatelessWidget {
  const DonorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donors',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Using DynamicTable to display donor data
          DynamicTable(
            columns: ['ID', 'Name', 'Blood Type', 'Contact', 'Address', 'Action'],
            rows: [
              ['1', 'John Doe', 'A+', '0771234567', 'Colombo', ''], // Empty for now, will handle button in the table
              ['2', 'Alice Smith', 'B-', '0787654321', 'Galle', ''],
            ],
          ),
        ],
      ),
    );
  }
}
