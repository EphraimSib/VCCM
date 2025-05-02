import 'package:flutter_test/flutter_test.dart';
import 'package:vccm/services/issue_tracker_service.dart';

class DebugReporter {
  static final IssueTrackerService _issueTracker = IssueTrackerService();

  static void reportIfCriticalFailure(String testName, TestFailure failure) {
    // Define criteria for critical failure, e.g., any failure here
    const isCritical = true;

    if (isCritical) {
      _issueTracker.reportCriticalFailure(
        testName,
        failure.toString(),
      );
    }
  }
}
