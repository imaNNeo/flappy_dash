import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceDataSource {
  final _secureStorage = const FlutterSecureStorage();
  static const _deviceIdKey = 'deviceId';

  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    const uuid = Uuid();
    String? deviceId = await readDeviceId();
    if (deviceId != null) {
      return deviceId;
    }
    if (Platform.isIOS) {
      deviceId = (await deviceInfo.iosInfo).identifierForVendor ?? uuid.v4();
    } else if (Platform.isAndroid) {
      deviceId = (await const AndroidId().getId()) ?? uuid.v4();
    } else {
      deviceId = uuid.v4();
    }
    await _writeDeviceId(deviceId);
    return deviceId;
  }

  Future<String?> readDeviceId() async {
    return await _secureStorage.read(key: _deviceIdKey);
  }

  Future<void> _writeDeviceId(String deviceId) async {
    await _secureStorage.write(key: _deviceIdKey, value: deviceId);
  }
}
