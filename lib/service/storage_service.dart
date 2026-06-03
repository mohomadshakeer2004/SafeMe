import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage uploads — fails gracefully on Spark plan (HTTP 402).
class StorageService {
  StorageService._();

  static const Duration uploadTimeout = Duration(seconds: 12);

  static const String sparkPlanMessage =
      'Photo upload is unavailable on the free Firebase plan. '
      'Upgrade to Blaze, or your data was saved without the photo.';

  static Future<String?> uploadFile({
    required String storagePath,
    required File file,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      await ref.putFile(file).timeout(uploadTimeout);
      return await ref.getDownloadURL().timeout(const Duration(seconds: 8));
    } on TimeoutException {
      print('Storage upload timed out ($storagePath)');
      return null;
    } catch (e) {
      print('Storage upload failed ($storagePath): $e');
      return null;
    }
  }

  static bool isUnavailableError(Object error) {
    final message = error.toString();
    return message.contains('402') ||
        message.contains('Blaze') ||
        message.contains('Spark') ||
        message.contains('firebase_storage');
  }
}
