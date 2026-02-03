import 'dart:developer';
import 'dart:io';
import '../data/models/status_media.dart';

class StatusReaderService {
  static const String statusPath =
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';

  static List<StatusMedia> readStatuses() {
    try {
      final dir = Directory(statusPath);

      log("dir dir ${dir.listSync()}");
      if (!dir.existsSync()) return [];

      var res = dir
          .listSync()
          .where(
            (file) => file.path.endsWith('.jpg') || file.path.endsWith('.mp4'),
          )
          .map(
            (file) => StatusMedia(
              images: file.path,
              isVideo: file.path.endsWith('.mp4'),
            ),
          )
          .toList()
          .reversed
          .toList();

      log("res ${res}");

      return res;
    } catch (e) {
     return [];
    }
  }
}
