
import 'dart:io';
import 'dart:typed_data';
import 'package:saver_gallery/saver_gallery.dart';
import '../data/models/status_media.dart';

class StatusReaderService {
  // Updated paths for Android 11+
  static const String _whatsappStatusPath =
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';
  
  static const String _whatsappBusinessStatusPath =
      '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses';

  // Fallback paths for older Android versions
  static const String _legacyWhatsappPath =
      '/storage/emulated/0/WhatsApp/Media/.Statuses';

  static List<StatusMedia> readStatuses() {
    List<StatusMedia> statuses = [];

    try {
      // Try new path first (Android 11+)
      statuses.addAll(_readFromDirectory(_whatsappStatusPath));
      
      // Try WhatsApp Business
      statuses.addAll(_readFromDirectory(_whatsappBusinessStatusPath));
      
      // Try legacy path if nothing found
      if (statuses.isEmpty) {
        statuses.addAll(_readFromDirectory(_legacyWhatsappPath));
      }
    } catch (e) {
      print('Error reading statuses: $e');
    }

    return statuses;
  }

  static List<StatusMedia> _readFromDirectory(String path) {
    List<StatusMedia> statuses = [];

    try {
      final statusDir = Directory(path);

      if (!statusDir.existsSync()) {
        return statuses;
      }

      final files = statusDir.listSync();

      for (var file in files) {
        if (file is File && !file.path.endsWith('.nomedia')) {
          final extension = file.path.toLowerCase();
          final isVideo = extension.endsWith('.mp4') ||
              extension.endsWith('.mkv') ||
              extension.endsWith('.avi') ||
              extension.endsWith('.3gp');

          statuses.add(StatusMedia(
            images: file.path,
            isVideo: isVideo,
          ));
        }
      }
    } catch (e) {
      print('Error reading from $path: $e');
    }

    return statuses;
  }

  static Future<bool> downloadStatus(StatusMedia media) async {
    try {
      final file = File(media.images);

      if (!await file.exists()) {
        print('File does not exist: ${media.images}');
        return false;
      }

      // Read file as bytes
      final bytes = await file.readAsBytes();

      // Determine file name and extension
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last;

      // Save using saver_gallery
      final result = await SaverGallery.saveImage(
        Uint8List.fromList(bytes),
        quality: 100,
        fileName: fileName,
        androidRelativePath: "Pictures/StatusSaver",
        skipIfExists: false,
      );

      if (result.isSuccess) {
        print('Status saved successfully: ${result.isSuccess}');
        return true;
      } else {
        print('Failed to save status: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      print('Error downloading status: $e');
      return false;
    }
  }

  static Future<bool> downloadVideo(StatusMedia media) async {
    try {
      final file = File(media.images);

      if (!await file.exists()) {
        print('File does not exist: ${media.images}');
        return false;
      }

      final fileName = file.path.split('/').last;

      // For videos, use saveFile method
      final result = await SaverGallery.saveFile(
        filePath: file.path,
        fileName: fileName,
        androidRelativePath: "Movies/StatusSaver",
        skipIfExists: false,
      );

      if (result.isSuccess) {
        print('Video saved successfully: ${result.isSuccess}');
        return true;
      } else {
        print('Failed to save video: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      print('Error downloading video: $e');
      return false;
    }
  }

  static bool isWhatsAppInstalled() {
    final whatsappDir = Directory(_whatsappStatusPath);
    final legacyDir = Directory(_legacyWhatsappPath);
    final businessDir = Directory(_whatsappBusinessStatusPath);

    return whatsappDir.existsSync() || 
           legacyDir.existsSync() || 
           businessDir.existsSync();
  }
}