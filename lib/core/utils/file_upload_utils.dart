import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vsc_app/core/utils/app_logger.dart';

/// Utility class for handling file upload operations across the app
class FileUploadUtils {
  /// Create MultipartFile from XFile with platform-specific handling
  /// This method handles the differences between web and mobile platforms
  static Future<MultipartFile> createMultipartFileFromXFile(XFile imageFile) async {
    try {
      if (kIsWeb) {
        // For web, read the file as bytes
        final bytes = await imageFile.readAsBytes();
        return MultipartFile.fromBytes(bytes, filename: imageFile.name);
      } else {
        // For mobile, use the file path
        return MultipartFile.fromFile(imageFile.path, filename: imageFile.name);
      }
    } catch (e) {
      AppLogger.error('FileUploadUtils: Error creating MultipartFile from XFile: $e');
      rethrow;
    }
  }
}
