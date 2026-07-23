import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage uploads — falls back to inline data URLs when Storage fails
/// (common on Spark plan / HTTP 402) so admin can still show evidence photos.
class StorageService {
  StorageService._();

  static const Duration uploadTimeout = Duration(seconds: 45);
  static const int maxInlineBytes = 700000;

  static const String sparkPlanMessage =
      'Photo upload is unavailable on the free Firebase plan. '
      'Upgrade to Blaze, or your data was saved without the photo.';

  static Future<String?> uploadFile({
    required String storagePath,
    required File file,
    String? contentType,
    Duration? timeout,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTimeout = timeout ?? StorageService.uploadTimeout;
      if (contentType != null) {
        await ref
            .putFile(file, SettableMetadata(contentType: contentType))
            .timeout(uploadTimeout);
      } else {
        await ref.putFile(file).timeout(uploadTimeout);
      }
      return await ref.getDownloadURL().timeout(const Duration(seconds: 12));
    } on TimeoutException {
      print('Storage upload timed out ($storagePath)');
      return null;
    } catch (e) {
      print('Storage upload failed ($storagePath): $e');
      return null;
    }
  }

  /// Prefer Storage download URL; if that fails, store a compressed data URL in RTDB.
  static Future<String?> uploadFileOrInline({
    required String storagePath,
    required File file,
    String contentType = 'image/jpeg',
    Duration? timeout,
  }) async {
    final url = await uploadFile(
      storagePath: storagePath,
      file: file,
      contentType: contentType,
      timeout: timeout,
    );
    if (url != null && url.isNotEmpty) {
      return url;
    }

    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return null;
      }
      if (bytes.length > maxInlineBytes) {
        print(
          'Inline image too large (${bytes.length} bytes) for $storagePath — '
          'pick a smaller photo or enable Firebase Storage (Blaze).',
        );
        return null;
      }
      final b64 = base64Encode(bytes);
      final mime = contentType.isNotEmpty ? contentType : 'image/jpeg';
      print('Storage fallback: inline data URL for $storagePath (${bytes.length} bytes)');
      return 'data:$mime;base64,$b64';
    } catch (e) {
      print('Inline image fallback failed ($storagePath): $e');
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
