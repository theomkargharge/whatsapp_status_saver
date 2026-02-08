// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../data/models/status_media.dart';

// /// Play Store COMPLIANT Status Reader using SAF (Storage Access Framework)
// ///
// /// This is the ONLY way to build a WhatsApp Status Saver that will be
// /// approved by Google Play Store for Android 11+
// ///
// /// How it works:
// /// 1. User clicks "Select WhatsApp Status Folder"
// /// 2. Android file picker opens
// /// 3. User navigates to: Android/media/com.whatsapp/WhatsApp/Media/.Statuses
// /// 4. User selects the .Statuses folder
// /// 5. App gets persistent permission to read that folder
// /// 6. App can now access statuses without any special permissions
// class StatusReaderService {
//   static const platform = MethodChannel('com.example.statussaver/storage');
//   static const String _uriKey = 'status_folder_uri';

//   /// Opens Android's directory picker for user to select .Statuses folder
//   /// Returns true if user selected a folder
//   static Future<bool> requestFolderAccess() async {
//     try {
//       final String? uri = await platform.invokeMethod('openDirectoryPicker');

//       if (uri != null) {
//         // Save the URI for future use
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(_uriKey, uri);
//         print('Status folder URI saved: $uri');
//         return true;
//       }

//       return false;
//     } catch (e) {
//       print('Error requesting folder access: $e');
//       return false;
//     }
//   }

//   /// Check if we have permission to access status folder
//   static Future<bool> hasPermission() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final uri = prefs.getString(_uriKey);

//       if (uri == null) return false;

//       final bool hasPermission = await platform.invokeMethod(
//         'checkUriPermission',
//         {'uri': uri},
//       );

//       return hasPermission;
//     } catch (e) {
//       print('Error checking permission: $e');
//       return false;
//     }
//   }

//   /// Read statuses from the selected folder
//   static Future<List<StatusMedia>> readStatuses() async {
//     List<StatusMedia> statuses = [];

//     print('========== READING STATUSES (SAF) ==========');

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final uri = prefs.getString(_uriKey);

//       if (uri == null) {
//         print('No folder selected. User needs to grant access first.');
//         return statuses;
//       }

//       // Get files from the URI using native Android code
//       final List<dynamic> files = await platform.invokeMethod(
//         'getStatusFiles',
//         {'uri': uri},
//       );

//       for (var file in files) {
//         final fileMap = Map<String, dynamic>.from(file);

//         statuses.add(StatusMedia(
//           images: fileMap['uri'] as String, // Store URI instead of path
//           isVideo: fileMap['isVideo'] as bool,
//           name: fileMap['name'] as String?,
//           size: fileMap['size'] as int?,
//           lastModified: fileMap['lastModified'] as int?,
//         ));
//       }

//       print('TOTAL STATUSES FOUND: ${statuses.length}');
//     } catch (e) {
//       print('ERROR reading statuses: $e');
//     }

//     print('======================================');
//     return statuses;
//   }

//   /// Download status to gallery
//   static Future<bool> downloadStatus(StatusMedia media) async {
//     try {
//       // For SAF-based approach, you'll need to:
//       // 1. Read bytes from the content URI
//       // 2. Save to public directory using saver_gallery

//       // This requires additional native code to read from content URI
//       // For now, returning false to indicate not implemented

//       print('Download functionality requires additional implementation');
//       return false;
//     } catch (e) {
//       print('Error downloading status: $e');
//       return false;
//     }
//   }

//   /// Clear saved folder permission
//   static Future<void> clearPermission() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_uriKey);
//   }

//   /// Check if WhatsApp is installed
//   static Future<bool> isWhatsAppInstalled() async {
//     // This is just a helper - actual access requires user selection
//     final paths = [
//       '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
//       '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
//     ];

//     for (final path in paths) {
//       final dir = Directory(path);
//       if (await dir.exists()) {
//         return true;
//       }
//     }

//     return false;
//   }
// }

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'dart:typed_data';
import '../data/models/status_media.dart';

/// Play Store COMPLIANT Status Reader using SAF (Storage Access Framework)
class StatusReaderService {
  static const platform = MethodChannel('com.example.statussaver/storage');
  static const String _uriKey = 'status_folder_uri';

  /// Opens Android's directory picker for user to select .Statuses folder
  ///
  /// //   static Future<bool> requestFolderAccess() async {

