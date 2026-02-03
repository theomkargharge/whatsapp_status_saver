import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StatusSaverService {
  static Future<void> save(String sourcePath) async {
    final dir = await getExternalStorageDirectory();
    final targetDir = Directory('${dir!.path}/SavedStatus');

    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final fileName = sourcePath.split('/').last;
    final targetFile = File('${targetDir.path}/$fileName');

    await File(sourcePath).copy(targetFile.path);
  }
}
