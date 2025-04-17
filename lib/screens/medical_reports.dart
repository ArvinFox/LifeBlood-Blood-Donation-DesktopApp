import 'package:flutter/material.dart';
import 'package:blood_donation_app/components/table.dart';

class MedicalReportsPage extends StatelessWidget {
  const MedicalReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical Reports',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DynamicTable(
            columns: [
              'ID',
              'User Name',
              'Medical Report',
              'View Report',
              'Approve / Reject',
            ],
            rows: [
              [
                '1',
                'John Doe',
                'Blood Test',
                Center(
                  child: SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 46, 126, 216),
                        foregroundColor: Color.fromARGB(255, 255, 255, 255),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), 
                        ),
                      ),
                      child: Text("View"),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), 
                        ),
                      ),
                      child: Text("Approve"),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), 
                        ),
                      ),
                      child: Text("Reject"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}