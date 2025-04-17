import 'package:flutter/material.dart';

class DynamicTable extends StatelessWidget {
  final List<String> columns;
  final List<List<dynamic>> rows; // Change from List<List<String>> to List<List<dynamic>>

  const DynamicTable({
    Key? key,
    required this.columns,
    required this.rows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.black54),
      columnWidths: _getColumnWidths(columns.length),
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0E0),
          ),
          children: columns.map((column) => _tableCell(column, isHeader: true)).toList(),
        ),
        ...rows.map((row) {
          return TableRow(
            children: row.map((cell) {
              // Check if the cell is the "action" column (i.e., the last column)
              if (row.indexOf(cell) == row.length - 1 && cell is String) {
                return _viewButton(); // Add View button in the last column
              } else {
                return _tableCell(cell.toString()); // Normal cell (ensure all content is string)
              }
            }).toList(),
          );
        }).toList(),
      ],
    );
  }

  // Dynamically calculate column widths
  Map<int, TableColumnWidth> _getColumnWidths(int columnCount) {
    return {
      for (int i = 0; i < columnCount; i++) i: FlexColumnWidth(),
    };
  }

  // Widget to create a cell in the table
  static Widget _tableCell(String text, {bool isHeader = false}) {
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

  // Widget for the View Button
  static Widget _viewButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: () {
          // Add action for the button press (e.g., navigate to view details page)
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(60, 30),
        ),
        child: const Text('View'),
      ),
    );
  }
}
