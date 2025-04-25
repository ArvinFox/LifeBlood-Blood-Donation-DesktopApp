import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Uint8List> downloadFile(String filePath) async {
    try {
      return await _supabase.storage
          .from('medical-reports')
          .download(filePath);
    } on StorageException catch (e) {
      throw Exception('Download error: ${e.message}');
    }
  }

  String getPublicUrl(String filePath) {
    return _supabase.storage
        .from('medical-reports')
        .getPublicUrl(filePath);
  }
}