import 'package:permission_handler/permission_handler.dart';

class StoragePermissionService {
  static Future<bool> request() async {
    final status = await Permission.storage.request();
    final status2 = await Permission.manageExternalStorage.request();
    if (status.isDenied || status2.isDenied) {
      return false;
    }
    return status.isGranted || status2.isGranted;
  }
}
