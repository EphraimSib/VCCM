import 'dart:async';
import 'dart:math' as math;

class TransactionPattern {
  final String type;
  final double amount;
  final String category;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  TransactionPattern({
    required this.type,
    required this.amount,
    required this.category,
    required this.timestamp,
    required this.metadata,
  });
}

class TransactionAnalytics {
  final double totalAmount;
  final String category;
  final int transactionCount;
  final double averageAmount;
  final List<TransactionPattern> patterns;
  final Map<String, dynamic> insights;

  TransactionAnalytics({
    required this.totalAmount,
    required this.category,
    required this.transactionCount,
    required this.averageAmount,
    required this.patterns,
    required this.insights,
  });
}

class TransactionAnalyticsService {
  final _analyticsController = StreamController<TransactionAnalytics>.broadcast();
  final _transactionPatterns = <String, List<TransactionPattern>>{};
  final _categoryMetrics = <String, Map<String, double>>{};
  
  Stream<TransactionAnalytics> get analyticsStream => _analyticsController.stream;

  // Initialize analytics service
  Future<void> initialize() async {
    _initializeCategories();
    _startPeriodicAnalysis();
  }

  void _initializeCategories() {
    _categoryMetrics['shopping'] = {
      'totalAmount': 0.0,
      'transactionCount': 0.0,
      'averageAmount': 0.0,
      'frequency': 0.0,
    };
    _categoryMetrics['dining'] = {
      'totalAmount': 0.0,
      'transactionCount': 0.0,
      'averageAmount': 0.0,
      'frequency': 0.0,
    };
    _categoryMetrics['entertainment'] = {
      'totalAmount': 0.0,
      'transactionCount': 0.0,
      'averageAmount': 0.0,
      'frequency': 0.0,
    };
    _categoryMetrics['utilities'] = {
      'totalAmount': 0.0,
      'transactionCount': 0.0,
      'averageAmount': 0.0,
      'frequency': 0.0,
    };
  }

