import 'dart:async';
import 'dart:math' as math;
import 'advanced_analytics_service.dart';

enum SubscriptionTier {
  basic(price: 0, features: ['Basic Analytics', 'Standard Support']),
  premium(price: 9.99, features: [
    'Advanced Analytics',
    'Priority Support',
    'Cross-Border Payments',
    'Predictive Alerts',
    'Smart Budgeting'
  ]),
  enterprise(price: 29.99, features: [
    'All Premium Features',
    'Dedicated Support',
    'Custom Analytics',
    'API Access',
    'Bulk Transactions'
  ]);

  final double price;
  final List<String> features;
  const SubscriptionTier({required this.price, required this.features});
}

class PredictiveAlert {
  final String type;
  final String message;
  final double confidence;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  PredictiveAlert({
    required this.type,
    required this.message,
    required this.confidence,
    required this.timestamp,
    required this.details,
  });
}

class CrossBorderTransaction {
  final String id;
  final double amount;
  final Currency fromCurrency;
  final Currency toCurrency;
  final double exchangeRate;
  final double fee;
  final String status;
  final DateTime timestamp;

  CrossBorderTransaction({
    required this.id,
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.exchangeRate,
    required this.fee,
    required this.status,
    required this.timestamp,
  });
}

class PremiumAnalyticsService {
  final _alertsController = StreamController<List<PredictiveAlert>>.broadcast();
  final _transactionsController = StreamController<List<CrossBorderTransaction>>.broadcast();
  final _recommendationsController = StreamController<List<String>>.broadcast();
  
  Stream<List<PredictiveAlert>> get alertsStream => _alertsController.stream;
  Stream<List<CrossBorderTransaction>> get transactionsStream => _transactionsController.stream;
  Stream<List<String>> get recommendationsStream => _recommendationsController.stream;

  final AdvancedAnalyticsService _analyticsService;
  final Map<String, SubscriptionTier> _userTiers = {};
  final Map<String, List<PredictiveAlert>> _userAlerts = {};
  final Map<String, List<CrossBorderTransaction>> _userTransactions = {};
  Timer? _analysisTimer;

  PremiumAnalyticsService(this._analyticsService) {
    _startPeriodicAnalysis();
  }