  static Future<bool> requestFolderAccess() async {
    try {
      final String? uri = await platform.invokeMethod('openDirectoryPicker');

      if (uri != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_uriKey, uri);
        print('Status folder URI saved: $uri');
        return true;
      }

      return false;
    } catch (e) {
      print('Error requesting folder access: $e');
      return false;
    }
  }

  /// Check if we have permission to access status folder
  static Future<bool> hasPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uri = prefs.getString(_uriKey);

      if (uri == null) return false;

      final bool hasPermission = await platform.invokeMethod(
        'checkUriPermission',
        {'uri': uri},
      );

      return hasPermission;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  /// Read statuses from the selected folder
  static Future<List<StatusMedia>> readStatuses() async {
    List<StatusMedia> statuses = [];

    print('========== READING STATUSES (SAF) ==========');

    try {
      final prefs = await SharedPreferences.getInstance();
      final uri = prefs.getString(_uriKey);

      if (uri == null) {
        print('No folder selected. User needs to grant access first.');
        return statuses;
      }

      final List<dynamic> files = await platform.invokeMethod(
        'getStatusFiles',
        {'uri': uri},
      );

      for (var file in files) {
        final fileMap = Map<String, dynamic>.from(file);

        statuses.add(
          StatusMedia(
            images: fileMap['uri'] as String,
            isVideo: fileMap['isVideo'] as bool,
            name: fileMap['name'] as String?,
            size: fileMap['size'] as int?,
            lastModified: fileMap['lastModified'] as int?,
          ),
        );
      }

      print('TOTAL STATUSES FOUND: ${statuses.length}');
    } catch (e) {
      print('ERROR reading statuses: $e');
    }

    print('======================================');
    return statuses;
  }

  /// Download status to gallery - COMPLETE IMPLEMENTATION
  static Future<bool> downloadStatus(StatusMedia media) async {
    try {
      print('Starting download for: ${media.images}');

      Uint8List bytes;
      String fileName;

      // Check if it's a content URI or file path
      if (media.images.startsWith('content://')) {
        // Content URI - use platform channel to get bytes
        print('Downloading from content URI...');

        final bytesResult = await platform.invokeMethod<Uint8List>(
          'getBytesFromUri',
          {'uri': media.images},
        );

        if (bytesResult == null) {
          print('Failed to read bytes from content URI');
          return false;
        }

        bytes = bytesResult;
        fileName =
            media.name ?? 'status_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // File path - read directly
        print('Downloading from file path...');

        final file = File(media.images);
        if (!await file.exists()) {
          print('File does not exist: ${media.images}');
          return false;
        }

        bytes = await file.readAsBytes();
        fileName = file.path.split('/').last;
      }

      // Ensure proper file extension
      if (!fileName.contains('.')) {
        if (media.isVideo) {
          fileName += '.mp4';
        } else {
          fileName += '.jpg';
        }
      }

      print('File size: ${bytes.length} bytes');
      print('File name: $fileName');

      // Save using saver_gallery
      if (media.isVideo) {
        // For videos, we need to save to a temporary file first
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(bytes);

        final result = await SaverGallery.saveFile(
          filePath: tempFile.path,
          fileName: fileName,
          androidRelativePath: "Movies/StatusSaver",
          skipIfExists: false,
        );

        // Clean up temp file
        await tempFile.delete();

        if (result.isSuccess) {
          print('Video saved successfully: ${result.isSuccess}');
          return true;
        } else {
          print('Failed to save video: ${result.errorMessage}');
          return false;
        }
      } else {
        // For images, save directly
        final result = await SaverGallery.saveImage(
          bytes,
          quality: 100,
          fileName: fileName,
          androidRelativePath: "Pictures/StatusSaver",
          skipIfExists: false,
        );

        if (result.isSuccess) {
          print('Image saved successfully: ${result.isSuccess}');
          return true;
        } else {
          print('Failed to save image: ${result.errorMessage}');
          return false;
        }
      }
    } catch (e) {
      print('Error downloading status: $e');
      return false;
    }
  }

  /// Download and return local file path (for saving to favorites)
  static Future<String?> downloadAndGetPath(StatusMedia media) async {
    try {
      Uint8List bytes;
      String fileName;

      // Get bytes
      if (media.images.startsWith('content://')) {
        final bytesResult = await platform.invokeMethod<Uint8List>(
          'getBytesFromUri',
          {'uri': media.images},
        );

        if (bytesResult == null) return null;
        bytes = bytesResult;
        fileName =
            media.name ?? 'status_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        final file = File(media.images);
        if (!await file.exists()) return null;
        bytes = await file.readAsBytes();
        fileName = file.path.split('/').last;
      }

      // Ensure extension
      if (!fileName.contains('.')) {
        fileName += media.isVideo ? '.mp4' : '.jpg';
      }

      // Save to app's documents directory for favorites
      final Directory appDir = await Directory.systemTemp.create();
      final String localPath = '${appDir.path}/StatusSaver/$fileName';
      final File localFile = File(localPath);

      // Create directory if doesn't exist
      await localFile.parent.create(recursive: true);

      // Write file
      await localFile.writeAsBytes(bytes);

      // Also save to gallery
      if (media.isVideo) {
        await SaverGallery.saveFile(
          filePath: localPath,
          fileName: fileName,
          androidRelativePath: "Movies/StatusSaver",
          skipIfExists: false,
        );
      } else {
        await SaverGallery.saveImage(
          bytes,
          quality: 100,
          fileName: fileName,
          androidRelativePath: "Pictures/StatusSaver",
          skipIfExists: false,
        );
      }

      return localPath;
    } catch (e) {
      print('Error downloading and saving: $e');
      return null;
    }
  }

  /// Clear saved folder permission
  static Future<void> clearPermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uriKey);
  }

  /// Check if WhatsApp is installed
  static Future<bool> isWhatsAppInstalled() async {
    final paths = [
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
      '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
    ];

    for (final path in paths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        return true;
      }
    }

    return false;
  }
}
