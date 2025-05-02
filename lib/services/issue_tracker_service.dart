import 'dart:developer';

class IssueTrackerService {
  // Singleton pattern
  static final IssueTrackerService _instance = IssueTrackerService._internal();

  factory IssueTrackerService() {
    return _instance;
  }

  IssueTrackerService._internal();

  // Method to log critical test failure and generate debugging report
  void reportCriticalFailure(String testName, String errorDetails, {Map<String, dynamic>? additionalData}) {
    // Here you could integrate with external issue tracking systems or send reports to a server
    final report = _generateDebugReport(testName, errorDetails, additionalData);
    _sendReport(report);
  }

  String _generateDebugReport(String testName, String errorDetails, Map<String, dynamic>? additionalData) {
    final buffer = StringBuffer();
    buffer.writeln('Critical Test Failure Report');
    buffer.writeln('Test: $testName');
    buffer.writeln('Error Details: $errorDetails');
    if (additionalData != null) {
      buffer.writeln('Additional Data:');
      additionalData.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    buffer.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
    return buffer.toString();
  }

  void _sendReport(String report) {
    // For now, just log the report. Replace with actual sending logic.
    log(report, name: 'IssueTrackerService');
  }
}