  void _startPeriodicAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _analyzeUserData(),
    );
  }

  void setUserTier(String userId, SubscriptionTier tier) {
    _userTiers[userId] = tier;
    _analyzeUserData();
  }

  Future<CrossBorderTransaction> processCrossBorderPayment({
    required String userId,
    required double amount,
    required Currency fromCurrency,
    required Currency toCurrency,
  }) async {
    if (_userTiers[userId] == SubscriptionTier.basic) {
      throw Exception('Cross-border payments require Premium or Enterprise tier');
    }

    final exchangeRate = toCurrency.rate / fromCurrency.rate;
    final fee = _calculateCrossBorderFee(amount, exchangeRate, _userTiers[userId]!);
    final convertedAmount = amount * exchangeRate;

    final transaction = CrossBorderTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: convertedAmount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      exchangeRate: exchangeRate,
      fee: fee,
      status: 'completed',
      timestamp: DateTime.now(),
    );

    _userTransactions.putIfAbsent(userId, () => []);
    _userTransactions[userId]!.add(transaction);
    _transactionsController.add(_userTransactions[userId]!);

    return transaction;
  }

  double _calculateCrossBorderFee(double amount, double exchangeRate, SubscriptionTier tier) {
    final baseFee = amount * 0.02; // 2% base fee
    switch (tier) {
      case SubscriptionTier.premium:
        return baseFee * 0.5; // 50% discount
      case SubscriptionTier.enterprise:
        return baseFee * 0.2; // 80% discount
      default:
        return baseFee;
    }
  }

  void _analyzeUserData() {
    for (final userId in _userTiers.keys) {
      final analytics = _analyticsService.analyticsStream;
      final tier = _userTiers[userId]!;
      
      if (tier != SubscriptionTier.basic) {
        _generatePredictiveAlerts(userId);
        _generateRecommendations(userId);
      }
    }
  }

  void _generatePredictiveAlerts(String userId) {
    final analytics = _analyticsService.analyticsStream;
    final alerts = <PredictiveAlert>[];

    // Analyze spending patterns
    final recentTransactions = _userTransactions[userId] ?? [];
    if (recentTransactions.isNotEmpty) {
      final totalSpent = recentTransactions
          .map((t) => t.amount)
          .reduce((a, b) => a + b);
      
      final averageSpent = totalSpent / recentTransactions.length;
      final standardDeviation = _calculateStandardDeviation(
        recentTransactions.map((t) => t.amount).toList(),
        averageSpent,
      );

      // Predict potential overspending
      if (totalSpent > averageSpent + (2 * standardDeviation)) {
        alerts.add(PredictiveAlert(
          type: 'spending_alert',
          message: 'Potential overspending detected',
          confidence: 0.85,
          timestamp: DateTime.now(),
          details: {
            'current_spending': totalSpent,
            'average_spending': averageSpent,
            'deviation': standardDeviation,
          },
        ));
      }

      // Predict currency risk
      final currencyExposure = _calculateCurrencyExposure(recentTransactions);
      if (currencyExposure > 0.3) { // More than 30% exposure
        alerts.add(PredictiveAlert(
          type: 'currency_risk',
          message: 'High currency exposure detected',
          confidence: 0.75,
          timestamp: DateTime.now(),
          details: {
            'exposure_percentage': currencyExposure,
            'currencies': recentTransactions
                .map((t) => t.toCurrency.name)
                .toSet()
                .toList(),
          },
        ));
      }
    }

    _userAlerts[userId] = alerts;
    _alertsController.add(alerts);
  }

  double _calculateCurrencyExposure(List<CrossBorderTransaction> transactions) {
    if (transactions.isEmpty) return 0.0;

    final totalAmount = transactions
        .map((t) => t.amount)
        .reduce((a, b) => a + b);
    
    final foreignAmount = transactions
        .where((t) => t.toCurrency != Currency.mwk)
        .map((t) => t.amount)
        .reduce((a, b) => a + b);

    return foreignAmount / totalAmount;
  }

  void _generateRecommendations(String userId) {
    final analytics = _analyticsService.analyticsStream;
    final recommendations = <String>[];

    // Analyze spending patterns
    final recentTransactions = _userTransactions[userId] ?? [];
    if (recentTransactions.isNotEmpty) {
      final totalSpent = recentTransactions
          .map((t) => t.amount)
          .reduce((a, b) => a + b);
      
      final averageSpent = totalSpent / recentTransactions.length;

      // Generate budget recommendations
      if (totalSpent > averageSpent * 1.2) {
        recommendations.add(
          'Consider setting a monthly budget of MWK ${(averageSpent * 0.9).toStringAsFixed(2)} to optimize spending',
        );
      }

      // Generate currency recommendations
      final currencyExposure = _calculateCurrencyExposure(recentTransactions);
      if (currencyExposure > 0.3) {
        recommendations.add(
          'Diversify your currency exposure to reduce risk. Consider converting some foreign currency to MWK',
        );
      }

      // Generate fee optimization recommendations
      final totalFees = recentTransactions
          .map((t) => t.fee)
          .reduce((a, b) => a + b);
      
      if (totalFees > totalSpent * 0.05) {
        recommendations.add(
          'Consider consolidating cross-border transactions to reduce fees',
        );
      }
    }

    _recommendationsController.add(recommendations);
  }

  double _calculateStandardDeviation(List<double> values, double mean) {
    final squaredDifferences = values.map((x) => math.pow(x - mean, 2)).toList();
    final variance = squaredDifferences.reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  void dispose() {
    _analysisTimer?.cancel();
    _alertsController.close();
    _transactionsController.close();
    _recommendationsController.close();
  }
} 