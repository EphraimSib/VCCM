import 'package:device_info_plus/device_info_plus.dart';

class DeviceTestData {
  final String deviceId;
  final String deviceModel;
  final String platform;
  final Map<String, dynamic> testResults;

  DeviceTestData({
    required this.deviceId,
    required this.deviceModel,
    required this.platform,
    required this.testResults,
  });
}

class MultiDeviceInsightsService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<DeviceTestData> collectDeviceTestData(Map<String, dynamic> testResults) async {
    String deviceId = 'unknown';
    String deviceModel = 'unknown';
    String platform = 'unknown';

    try {
      final deviceInfo = await _deviceInfo.deviceInfo;
      final data = deviceInfo.data;
      deviceId = data['id'] ?? 'unknown';
      deviceModel = data['model'] ?? 'unknown';
      platform = data['platform'] ?? 'unknown';
    } catch (e) {
      // Handle error or fallback
    }

    return DeviceTestData(
      deviceId: deviceId,
      deviceModel: deviceModel,
      platform: platform,
      testResults: testResults,
    );
  }

  // Additional methods to analyze and aggregate data can be added here
}
