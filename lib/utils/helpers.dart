import 'package:flutter/material.dart';

class Helpers {
  //error message
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ),
    );
  }

  //success message
  static void showSucess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
    );
  }

  static void debugPrintWithBorder(String message) {
    print("========================================");
    print(message);
    print("========================================");
  }

  static DateTime combineDateAndTime(String date, String time) {
    final dateParts = date.split('-');
    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);

    final timeParts = time.trim().split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);
    final period = timeParts[1].toUpperCase();

    // Convert to 24-hour format
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return DateTime(year, month, day, hour, minute);
  }
}

TableRow buildTableRow(String label, String value) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Text(
          value,
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    ],
  );
}
