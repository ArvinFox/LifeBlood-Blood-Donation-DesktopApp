import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Upload image (event or reward)
  Future<String> uploadImage(String type, String base64Image, String id) async {
    final imageBytes = base64Decode(base64Image);
    final imageName = '${type}_image_$id.jpg';
    final imagePath = '$id/$imageName';

    await supabase.storage
        .from('${type}s')
        .uploadBinary(
          imagePath,
          imageBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'), 
        );

    final publicUrl = supabase.storage
        .from('${type}s')
        .getPublicUrl(imagePath);

    return publicUrl;
  }
}