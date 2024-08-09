import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status;
  }
}
