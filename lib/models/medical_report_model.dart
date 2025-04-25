import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalReport {
  final String? id;
  final String donorName;
  final String reportType;
  final String status;
  final DateTime date;
  final String filePath;

  MedicalReport({
    this.id,
    required this.donorName,
    required this.reportType,
    required this.status,
    required this.date,
    required this.filePath,
  });

  factory MedicalReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicalReport(
      id: doc.id,
      donorName: data['donorName'] ?? '',
      reportType: data['reportType'] ?? '',
      status: data['status'] ?? 'Pending',
      date: (data['date'] as Timestamp).toDate(),
      filePath: data['filePath'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'donorName': donorName,
      'reportType': reportType,
      'status': status,
      'date': Timestamp.fromDate(date),
      'filePath': filePath,
    };
  }
}