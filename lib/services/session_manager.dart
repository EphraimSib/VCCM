import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'behavioral_security_service.dart';

class SessionManager {
  static const String _ACTIVE_SESSIONS_KEY = 'active_sessions';
  static const String _CURRENT_DEVICE_KEY = 'current_device';
  static const Duration _SESSION_TIMEOUT = Duration(minutes: 30);
  
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final StreamController<List<DeviceSession>> _sessionsController = 
      StreamController<List<DeviceSession>>.broadcast();
  
  Stream<List<DeviceSession>> get activeSessions => _sessionsController.stream;

  // Cached device information
  String? _currentDeviceId;
  String? _currentDeviceName;

  // Session state
  DateTime? _lastActivityTime;
  Timer? _sessionTimer;
  bool _isActive = false;

  Future<void> initialize() async {
    await _loadDeviceInfo();
    await _loadActiveSessions();
    _startSessionTimer();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        _currentDeviceId = androidInfo.id;
        _currentDeviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _currentDeviceId = iosInfo.identifierForVendor;
        _currentDeviceName = '${iosInfo.name} ${iosInfo.model}';
      } else {
        final webInfo = await _deviceInfo.webBrowserInfo;
        _currentDeviceId = webInfo.vendor! + webInfo.userAgent!;
        _currentDeviceName = '${webInfo.browserName} on ${webInfo.platform}';
      }

      // Store current device info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_CURRENT_DEVICE_KEY, _currentDeviceId!);
    } catch (e) {
      debugPrint('Error loading device info: $e');
      // Generate fallback device ID
      _currentDeviceId = DateTime.now().toIso8601String();
      _currentDeviceName = 'Unknown Device';
    }
  }

  Future<void> _loadActiveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_ACTIVE_SESSIONS_KEY) ?? [];
      
      final sessions = sessionsJson
          .map((json) => DeviceSession.fromJson(json))
          .where((session) => _isSessionValid(session))
          .toList();

      _sessionsController.add(sessions);
    } catch (e) {
      debugPrint('Error loading active sessions: $e');
      _sessionsController.add([]);
    }
  }

  bool _isSessionValid(DeviceSession session) {
    final now = DateTime.now();
    return session.status == SessionStatus.active &&
           now.difference(session.startTime) <= _SESSION_TIMEOUT;
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkSessionTimeout(),
    );
  }

  void _checkSessionTimeout() {
    if (_lastActivityTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastActivityTime!) > _SESSION_TIMEOUT) {
        _handleSessionTimeout();
      }
    }
  }

  void _handleSessionTimeout() {
    _isActive = false;
    _lastActivityTime = null;
    _notifySessionChange(SessionStatus.expired);
  }

  Future<bool> startSession(String userId) async {
    if (_currentDeviceId == null) {
      await _loadDeviceInfo();
    }

    final newSession = DeviceSession(
      deviceId: _currentDeviceId!,
      deviceName: _currentDeviceName!,
      userId: userId,
      startTime: DateTime.now(),
      status: SessionStatus.active,
    );

    await _saveSession(newSession);
    _isActive = true;
    _lastActivityTime = DateTime.now();
    _notifySessionChange(SessionStatus.active);
    return true;
  }

  Future<void> _saveSession(DeviceSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await _getActiveSessions();
      
      // Remove any existing session for this device
      sessions.removeWhere((s) => s.deviceId == session.deviceId);
      sessions.add(session);

      // Save updated sessions
      await prefs.setStringList(
        _ACTIVE_SESSIONS_KEY,
        sessions.map((s) => s.toJson()).toList(),
      );

      _sessionsController.add(sessions);
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  Future<List<DeviceSession>> _getActiveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList(_ACTIVE_SESSIONS_KEY) ?? [];
    
    return sessionsJson
        .map((json) => DeviceSession.fromJson(json))
        .where((session) => _isSessionValid(session))
        .toList();
  }

  Future<bool> transferSession(String userId, String targetDeviceId) async {
    if (!_isActive) return false;

    final sessions = await _getActiveSessions();
    final targetSession = sessions.firstWhere(
      (s) => s.deviceId == targetDeviceId,
      orElse: () => null as DeviceSession,
    );

    // Update source session
    await _updateSessionStatus(
      _currentDeviceId!,
      SessionStatus.expired,
    );

    // Update target session
    await _updateSessionStatus(
      targetDeviceId,
      SessionStatus.active,
      startTime: DateTime.now(),
    );

    return true;
  }

  Future<void> _updateSessionStatus(
    String deviceId,
    SessionStatus status, {
    DateTime? startTime,
  }) async {
    final sessions = await _getActiveSessions();
    final index = sessions.indexWhere((s) => s.deviceId == deviceId);
    
    if (index != -1) {
      sessions[index] = sessions[index].copyWith(
        status: status,
        startTime: startTime,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _ACTIVE_SESSIONS_KEY,
        sessions.map((s) => s.toJson()).toList(),
      );

      _sessionsController.add(sessions);
    }
  }

  void updateActivity() {
    _lastActivityTime = DateTime.now();
  }

  Future<void> endSession() async {
    if (_currentDeviceId != null) {
      await _updateSessionStatus(_currentDeviceId!, SessionStatus.expired);
    }
    _isActive = false;
    _lastActivityTime = null;
    _sessionTimer?.cancel();
  }

  void _notifySessionChange(SessionStatus status) {
    // Implement session change notification logic
    // This could include:
    // - Updating UI
    // - Syncing with server
    // - Triggering security checks
  }

  void dispose() {
    _sessionTimer?.cancel();
    _sessionsController.close();
  }
}

extension DeviceSessionJson on DeviceSession {
  String toJson() {
    return '''
    {
      "deviceId": "$deviceId",
      "deviceName": "$deviceName",
      "userId": "$userId",
      "startTime": "${startTime.toIso8601String()}",
      "status": "${status.toString()}"
    }
    ''';
  }

  static DeviceSession fromJson(String json) {
    // Implement JSON parsing
    // This is a simplified version - you should use proper JSON parsing
    final data = json.replaceAll(RegExp(r'[{}\s"]'), '').split(',');
    final map = Map.fromEntries(
      data.map((item) {
        final parts = item.split(':');
        return MapEntry(parts[0], parts[1]);
      }),
    );

    return DeviceSession(
      deviceId: map['deviceId']!,
      deviceName: map['deviceName']!,
      userId: map['userId']!,
      startTime: DateTime.parse(map['startTime']!),
      status: SessionStatus.values.firstWhere(
        (s) => s.toString() == map['status'],
      ),
    );
  }
} 