import 'package:flutter/material.dart';

class DonorsPage extends StatelessWidget {
  const DonorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Banner
          Container(
            height: 80,
            color: Colors.red[700],
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/blood_logo.jpg',
                      height: 40, // adjust size as needed
                    ),
                  ],
                ),

                Row(
                  children: const [
                    Icon(Icons.notifications_none, color: Colors.white),
                    SizedBox(width: 20),
                    Icon(Icons.power_settings_new, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),

          // Main Content with Sidebar and Table
          Expanded(
            child: Row(
              children: [
                // Sidebar
                Container(
                  width: 220,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      navItem(Icons.dashboard, 'Dashboard'),
                      navItem(Icons.search, 'Request Donors'),
                      navItem(Icons.person, 'Donors', isSelected: true),
                      navItem(Icons.description, 'Medical Reports'),
                      navItem(Icons.event, 'Events'),
                      navItem(Icons.card_giftcard, 'Rewards'),
                    ],
                  ),
                ),

                // Black line separator
                Container(
                  width: 1, // Width of the line
                  color: Colors.black, // Black color for the line
                ),

                // Donors Table
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Donors',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Table(
                          border: TableBorder.all(color: Colors.black54),
                          columnWidths: const {
                            0: FixedColumnWidth(50),
                            1: FlexColumnWidth(),
                            2: FixedColumnWidth(100),
                            3: FixedColumnWidth(150),
                            4: FlexColumnWidth(),
                            5: FixedColumnWidth(80),
                          },
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color(0xFFE0E0E0),
                              ),
                              children: [
                                tableCell('ID', isHeader: true),
                                tableCell('Name', isHeader: true),
                                tableCell('Blood Type', isHeader: true),
                                tableCell('Contact Number', isHeader: true),
                                tableCell('Address', isHeader: true),
                                tableCell('', isHeader: true),
                              ],
                            ),
                            TableRow(
                              children: [
                                tableCell(''),
                                tableCell(''),
                                tableCell(''),
                                tableCell(''),
                                tableCell(''),
                                Padding(
                                  padding: const EdgeInsets.all(
                                    8.0,
                                  ), // Added padding here
                                  child: Center(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(60, 30),
                                      ),
                                      onPressed: () {},
                                      child: const Text('View'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget navItem(
    IconData icon,
    String label, {
    bool isSelected = false,
  }) {
    return Container(
      color: isSelected ? Colors.grey[200] : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.red[700] : Colors.black87,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.red[700] : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  static Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}