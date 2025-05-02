import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../widgets/security_notification_widget.dart';

class BehavioralPattern {
  final String deviceId;
  final String location;
  final TimeOfDay usualLoginTime;
  final List<String> frequentIPs;
  final List<String> trustedDevices;
  final Map<String, double> typicalBehavior;

  BehavioralPattern({
    required this.deviceId,
    required this.location,
    required this.usualLoginTime,
    required this.frequentIPs,
    required this.trustedDevices,
    required this.typicalBehavior,
  });
}

class BiometricAuthResult {
  final bool success;
  final String? error;
  final BiometricType? type;

  BiometricAuthResult({
    required this.success,
    this.error,
    this.type,
  });
}

class BehavioralSecurityService {
  static const double RISK_THRESHOLD = 0.75;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final StreamController<SecurityAlert> _securityAlertsController = 
      StreamController<SecurityAlert>.broadcast();
  
  Stream<SecurityAlert> get securityAlerts => _securityAlertsController.stream;

  // Cached behavioral patterns by user
  final Map<String, BehavioralPattern> _userPatterns = {};
  
  // Active sessions across devices
  final Map<String, List<DeviceSession>> _activeSessions = {};

  Future<BiometricAuthResult> authenticateWithBiometrics() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        return BiometricAuthResult(
          success: false,
          error: 'Biometric authentication not available',
        );
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return BiometricAuthResult(
          success: false,
          error: 'No biometric methods configured',
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return BiometricAuthResult(
        success: authenticated,
        type: availableBiometrics.first,
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<void> analyzeBehavior(UserActivity activity) async {
    final pattern = _userPatterns[activity.userId];
    if (pattern != null) {
      final riskScore = await _calculateRiskScore(activity, pattern);
      if (riskScore >= RISK_THRESHOLD) {
        await _handleSuspiciousActivity(activity, riskScore);
      }
    }
    await _updateBehavioralPattern(activity);
  }

  Future<double> _calculateRiskScore(
    UserActivity activity,
    BehavioralPattern pattern,
  ) async {
    double score = 0;
    int factors = 0;

    // Check login time deviation
    final loginTime = TimeOfDay.fromDateTime(activity.timestamp);
    final timeDifference = _calculateTimeDifference(loginTime, pattern.usualLoginTime);
    if (timeDifference > 180) { // More than 3 hours difference
      score += 0.3;
      factors++;
    }

    // Check location anomaly
    if (activity.location != pattern.location) {
      score += 0.3;
      factors++;
    }

    // Check device trust
    if (!pattern.trustedDevices.contains(activity.deviceId)) {
      score += 0.2;
      factors++;
    }

    // Check IP address
    if (!pattern.frequentIPs.contains(activity.ipAddress)) {
      score += 0.2;
      factors++;
    }

    // Analyze behavioral metrics
    final behaviorScore = _analyzeBehavioralMetrics(
      activity.behaviorMetrics,
      pattern.typicalBehavior,
    );
    if (behaviorScore > 0) {
      score += behaviorScore;
      factors++;
    }

    return factors > 0 ? score / factors : 0;
  }

  double _analyzeBehavioralMetrics(
    Map<String, double> current,
    Map<String, double> typical,
  ) {
    double totalDeviation = 0;
    int metrics = 0;

    current.forEach((key, value) {
      if (typical.containsKey(key)) {
        final deviation = (value - typical[key]!).abs() / typical[key]!;
        if (deviation > 0.5) { // 50% deviation threshold
          totalDeviation += deviation;
          metrics++;
        }
      }
    });

    return metrics > 0 ? totalDeviation / metrics : 0;
  }

  Future<void> _handleSuspiciousActivity(
    UserActivity activity,
    double riskScore,
  ) async {
    // Lock the session
    _lockUserSession(activity.userId, activity.deviceId);

    // Notify about suspicious activity
    final alert = SecurityAlert.critical(
      'Suspicious Activity Detected',
      'Unusual activity detected on your account from ${activity.location}. '
      'Risk Score: ${(riskScore * 100).toStringAsFixed(1)}%',
    );
    _securityAlertsController.add(alert);

    // Request additional verification if risk is very high
    if (riskScore > 0.9) {
      await _requestAdditionalVerification(activity);
    }
  }

  void _lockUserSession(String userId, String deviceId) {
    final sessions = _activeSessions[userId] ?? [];
    final sessionIndex = sessions.indexWhere((s) => s.deviceId == deviceId);
    if (sessionIndex != -1) {
      sessions[sessionIndex] = sessions[sessionIndex].copyWith(
        status: SessionStatus.locked,
      );
      _activeSessions[userId] = sessions;
    }
  }

  Future<void> _requestAdditionalVerification(UserActivity activity) async {
    // Implement additional verification logic
    // This could include:
    // - SMS verification
    // - Email verification
    // - Security questions
    // - Manual review
  }

  Future<void> _updateBehavioralPattern(UserActivity activity) async {
    final pattern = _userPatterns[activity.userId];
    if (pattern != null) {
      // Update existing pattern
      _updatePattern(pattern, activity);
    } else {
      // Create new pattern
      _userPatterns[activity.userId] = BehavioralPattern(
        deviceId: activity.deviceId,
        location: activity.location,
        usualLoginTime: TimeOfDay.fromDateTime(activity.timestamp),
        frequentIPs: [activity.ipAddress],
        trustedDevices: [activity.deviceId],
        typicalBehavior: activity.behaviorMetrics,
      );
    }
  }

  void _updatePattern(BehavioralPattern pattern, UserActivity activity) {
    // Update pattern with new activity data
    // This would typically involve more sophisticated statistical analysis
  }

  int _calculateTimeDifference(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return (minutes1 - minutes2).abs();
  }

  Future<bool> transferSession(String userId, String fromDevice, String toDevice) async {
    final sessions = _activeSessions[userId] ?? [];
    final sourceSession = sessions.firstWhere(
      (s) => s.deviceId == fromDevice,
      orElse: () => null as DeviceSession,
    );

    if (sourceSession.status != SessionStatus.active) {
      return false;
    }

    // Create new session for target device
    final newSession = DeviceSession(
      deviceId: toDevice,
      deviceName: sourceSession.deviceName,
      userId: sourceSession.userId,
      startTime: DateTime.now(),
      status: SessionStatus.active,
    );

    // Update sessions
    sessions.add(newSession);
    _activeSessions[userId] = sessions;

    // Notify about session transfer
    _securityAlertsController.add(
      SecurityAlert.info(
        'Session Transferred',
        'Your session has been transferred to a new device.',
      ),
    );

    return true;
  }

  void dispose() {
    _securityAlertsController.close();
  }
}

class UserActivity {
  final String userId;
  final String deviceId;
  final String location;
  final String ipAddress;
  final DateTime timestamp;
  final Map<String, double> behaviorMetrics;

  UserActivity({
    required this.userId,
    required this.deviceId,
    required this.location,
    required this.ipAddress,
    required this.timestamp,
    required this.behaviorMetrics,
  });
}

class DeviceSession {
  final String deviceId;
  final String deviceName;
  final String userId;
  final DateTime startTime;
  final SessionStatus status;

  DeviceSession({
    required this.deviceId,
    required this.deviceName,
    required this.userId,
    required this.startTime,
    required this.status,
  });

  DeviceSession copyWith({
    String? deviceId,
    String? deviceName,
    String? userId,
    DateTime? startTime,
    SessionStatus? status,
  }) {
    return DeviceSession(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
    );
  }
}

enum SessionStatus {
  active,
  locked,
  expired,
} 