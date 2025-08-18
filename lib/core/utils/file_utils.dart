import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vsc_app/core/utils/app_logger.dart';

/// Utility class for file operations
class FileUtils {
  /// Get the file extension from a file path
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Get the file name from a file path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Get the file name without extension from a file path
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Get the directory path from a file path
  static String getDirectoryPath(String filePath) {
    return path.dirname(filePath);
  }

  /// Check if a file exists
  static Future<bool> fileExists(String filePath) async {
    if (kIsWeb) return false;

    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      AppLogger.error('Error checking if file exists', error: e);
      return false;
    }
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    if (kIsWeb) return 0;

    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      AppLogger.error('Error getting file size', error: e);
      return 0;
    }
  }

  /// Format file size to human-readable format
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  /// Get MIME type from file extension
  static String getMimeType(String filePath) {
    final extension = getFileExtension(filePath).toLowerCase().replaceFirst('.', '');

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      case 'json':
        return 'application/json';
      default:
        return 'application/octet-stream';
    }
  }

  /// Convert XFile to Uint8List
  static Future<Uint8List?> xFileToUint8List(XFile? file) async {
    if (file == null) return null;

    try {
      return await file.readAsBytes();
    } catch (e) {
      AppLogger.error('Error converting XFile to Uint8List', error: e);
      return null;
    }
  }

  /// Check if a file is an image based on its extension
  static bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  /// Check if a file is a document based on its extension
  static bool isDocumentFile(String filePath) {
    final extension = getFileExtension(filePath).toLowerCase();
    return ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt'].contains(extension);
  }
}
