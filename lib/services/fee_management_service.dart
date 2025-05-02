import 'dart:async';
import 'subscription_service.dart';

class FeeTier {
  final double minAmount;
  final double maxAmount;
  final double fixedFee;

  FeeTier({
    required this.minAmount,
    required this.maxAmount,
    required this.fixedFee,
  });
}

class RevenueAllocation {
  final double operationalCosts;
  final double businessGrowth;
  final double reserveFund;
  final double marketing;
  final double researchDevelopment;

  RevenueAllocation({
    required this.operationalCosts,
    required this.businessGrowth,
    required this.reserveFund,
    required this.marketing,
    required this.researchDevelopment,
  });

  double get total => operationalCosts + businessGrowth + reserveFund + marketing + researchDevelopment;
}

class FinancialMetrics {
  final double totalRevenue;
  final double subscriptionRevenue;
  final double transactionFees;
  final double withdrawalFees;
  final RevenueAllocation allocation;
  final Map<String, double> categoryBreakdown;
  final List<Map<String, dynamic>> recentTransactions;

  FinancialMetrics({
    required this.totalRevenue,
    required this.subscriptionRevenue,
    required this.transactionFees,
    required this.withdrawalFees,
    required this.allocation,
    required this.categoryBreakdown,
    required this.recentTransactions,
  });
}

class FeeManagementService {
  final _metricsController = StreamController<FinancialMetrics>.broadcast();
  final _allocationController = StreamController<RevenueAllocation>.broadcast();
  
  Stream<FinancialMetrics> get metricsStream => _metricsController.stream;
  Stream<RevenueAllocation> get allocationStream => _allocationController.stream;

  final List<FeeTier> _withdrawalFeeTiers = [
    FeeTier(minAmount: 100, maxAmount: 5000, fixedFee: 200),
    FeeTier(minAmount: 5001, maxAmount: 10000, fixedFee: 250),
    FeeTier(minAmount: 10001, maxAmount: 20000, fixedFee: 500),
    FeeTier(minAmount: 20001, maxAmount: double.infinity, fixedFee: 1000),
  ];

  final Map<String, double> _revenueCategories = {
    'subscription': 0.0,
    'transaction_fees': 0.0,
    'withdrawal_fees': 0.0,
  };

  final List<Map<String, dynamic>> _recentTransactions = [];
  Timer? _metricsTimer;
  final SubscriptionService _subscriptionService;

  FeeManagementService(this._subscriptionService) {
    _startPeriodicMetricsUpdate();
  }

  void _startPeriodicMetricsUpdate() {
    _metricsTimer?.cancel();
    _metricsTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _updateMetrics(),
    );
  }

  double calculateWithdrawalFee(double amount) {
    final tier = _withdrawalFeeTiers.firstWhere(
      (tier) => amount >= tier.minAmount && amount < tier.maxAmount,
      orElse: () => _withdrawalFeeTiers.last,
    );
    
    return tier.fixedFee;
  }

  RevenueAllocation calculateRevenueAllocation(double totalRevenue) {
    return RevenueAllocation(
      operationalCosts: totalRevenue * 0.40,
      businessGrowth: totalRevenue * 0.25,
      reserveFund: totalRevenue * 0.15,
      marketing: totalRevenue * 0.12,
      researchDevelopment: totalRevenue * 0.08,
    );
  }

  Future<void> processWithdrawal(String userId, double amount) async {
    if (!_subscriptionService.isSubscriptionActive(userId)) {
      throw Exception('User must have an active subscription to withdraw funds');
    }

    final fee = calculateWithdrawalFee(amount);
    final totalAmount = amount + fee;
    
    _revenueCategories['withdrawal_fees'] = _revenueCategories['withdrawal_fees']! + fee;
    _recentTransactions.add({
      'type': 'withdrawal',
      'userId': userId,
      'amount': amount,
      'fee': fee,
      'timestamp': DateTime.now(),
    });

    _updateMetrics();
  }

  Future<void> processSubscription(String userId, SubscriptionPlan plan) async {
    await _subscriptionService.subscribeUser(userId, plan);
    _revenueCategories['subscription'] = _revenueCategories['subscription']! + plan.amount;
    _recentTransactions.add({
      'type': 'subscription',
      'userId': userId,
      'amount': plan.amount,
      'plan': plan.name,
      'timestamp': DateTime.now(),
    });

    _updateMetrics();
  }

  void processTransaction(String userId, double amount, double fee) {
    if (!_subscriptionService.isSubscriptionActive(userId)) {
      throw Exception('User must have an active subscription to perform transactions');
    }

    _revenueCategories['transaction_fees'] = _revenueCategories['transaction_fees']! + fee;
    _recentTransactions.add({
      'type': 'transaction',
      'userId': userId,
      'amount': amount,
      'fee': fee,
      'timestamp': DateTime.now(),
    });

    _updateMetrics();
  }

  void _updateMetrics() {
    final totalRevenue = _revenueCategories.values.reduce((a, b) => a + b);
    final allocation = calculateRevenueAllocation(totalRevenue);
    
    final metrics = FinancialMetrics(
      totalRevenue: totalRevenue,
      subscriptionRevenue: _revenueCategories['subscription']!,
      transactionFees: _revenueCategories['transaction_fees']!,
      withdrawalFees: _revenueCategories['withdrawal_fees']!,
      allocation: allocation,
      categoryBreakdown: Map.from(_revenueCategories),
      recentTransactions: List.from(_recentTransactions),
    );

    _metricsController.add(metrics);
    _allocationController.add(allocation);
  }

  Map<String, double> getRevenueBreakdown() {
    final total = _revenueCategories.values.reduce((a, b) => a + b);
    return _revenueCategories.map(
      (key, value) => MapEntry(key, (value / total) * 100),
    );
  }

  List<Map<String, dynamic>> getRecentTransactions({int limit = 10}) {
    _recentTransactions.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return _recentTransactions.take(limit).toList();
  }

  void dispose() {
    _metricsTimer?.cancel();
    _metricsController.close();
    _allocationController.close();
  }
} 