import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
