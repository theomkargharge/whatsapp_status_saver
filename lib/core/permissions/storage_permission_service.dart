// lib/services/permission_service.dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static Future<bool> requestStoragePermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ (API 33+)
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        
        return photos.isGranted && videos.isGranted;
      } else if (sdkInt >= 30) {
        // Android 11-12 (API 30-32)
        final storage = await Permission.storage.request();
        
        if (storage.isDenied || storage.isPermanentlyDenied) {
          // Try manageExternalStorage for Android 11-12 ONLY if needed
          // Note: This might need justification for Play Store
          final manageStorage = await Permission.manageExternalStorage.request();
          return manageStorage.isGranted || storage.isGranted;
        }
        
        return storage.isGranted;
      } else {
        // Android 10 and below (API 29 and below)
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    }
    return false;
  }

  static Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return await Permission.photos.isGranted && 
               await Permission.videos.isGranted;
      } else if (sdkInt >= 30) {
        return await Permission.storage.isGranted ||
               await Permission.manageExternalStorage.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return false;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}