import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_donation_app/models/medical_report_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicalReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

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

    bool isDonorVerified = newStatus == 'Approved';
    await _firestore
      .collection('user')
      .doc(reportId)
      .update({'isDonorVerified': isDonorVerified});
  }

  Future<Uint8List> downloadFile(String filePath) async {
    try {
      return await _supabase.storage
        .from('medical-reports')
        .download(filePath);
    } on StorageException catch (e) {
      throw Exception('Download error: ${e.message}');
    }
  }
}