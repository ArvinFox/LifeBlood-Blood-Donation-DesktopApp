import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_donation_app/models/medical_report_model.dart';

class MedicalReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MedicalReport>> getReports() {
    return _firestore
        .collection('medical_reports')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalReport.fromFirestore(doc))
            .toList());
  }

  Future<void> updateReportStatus(String reportId, String newStatus) async {
    await _firestore
        .collection('medical_reports')
        .doc(reportId)
        .update({'status': newStatus});
  }
}