  // Start periodic analysis
  Timer? _analysisTimer;
  void _startPeriodicAnalysis() {
    _analysisTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _performAnalysis();
    });
  }

  // Process new transaction
  Future<void> processTransaction(TransactionPattern transaction) async {
    // Update category metrics
    final category = transaction.category;
    if (!_categoryMetrics.containsKey(category)) {
      _categoryMetrics[category] = {
        'totalAmount': 0.0,
        'transactionCount': 0.0,
        'averageAmount': 0.0,
        'frequency': 0.0,
      };
    }

    _categoryMetrics[category]!['totalAmount'] = 
        (_categoryMetrics[category]!['totalAmount'] ?? 0.0) + transaction.amount;
    _categoryMetrics[category]!['transactionCount'] = 
        (_categoryMetrics[category]!['transactionCount'] ?? 0.0) + 1;
    _categoryMetrics[category]!['averageAmount'] = 
        _categoryMetrics[category]!['totalAmount']! / _categoryMetrics[category]!['transactionCount']!;

    // Store transaction pattern
    if (!_transactionPatterns.containsKey(category)) {
      _transactionPatterns[category] = [];
    }
    _transactionPatterns[category]!.add(transaction);

    // Trigger analysis
    await _performAnalysis();
  }

  // Perform transaction analysis
  Future<void> _performAnalysis() async {
    for (final category in _categoryMetrics.keys) {
      final patterns = _transactionPatterns[category] ?? [];
      if (patterns.isEmpty) continue;

      final metrics = _categoryMetrics[category]!;
      final insights = await _generateInsights(category, patterns);

      final analytics = TransactionAnalytics(
        totalAmount: metrics['totalAmount'] ?? 0.0,
        category: category,
        transactionCount: metrics['transactionCount']?.toInt() ?? 0,
        averageAmount: metrics['averageAmount'] ?? 0.0,
        patterns: patterns,
        insights: insights,
      );

      _analyticsController.add(analytics);
    }
  }

  // Generate insights from transaction patterns
  Future<Map<String, dynamic>> _generateInsights(
    String category,
    List<TransactionPattern> patterns,
  ) async {
    final insights = <String, dynamic>{};
    
    // Analyze spending trends
    insights['trend'] = _analyzeSpendingTrend(patterns);
    
    // Detect unusual patterns
    insights['anomalies'] = _detectAnomalies(patterns);
    
    // Calculate frequency metrics
    insights['frequency'] = _calculateFrequencyMetrics(patterns);
    
    // Generate recommendations
    insights['recommendations'] = _generateRecommendations(
      category,
      patterns,
      insights,
    );

    return insights;
  }

  Map<String, dynamic> _analyzeSpendingTrend(List<TransactionPattern> patterns) {
    if (patterns.isEmpty) return {};

    // Sort patterns by timestamp
    patterns.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate trend metrics
    final amounts = patterns.map((p) => p.amount).toList();
    final trend = _calculateTrendLine(amounts);

    return {
      'direction': trend > 0 ? 'increasing' : 'decreasing',
      'slope': trend.abs(),
      'volatility': _calculateVolatility(amounts),
    };
  }

  double _calculateTrendLine(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final n = values.length;
    var sumX = 0.0;
    var sumY = 0.0;
    var sumXY = 0.0;
    var sumXX = 0.0;
    
    for (var i = 0; i < n; i++) {
      sumX += i.toDouble();
      sumY += values[i];
      sumXY += i * values[i];
      sumXX += i * i;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    return slope;
  }

  double _calculateVolatility(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  List<Map<String, dynamic>> _detectAnomalies(List<TransactionPattern> patterns) {
    final anomalies = <Map<String, dynamic>>[];
    if (patterns.isEmpty) return anomalies;

    // Calculate statistics
    final amounts = patterns.map((p) => p.amount).toList();
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    final stdDev = _calculateStandardDeviation(amounts, mean);
    const threshold = 2.0; // Number of standard deviations for anomaly detection

    // Detect anomalies
    for (final pattern in patterns) {
      final zScore = (pattern.amount - mean).abs() / stdDev;
      if (zScore > threshold) {
        anomalies.add({
          'timestamp': pattern.timestamp.toIso8601String(),
          'amount': pattern.amount,
          'zScore': zScore,
          'type': pattern.type,
        });
      }
    }

    return anomalies;
  }

  double _calculateStandardDeviation(List<double> values, double mean) {
    if (values.isEmpty) return 0.0;
    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  Map<String, dynamic> _calculateFrequencyMetrics(List<TransactionPattern> patterns) {
    if (patterns.isEmpty) return {};

    // Sort patterns by timestamp
    patterns.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate time differences between transactions
    final timeDiffs = <Duration>[];
    for (var i = 1; i < patterns.length; i++) {
      timeDiffs.add(patterns[i].timestamp.difference(patterns[i - 1].timestamp));
    }

    // Calculate average time between transactions
    final avgTimeDiff = timeDiffs.isEmpty ? Duration.zero : Duration(
      milliseconds: timeDiffs
          .map((d) => d.inMilliseconds)
          .reduce((a, b) => a + b) ~/ timeDiffs.length,
    );

    return {
      'averageInterval': avgTimeDiff.inHours,
      'transactionsPerDay': 24 / math.max(avgTimeDiff.inHours, 1),
      'mostActiveDay': _findMostActiveDay(patterns),
      'mostActiveTime': _findMostActiveTime(patterns),
    };
  }

  String _findMostActiveDay(List<TransactionPattern> patterns) {
    final dayCounts = <int, int>{};
    for (final pattern in patterns) {
      final day = pattern.timestamp.weekday;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    var maxCount = 0;
    var mostActiveDay = 1;
    dayCounts.forEach((day, count) {
      if (count > maxCount) {
        maxCount = count;
        mostActiveDay = day;
      }
    });

    switch (mostActiveDay) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
      default: return 'Unknown';
    }
  }

  String _findMostActiveTime(List<TransactionPattern> patterns) {
    final hourCounts = <int, int>{};
    for (final pattern in patterns) {
      final hour = pattern.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    var maxCount = 0;
    var mostActiveHour = 0;
    hourCounts.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        mostActiveHour = hour;
      }
    });

    final period = mostActiveHour < 12 ? 'AM' : 'PM';
    final hour = mostActiveHour < 12 ? mostActiveHour : mostActiveHour - 12;
    return '${hour == 0 ? 12 : hour} $period';
  }

  List<String> _generateRecommendations(
    String category,
    List<TransactionPattern> patterns,
    Map<String, dynamic> insights,
  ) {
    final recommendations = <String>[];
    
    // Check spending trend
    final trend = insights['trend'] as Map<String, dynamic>;
    if (trend['direction'] == 'increasing' && trend['slope'] > 0.1) {
      recommendations.add(
        'Your $category spending is trending upward. Consider setting a budget.',
      );
    }

    // Check transaction frequency
    final frequency = insights['frequency'] as Map<String, dynamic>;
    final transactionsPerDay = frequency['transactionsPerDay'] as double;
    if (transactionsPerDay > 3) {
      recommendations.add(
        'You have frequent $category transactions. Consider consolidating purchases.',
      );
    }

    // Check for anomalies
    final anomalies = insights['anomalies'] as List<Map<String, dynamic>>;
    if (anomalies.isNotEmpty) {
      recommendations.add(
        'Unusual spending patterns detected in $category. Review recent transactions.',
      );
    }

    // Add category-specific recommendations
    switch (category.toLowerCase()) {
      case 'shopping':
        recommendations.add(_generateShoppingRecommendations(patterns));
        break;
      case 'dining':
        recommendations.add(_generateDiningRecommendations(patterns));
        break;
      case 'entertainment':
        recommendations.add(_generateEntertainmentRecommendations(patterns));
        break;
      case 'utilities':
        recommendations.add(_generateUtilitiesRecommendations(patterns));
        break;
    }

    return recommendations;
  }

  String _generateShoppingRecommendations(List<TransactionPattern> patterns) {
    final avgAmount = patterns.map((p) => p.amount).reduce((a, b) => a + b) / patterns.length;
    return avgAmount > 100
        ? 'Consider making a shopping list to avoid impulse purchases.'
        : 'Your shopping habits appear well-managed.';
  }

  String _generateDiningRecommendations(List<TransactionPattern> patterns) {
    final weekendPatterns = patterns.where(
      (p) => p.timestamp.weekday == DateTime.saturday || p.timestamp.weekday == DateTime.sunday,
    );
    final weekendSpending = weekendPatterns.map((p) => p.amount).fold(0.0, (a, b) => a + b);
    return weekendSpending > 200
        ? 'Consider meal planning to reduce weekend dining expenses.'
        : 'Your dining expenses are within reasonable limits.';
  }

  String _generateEntertainmentRecommendations(List<TransactionPattern> patterns) {
    final monthlyTotal = patterns
        .where((p) => p.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .map((p) => p.amount)
        .fold(0.0, (a, b) => a + b);
    return monthlyTotal > 300
        ? 'Look for free or discounted entertainment options in your area.'
        : 'Your entertainment spending is reasonable.';
  }

  String _generateUtilitiesRecommendations(List<TransactionPattern> patterns) {
    final recentPatterns = patterns
        .where((p) => p.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 90))))
        .toList();
    if (recentPatterns.length >= 3) {
      final trend = _calculateTrendLine(recentPatterns.map((p) => p.amount).toList());
      return trend > 0
          ? 'Your utility costs are rising. Consider energy-saving measures.'
          : 'Your utility costs are stable or decreasing.';
    }
    return 'Monitor your utility usage patterns for potential savings.';
  }

  void dispose() {
    _analysisTimer?.cancel();
    _analyticsController.close();
  }
} 