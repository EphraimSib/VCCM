import 'dart:async';
import 'dart:math' as math;
import 'subscription_service.dart';
import 'fee_management_service.dart';

enum Currency {
  mwk(rate: 1.0, symbol: 'MWK'),
  usd(rate: 0.0006, symbol: '\$'),
  eur(rate: 0.0005, symbol: '€'),
  gbp(rate: 0.0004, symbol: '£');

  final double rate;
  final String symbol;
  const Currency({required this.rate, required this.symbol});
}

class UserAnalytics {
  final String userId;
  final double totalSpent;
  final double averageTransaction;
  final int transactionCount;
  final double subscriptionUtilization;
  final List<Map<String, dynamic>> spendingPatterns;
  final Map<String, double> categoryBreakdown;
  final double riskScore;
  final List<String> fraudAlerts;

  UserAnalytics({
    required this.userId,
    required this.totalSpent,
    required this.averageTransaction,
    required this.transactionCount,
    required this.subscriptionUtilization,
    required this.spendingPatterns,
    required this.categoryBreakdown,
    required this.riskScore,
    required this.fraudAlerts,
  });
}

class AdaptivePricing {
  final double basePrice;
  final double engagementMultiplier;
  final double loyaltyDiscount;
  final double volumeDiscount;
  final double finalPrice;

  AdaptivePricing({
    required this.basePrice,
    required this.engagementMultiplier,
    required this.loyaltyDiscount,
    required this.volumeDiscount,
    required this.finalPrice,
  });
}

class AdvancedAnalyticsService {
  final _analyticsController = StreamController<UserAnalytics>.broadcast();
  final _pricingController = StreamController<AdaptivePricing>.broadcast();
  
  Stream<UserAnalytics> get analyticsStream => _analyticsController.stream;
  Stream<AdaptivePricing> get pricingStream => _pricingController.stream;

  final SubscriptionService _subscriptionService;
  final FeeManagementService _feeService;
  final Map<String, List<Map<String, dynamic>>> _userTransactions = {};
  final Map<String, double> _userRiskScores = {};
  final Map<String, List<String>> _userFraudAlerts = {};
  Timer? _analyticsTimer;

  AdvancedAnalyticsService(this._subscriptionService, this._feeService) {
    _startPeriodicAnalyticsUpdate();
  }

