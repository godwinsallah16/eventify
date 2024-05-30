import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermissionsStatus() async {
  // Check the status of camera, location, and calendar permissions
  PermissionStatus cameraStatus = await Permission.camera.status;
  PermissionStatus locationStatus = await Permission.location.status;
  PermissionStatus calendarStatus = await Permission.calendarWriteOnly.status;

  // Check if any of the permissions are denied
  return !(cameraStatus.isDenied ||
      locationStatus.isDenied ||
      calendarStatus.isDenied);
}

Future<bool> requestPermissions() async {
  // Request all the permissions at once
  Map<Permission, PermissionStatus> permissionStatuses = await [
    Permission.camera,
    Permission.location,
    Permission.calendarWriteOnly, // or Permission.calendarFullAccess
  ].request();

  // Check if all permissions are granted
  bool allPermissionsGranted = permissionStatuses.values
      .every((status) => status == PermissionStatus.granted);

  // Return true if all permissions are granted
  return allPermissionsGranted;
}
