import 'dart:convert';
import 'dart:typed_data';

import 'package:blood_donation_app/utils/helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Fetch image
  Future<String?> fetchImage(String bucketName, String filePath) async {
    try {
      final Uint8List bytes = await Supabase.instance.client.storage
        .from(bucketName)
        .download(filePath);

      if (bytes.isNotEmpty) {
        return base64Encode(bytes);
      }
    } catch (e) {
      Helpers.debugPrintWithBorder('Error fetching image: $e');
    }
    return null;
  }

  // Upload image
  Future<String> uploadImage(String type, String base64Image, String id) async {
    await deleteImage(type, id);   // Delete existing files
    
    final imageBytes = base64Decode(base64Image);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final imageName = '${type}_image_${id}_$timestamp.jpg';
    final imagePath = '$id/$imageName';

    await supabase.storage
        .from('${type}s')
        .uploadBinary(
          imagePath,
          imageBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'), 
        );

    return imageName;
  }

  // Delete image
  Future<void> deleteImage(String type, String id) async {
    try {
      final storage = supabase.storage.from('${type}s');

      final List<FileObject>? existingFiles = await storage.list(path: id);

      if (existingFiles != null) {
        for (final file in existingFiles) {
          if (file.name.startsWith('${type}_image_')) {
            final fullPath = '$id/${file.name}';
            await storage.remove([fullPath]);
            Helpers.debugPrintWithBorder('Deleted image: $fullPath');
          }
        }
      }

    } catch (e) {
      Helpers.debugPrintWithBorder("Error deleting image: $e");
    }
  }
}