import 'package:flutter/foundation.dart';

class BetaFeedback {
  final String userId;
  final String feedback;
  final DateTime timestamp;
  bool responded;

  BetaFeedback({
    required this.userId,
    required this.feedback,
    required this.timestamp,
    this.responded = false,
  });
}

class BetaEngagementProvider with ChangeNotifier {
  final List<BetaFeedback> _feedbackList = [];

  List<BetaFeedback> get feedbackList => List.unmodifiable(_feedbackList);

  void addFeedback(BetaFeedback feedback) {
    _feedbackList.add(feedback);
    notifyListeners();
  }

  void markResponded(String userId, DateTime timestamp) {
    final index = _feedbackList.indexWhere((f) => f.userId == userId && f.timestamp == timestamp);
    if (index != -1) {
      _feedbackList[index].responded = true;
      notifyListeners();
    }
  }
}
