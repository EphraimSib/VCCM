import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/security_notification_widget.dart';

class TransactionPattern {
  final String category;
  final double averageAmount;
  final TimeOfDay usualTime;
  final List<int> frequentDays; // 1-7 representing Monday-Sunday
  final String location;

  TransactionPattern({
    required this.category,
    required this.averageAmount,
    required this.usualTime,
    required this.frequentDays,
    required this.location,
  });
}

class TransactionFilterService {
  static const double FRAUD_THRESHOLD = 0.85; // 85% confidence for fraud detection
  static const double AMOUNT_VARIANCE_THRESHOLD = 2.5; // 250% of usual amount
  
  final StreamController<SecurityAlert> _securityAlertsController = 
      StreamController<SecurityAlert>.broadcast();
  
  Stream<SecurityAlert> get securityAlerts => _securityAlertsController.stream;

  // Cached user transaction patterns
  final Map<String, List<TransactionPattern>> _userPatterns = {};

  // AI-suggested filters based on user behavior
  final StreamController<List<FilterSuggestion>> _filterSuggestionsController = 
      StreamController<List<FilterSuggestion>>.broadcast();
  
  Stream<List<FilterSuggestion>> get filterSuggestions => 
      _filterSuggestionsController.stream;

  Future<void> analyzeTransaction(Transaction transaction) async {
    final patterns = _userPatterns[transaction.userId] ?? [];
    final matchingPattern = _findMatchingPattern(transaction, patterns);
    
    if (matchingPattern != null) {
      final fraudScore = _calculateFraudScore(transaction, matchingPattern);
      if (fraudScore >= FRAUD_THRESHOLD) {
        _autoLockTransaction(transaction);
        _notifySecurityAlert(transaction, fraudScore);
      }
    }

    // Update AI patterns
    await _updateTransactionPatterns(transaction);
  }

  Future<List<FilterSuggestion>> getSuggestedFilters(String userId) async {
    final patterns = _userPatterns[userId] ?? [];
    final suggestions = <FilterSuggestion>[];

    if (patterns.isEmpty) return suggestions;

    // Analyze spending patterns
    final categories = _analyzeCategoryPatterns(patterns);
    final timePatterns = _analyzeTimePatterns(patterns);
    final amountPatterns = _analyzeAmountPatterns(patterns);

    // Generate smart suggestions
    suggestions.addAll([
      if (categories.isNotEmpty)
        FilterSuggestion(
          type: FilterType.category,
          title: 'Top Categories',
          description: 'Focus on your most active spending areas',
          values: categories.take(3).toList(),
        ),
      if (timePatterns.isNotEmpty)
        FilterSuggestion(
          type: FilterType.timeRange,
          title: 'Peak Activity Times',
          description: 'View transactions during your busiest hours',
          values: timePatterns,
        ),
      if (amountPatterns.isNotEmpty)
        FilterSuggestion(
          type: FilterType.amount,
          title: 'Unusual Amounts',
          description: 'Transactions outside your normal spending pattern',
          values: amountPatterns,
        ),
    ]);

    _filterSuggestionsController.add(suggestions);
    return suggestions;
  }

  double _calculateFraudScore(Transaction transaction, TransactionPattern pattern) {
    double score = 0;
    int factors = 0;

    // Check amount variance
    final amountRatio = transaction.amount / pattern.averageAmount;
    if (amountRatio > AMOUNT_VARIANCE_THRESHOLD) {
      score += 0.4;
      factors++;
    }

    // Check unusual time
    final transactionTime = TimeOfDay.fromDateTime(transaction.timestamp);
    final timeDifference = _calculateTimeDifference(transactionTime, pattern.usualTime);
    if (timeDifference > 180) { // More than 3 hours difference
      score += 0.3;
      factors++;
    }

    // Check unusual day
    if (!pattern.frequentDays.contains(transaction.timestamp.weekday)) {
      score += 0.2;
      factors++;
    }

    // Check location
    if (transaction.location != pattern.location) {
      score += 0.3;
      factors++;
    }

    return factors > 0 ? score / factors : 0;
  }

  int _calculateTimeDifference(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return (minutes1 - minutes2).abs();
  }

  void _autoLockTransaction(Transaction transaction) {
    // Implement transaction locking logic
    transaction.status = TransactionStatus.locked;
    // Notify backend about locked transaction
  }

  void _notifySecurityAlert(Transaction transaction, double fraudScore) {
    final alert = SecurityAlert.critical(
      'Suspicious Transaction Detected',
      'A transaction of \$${transaction.amount.toStringAsFixed(2)} at ${transaction.merchant} '
      'has been automatically locked due to unusual activity. Fraud confidence: ${(fraudScore * 100).toStringAsFixed(1)}%',
    );
    _securityAlertsController.add(alert);
  }

  Future<void> _updateTransactionPatterns(Transaction transaction) async {
    // Implement ML-based pattern updating logic
    // This would typically involve a more sophisticated ML model
    final patterns = _userPatterns[transaction.userId] ?? [];
    final existingPattern = _findMatchingPattern(transaction, patterns);

    if (existingPattern != null) {
      // Update existing pattern
      _updatePattern(existingPattern, transaction);
    } else {
      // Create new pattern
      patterns.add(TransactionPattern(
        category: transaction.category,
        averageAmount: transaction.amount,
        usualTime: TimeOfDay.fromDateTime(transaction.timestamp),
        frequentDays: [transaction.timestamp.weekday],
        location: transaction.location,
      ));
    }

    _userPatterns[transaction.userId] = patterns;
  }

  TransactionPattern? _findMatchingPattern(
    Transaction transaction,
    List<TransactionPattern> patterns,
  ) {
    return patterns.firstWhere(
      (pattern) => pattern.category == transaction.category,
      orElse: () => null as TransactionPattern,
    );
  }

  void _updatePattern(TransactionPattern pattern, Transaction transaction) {
    // Implement pattern updating logic
    // This would typically involve more sophisticated statistical analysis
  }

  List<String> _analyzeCategoryPatterns(List<TransactionPattern> patterns) {
    // Implement category analysis logic
    return patterns
        .map((p) => p.category)
        .toSet()
        .toList();
  }

  List<TimeOfDay> _analyzeTimePatterns(List<TransactionPattern> patterns) {
    // Implement time pattern analysis logic
    return patterns
        .map((p) => p.usualTime)
        .toSet()
        .toList();
  }

  List<double> _analyzeAmountPatterns(List<TransactionPattern> patterns) {
    // Implement amount pattern analysis logic
    return patterns
        .map((p) => p.averageAmount)
        .toSet()
        .toList();
  }

  void dispose() {
    _securityAlertsController.close();
    _filterSuggestionsController.close();
  }
}

class FilterSuggestion {
  final FilterType type;
  final String title;
  final String description;
  final List<dynamic> values;

  FilterSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.values,
  });
}

enum FilterType {
  category,
  timeRange,
  amount,
  location,
}

class Transaction {
  final String userId;
  final String category;
  final double amount;
  final DateTime timestamp;
  final String merchant;
  final String location;
  TransactionStatus status;

  Transaction({
    required this.userId,
    required this.category,
    required this.amount,
    required this.timestamp,
    required this.merchant,
    required this.location,
    this.status = TransactionStatus.pending,
  });
}

enum TransactionStatus {
  pending,
  completed,
  locked,
  cancelled,
} 