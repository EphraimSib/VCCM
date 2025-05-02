import 'dart:async';
import 'dart:math' as math;

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category;
  final List<String> milestones;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.category,
    required this.milestones,
  });

  double get progress => (currentAmount / targetAmount) * 100;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
}

class AdaptiveAnalytics {
  final Map<String, double> spendingPatterns;
  final List<Map<String, dynamic>> fraudAlerts;
  final List<FinancialGoal> financialGoals;
  final Map<String, dynamic> behavioralInsights;
  final Map<String, double> categoryBudgets;
  final List<String> recommendations;

  AdaptiveAnalytics({
    required this.spendingPatterns,
    required this.fraudAlerts,
    required this.financialGoals,
    required this.behavioralInsights,
    required this.categoryBudgets,
    required this.recommendations,
  });
}

class AdaptiveAnalyticsService {
  final _analyticsController = StreamController<AdaptiveAnalytics>.broadcast();
  final _goalsController = StreamController<List<FinancialGoal>>.broadcast();
  
  Stream<AdaptiveAnalytics> get analyticsStream => _analyticsController.stream;
  Stream<List<FinancialGoal>> get goalsStream => _goalsController.stream;

  final Map<String, List<double>> _historicalSpending = {};
  final Map<String, double> _categoryAverages = {};
  final List<FinancialGoal> _goals = [];
  Timer? _analysisTimer;

  void initialize() {
    _startPeriodicAnalysis();
  }

  void _startPeriodicAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performAnalysis(),
    );
  }

  void _performAnalysis() {
    _updateSpendingPatterns();
    _detectFraudPatterns();
    _updateFinancialGoals();
    _generateRecommendations();
    
    final analytics = AdaptiveAnalytics(
      spendingPatterns: _categoryAverages,
      fraudAlerts: _detectFraudPatterns(),
      financialGoals: _goals,
      behavioralInsights: _analyzeBehavior(),
      categoryBudgets: _calculateCategoryBudgets(),
      recommendations: _generateRecommendations(),
    );

    _analyticsController.add(analytics);
  }

  void _updateSpendingPatterns() {
    for (final category in _historicalSpending.keys) {
      final amounts = _historicalSpending[category]!;
      if (amounts.isNotEmpty) {
        _categoryAverages[category] = amounts.reduce((a, b) => a + b) / amounts.length;
      }
    }
  }

  List<Map<String, dynamic>> _detectFraudPatterns() {
    final alerts = <Map<String, dynamic>>[];
    
    for (final category in _historicalSpending.keys) {
      final amounts = _historicalSpending[category]!;
      if (amounts.length < 3) continue;

      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance = amounts.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / amounts.length;
      final stdDev = math.sqrt(variance);

      // Detect anomalies (transactions > 3 standard deviations from mean)
      for (var i = 0; i < amounts.length; i++) {
        if ((amounts[i] - mean).abs() > 3 * stdDev) {
          alerts.add({
            'category': category,
            'amount': amounts[i],
            'timestamp': DateTime.now().subtract(Duration(days: amounts.length - i - 1)),
            'severity': 'high',
            'description': 'Unusual spending pattern detected',
          });
        }
      }
    }

    return alerts;
  }

  void _updateFinancialGoals() {
    for (final goal in _goals) {
      final categorySpending = _historicalSpending[goal.category] ?? [];
      if (categorySpending.isNotEmpty) {
        final monthlyAverage = categorySpending.reduce((a, b) => a + b) / categorySpending.length;
        final projectedSavings = monthlyAverage * (goal.daysRemaining / 30);
        
        if (projectedSavings > goal.targetAmount - goal.currentAmount) {
          goal.milestones.add('On track to meet goal by ${goal.targetDate.toString().split(' ')[0]}');
        } else {
          goal.milestones.add('Need to increase savings by \$${(goal.targetAmount - goal.currentAmount - projectedSavings).toStringAsFixed(2)}');
        }
      }
    }
    _goalsController.add(_goals);
  }

  Map<String, dynamic> _analyzeBehavior() {
    final insights = <String, dynamic>{};
    
    for (final category in _historicalSpending.keys) {
      final amounts = _historicalSpending[category]!;
      if (amounts.length < 2) continue;

      // Calculate spending trend
      final trend = _calculateTrend(amounts);
      insights['${category}_trend'] = trend > 0.1 ? 'increasing' : trend < -0.1 ? 'decreasing' : 'stable';

      // Calculate spending frequency
      final frequency = amounts.length / 30; // Average transactions per month
      insights['${category}_frequency'] = frequency > 10 ? 'high' : frequency > 5 ? 'medium' : 'low';
    }

    return insights;
  }

  double _calculateTrend(List<double> values) {
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

    return (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  }

  Map<String, double> _calculateCategoryBudgets() {
    final budgets = <String, double>{};
    final totalIncome = _categoryAverages.values.reduce((a, b) => a + b);
    
    for (final category in _categoryAverages.keys) {
      final percentage = (_categoryAverages[category]! / totalIncome) * 100;
      budgets[category] = percentage;
    }

    return budgets;
  }

  List<String> _generateRecommendations() {
    final recommendations = <String>[];
    
    // Analyze spending patterns
    for (final category in _categoryAverages.keys) {
      final trend = _calculateTrend(_historicalSpending[category] ?? []);
      if (trend > 0.1) {
        recommendations.add('Consider reducing $category spending as it\'s trending upward');
      }
    }

    // Check financial goals
    for (final goal in _goals) {
      if (goal.progress < 50 && goal.daysRemaining < 30) {
        recommendations.add('Accelerate savings for ${goal.name} to meet your target');
      }
    }

    // Suggest budget adjustments
    final budgets = _calculateCategoryBudgets();
    for (final category in budgets.keys) {
      if (budgets[category]! > 30) {
        recommendations.add('$category spending is high. Consider reallocating some funds');
      }
    }

    return recommendations;
  }

  void addTransaction(String category, double amount) {
    _historicalSpending.putIfAbsent(category, () => []).add(amount);
    _performAnalysis();
  }

  void addFinancialGoal(FinancialGoal goal) {
    _goals.add(goal);
    _goalsController.add(_goals);
    _performAnalysis();
  }

  void updateFinancialGoal(String goalId, double newAmount) {
    final goal = _goals.firstWhere((g) => g.id == goalId);
    goal.currentAmount = newAmount;
    _goalsController.add(_goals);
    _performAnalysis();
  }

  void dispose() {
    _analysisTimer?.cancel();
    _analyticsController.close();
    _goalsController.close();
  }
} 