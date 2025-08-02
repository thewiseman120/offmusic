import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    // For Android 13+ (API 33+), use READ_MEDIA_AUDIO
    // For older versions, use READ_EXTERNAL_STORAGE
    PermissionStatus status;
    
    if (await Permission.audio.isGranted) {
      return true;
    }
    
    status = await Permission.audio.request();
    
    if (status.isDenied) {
      // Try legacy permission for older Android versions
      status = await Permission.storage.request();
    }
    
    return status.isGranted;
  }
  
  static Future<bool> checkPermission() async {
    return await Permission.audio.isGranted || 
           await Permission.storage.isGranted;
  }
}