  void _startPeriodicAnalyticsUpdate() {
    _analyticsTimer?.cancel();
    _analyticsTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _updateAnalytics(),
    );
  }

  double convertCurrency(double amount, Currency from, Currency to) {
    return amount * (to.rate / from.rate);
  }

  Future<void> processTransaction(
    String userId,
    double amount,
    String category,
    Currency currency,
  ) async {
    final mwkAmount = convertCurrency(amount, currency, Currency.mwk);
    
    _userTransactions.putIfAbsent(userId, () => []);
    _userTransactions[userId]!.add({
      'amount': mwkAmount,
      'category': category,
      'currency': currency.name,
      'timestamp': DateTime.now(),
    });

    _detectFraud(userId, mwkAmount);
    _updateAnalytics();
  }

  void _detectFraud(String userId, double amount) {
    final transactions = _userTransactions[userId] ?? [];
    if (transactions.isEmpty) return;

    final recentTransactions = transactions
        .where((t) => DateTime.now().difference(t['timestamp']).inHours < 24)
        .toList();
    
    final totalRecentAmount = recentTransactions
        .map((t) => t['amount'] as double)
        .reduce((a, b) => a + b);

    final averageAmount = totalRecentAmount / recentTransactions.length;
    final standardDeviation = _calculateStandardDeviation(
      recentTransactions.map((t) => t['amount'] as double).toList(),
      averageAmount,
    );

    // Detect anomalies
    if (amount > averageAmount + (3 * standardDeviation)) {
      _userFraudAlerts.putIfAbsent(userId, () => []);
      _userFraudAlerts[userId]!.add(
        'Suspicious large transaction detected: MWK ${amount.toStringAsFixed(2)}',
      );
    }

    // Update risk score
    final riskScore = _calculateRiskScore(
      transactions,
      recentTransactions,
      averageAmount,
      standardDeviation,
    );
    _userRiskScores[userId] = riskScore;
  }

  double _calculateStandardDeviation(List<double> values, double mean) {
    final squaredDifferences = values.map((x) => math.pow(x - mean, 2)).toList();
    final variance = squaredDifferences.reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  double _calculateRiskScore(
    List<Map<String, dynamic>> allTransactions,
    List<Map<String, dynamic>> recentTransactions,
    double averageAmount,
    double standardDeviation,
  ) {
    final timeBasedScore = recentTransactions.length > 10 ? 0.3 : 0.1;
    final amountBasedScore = standardDeviation > averageAmount ? 0.4 : 0.2;
    final frequencyScore = allTransactions.length > 50 ? 0.3 : 0.1;
    
    return (timeBasedScore + amountBasedScore + frequencyScore) / 3;
  }

  AdaptivePricing calculateAdaptivePricing(String userId) {
    final transactions = _userTransactions[userId] ?? [];
    final subscription = _subscriptionService.getSubscription(userId);
    final isActive = _subscriptionService.isSubscriptionActive(userId);

    // Base engagement score (0-1)
    final engagementScore = _calculateEngagementScore(transactions);
    
    // Loyalty discount (0-20%)
    final loyaltyDiscount = math.min(transactions.length * 0.01, 0.2);
    
    // Volume discount (0-15%)
    final totalVolume = transactions
        .map((t) => t['amount'] as double)
        .reduce((a, b) => a + b);
    final volumeDiscount = math.min(totalVolume * 0.00001, 0.15);

    final basePrice = subscription?.plan.amount.toDouble() ?? 1500.0;
    final engagementMultiplier = 1.0 + (engagementScore * 0.2);
    final finalPrice = basePrice * engagementMultiplier * (1 - loyaltyDiscount) * (1 - volumeDiscount);

    return AdaptivePricing(
      basePrice: basePrice,
      engagementMultiplier: engagementMultiplier,
      loyaltyDiscount: loyaltyDiscount,
      volumeDiscount: volumeDiscount,
      finalPrice: finalPrice,
    );
  }

  double _calculateEngagementScore(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) return 0.0;

    final recentTransactions = transactions
        .where((t) => DateTime.now().difference(t['timestamp']).inDays < 30)
        .toList();

    final frequencyScore = math.min(recentTransactions.length / 30, 1.0);
    final amountScore = math.min(
      recentTransactions
          .map((t) => t['amount'] as double)
          .reduce((a, b) => a + b) /
          10000,
      1.0,
    );
    final categoryScore = recentTransactions
            .map((t) => t['category'] as String)
            .toSet()
            .length /
        5;

    return (frequencyScore + amountScore + categoryScore) / 3;
  }

  void _updateAnalytics() {
    for (final userId in _userTransactions.keys) {
      final transactions = _userTransactions[userId]!;
      final totalSpent = transactions
          .map((t) => t['amount'] as double)
          .reduce((a, b) => a + b);
      
      final categoryBreakdown = <String, double>{};
      for (final transaction in transactions) {
        final category = transaction['category'] as String;
        final amount = transaction['amount'] as double;
        categoryBreakdown[category] = (categoryBreakdown[category] ?? 0) + amount;
      }

      final analytics = UserAnalytics(
        userId: userId,
        totalSpent: totalSpent,
        averageTransaction: totalSpent / transactions.length,
        transactionCount: transactions.length,
        subscriptionUtilization: _calculateSubscriptionUtilization(userId),
        spendingPatterns: _analyzeSpendingPatterns(transactions),
        categoryBreakdown: categoryBreakdown,
        riskScore: _userRiskScores[userId] ?? 0.0,
        fraudAlerts: _userFraudAlerts[userId] ?? [],
      );

      _analyticsController.add(analytics);
      _pricingController.add(calculateAdaptivePricing(userId));
    }
  }

  double _calculateSubscriptionUtilization(String userId) {
    final subscription = _subscriptionService.getSubscription(userId);
    if (subscription == null) return 0.0;

    final transactions = _userTransactions[userId] ?? [];
    final subscriptionAmount = subscription.plan.amount.toDouble();
    final totalSpent = transactions
        .map((t) => t['amount'] as double)
        .reduce((a, b) => a + b);

    return math.min(totalSpent / subscriptionAmount, 1.0);
  }

  List<Map<String, dynamic>> _analyzeSpendingPatterns(
    List<Map<String, dynamic>> transactions,
  ) {
    final patterns = <Map<String, dynamic>>[];
    final recentTransactions = transactions
        .where((t) => DateTime.now().difference(t['timestamp']).inDays < 30)
        .toList();

    // Analyze daily spending
    final dailySpending = <String, double>{};
    for (final transaction in recentTransactions) {
      final date = transaction['timestamp'].toString().split(' ')[0];
      dailySpending[date] = (dailySpending[date] ?? 0) + transaction['amount'];
    }
    patterns.add({
      'type': 'daily_spending',
      'data': dailySpending,
    });

    // Analyze category trends
    final categoryTrends = <String, List<double>>{};
    for (final transaction in recentTransactions) {
      final category = transaction['category'] as String;
      categoryTrends.putIfAbsent(category, () => []);
      categoryTrends[category]!.add(transaction['amount']);
    }
    patterns.add({
      'type': 'category_trends',
      'data': categoryTrends,
    });

    return patterns;
  }

  void dispose() {
    _analyticsTimer?.cancel();
    _analyticsController.close();
    _pricingController.close();
  }
} 