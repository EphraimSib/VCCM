import 'package:flutter/foundation.dart';

enum TestResultFilter {
  all,
  passed,
  failed,
  skipped,
}

class TestResultFilterProvider with ChangeNotifier {
  TestResultFilter _currentFilter = TestResultFilter.all;

  TestResultFilter get currentFilter => _currentFilter;

  void setFilter(TestResultFilter filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      notifyListeners();
    }
  }
}
