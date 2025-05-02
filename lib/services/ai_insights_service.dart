import 'dart:async';

class SpendingInsight {
  final String title;
  final String description;
  final double confidence;
  final InsightType type;
  final List<String> recommendations;
  final Map<String, double> metrics;

  SpendingInsight({
    required this.title,
    required this.description,
    required this.confidence,
    required this.type,
    required this.recommendations,
    required this.metrics,
  });
}

enum InsightType {
  budgetAlert,
  savingsOpportunity,
  spendingPattern,
  investmentSuggestion,
  billReminder,
  fraudWarning,
}

class AIInsightsService {
  static const double INSIGHT_CONFIDENCE_THRESHOLD = 0.65;
  
  final StreamController<List<SpendingInsight>> _insightsController = 
      StreamController<List<SpendingInsight>>.broadcast();
  
  Stream<List<SpendingInsight>> get insights => _insightsController.stream;

  // Cached user financial data
  final Map<String, UserFinancialData> _userFinancialData = {};

  Future<List<SpendingInsight>> analyzeSpendingPatterns(String userId) async {
    final userData = _userFinancialData[userId];
    if (userData == null) return [];

    final insights = <SpendingInsight>[];
    
    // Analyze budget adherence
    final budgetInsights = await _analyzeBudgetAdherence(userData);
    if (budgetInsights.confidence >= INSIGHT_CONFIDENCE_THRESHOLD) {
      insights.add(budgetInsights);
    }

    // Detect savings opportunities
    final savingsInsights = await _detectSavingsOpportunities(userData);
    if (savingsInsights.confidence >= INSIGHT_CONFIDENCE_THRESHOLD) {
      insights.add(savingsInsights);
    }

    // Analyze recurring expenses
    final recurringInsights = await _analyzeRecurringExpenses(userData);
    if (recurringInsights.confidence >= INSIGHT_CONFIDENCE_THRESHOLD) {
      insights.add(recurringInsights);
    }

    // Generate investment suggestions
    final investmentInsights = await _generateInvestmentSuggestions(userData);
    if (investmentInsights.confidence >= INSIGHT_CONFIDENCE_THRESHOLD) {
      insights.add(investmentInsights);
    }

    _insightsController.add(insights);
    return insights;
  }

  Future<SpendingInsight> _analyzeBudgetAdherence(UserFinancialData data) async {
    final categories = data.spendingByCategory;
    final budgets = data.budgetLimits;
    final overBudgetCategories = <String>[];
    final nearLimitCategories = <String>[];
    
    categories.forEach((category, amount) {
      if (budgets.containsKey(category)) {
        final limit = budgets[category]!;
        final ratio = amount / limit;
        
        if (ratio > 1.0) {
          overBudgetCategories.add(category);
        } else if (ratio > 0.8) {
          nearLimitCategories.add(category);
        }
      }
    });

    if (overBudgetCategories.isEmpty && nearLimitCategories.isEmpty) {
      return SpendingInsight(
        title: 'Budget Status: On Track',
        description: 'You\'re staying within your budget across all categories.',
        confidence: 0.9,
        type: InsightType.budgetAlert,
        recommendations: ['Keep up the good work!'],
        metrics: {'budgetAdherence': 1.0},
      );
    }

    final recommendations = <String>[];
    if (overBudgetCategories.isNotEmpty) {
      recommendations.add(
        'Consider reducing spending in: ${overBudgetCategories.join(", ")}',
      );
    }
    if (nearLimitCategories.isNotEmpty) {
      recommendations.add(
        'Watch spending in: ${nearLimitCategories.join(", ")}',
      );
    }

    return SpendingInsight(
      title: 'Budget Alert',
      description: 'Some categories need attention',
      confidence: 0.85,
      type: InsightType.budgetAlert,
      recommendations: recommendations,
      metrics: {
        'overBudgetCount': overBudgetCategories.length.toDouble(),
        'nearLimitCount': nearLimitCategories.length.toDouble(),
      },
    );
  }

  Future<SpendingInsight> _detectSavingsOpportunities(UserFinancialData data) async {
    final subscriptions = data.recurringExpenses;
    final unusedSubscriptions = <String>[];
    final recommendations = <String>[];

    // Analyze subscription usage
    subscriptions.forEach((subscription, details) {
      if (details.lastUsed.difference(DateTime.now()).inDays > 30) {
        unusedSubscriptions.add(subscription);
      }
    });

    if (unusedSubscriptions.isNotEmpty) {
      recommendations.add(
        'Consider canceling unused subscriptions: ${unusedSubscriptions.join(", ")}',
      );
    }

    // Analyze high-frequency small transactions
    final smallTransactions = data.transactions.where(
      (t) => t.amount < 10 && t.timestamp.isAfter(
        DateTime.now().subtract(const Duration(days: 30)),
      ),
    ).toList();

    if (smallTransactions.length > 15) {
      recommendations.add(
        'Small frequent purchases add up. Consider bulk buying instead.',
      );
    }

    return SpendingInsight(
      title: 'Savings Opportunities',
      description: 'We found some ways you could save money',
      confidence: 0.75,
      type: InsightType.savingsOpportunity,
      recommendations: recommendations,
      metrics: {
        'unusedSubscriptions': unusedSubscriptions.length.toDouble(),
        'smallTransactions': smallTransactions.length.toDouble(),
      },
    );
  }

  Future<SpendingInsight> _analyzeRecurringExpenses(UserFinancialData data) async {
    final recurringExpenses = data.recurringExpenses;
    final recommendations = <String>[];
    final metrics = <String, double>{};

    // Calculate total recurring expenses
    final totalRecurring = recurringExpenses.values
        .map((e) => e.amount)
        .fold(0.0, (a, b) => a + b);
    
    metrics['totalRecurring'] = totalRecurring;
    metrics['recurringCount'] = recurringExpenses.length.toDouble();

    // Find expensive subscriptions
    final expensiveSubscriptions = recurringExpenses.entries
        .where((e) => e.value.amount > 50)
        .map((e) => e.key)
        .toList();

    if (expensiveSubscriptions.isNotEmpty) {
      recommendations.add(
        'Review these higher-cost subscriptions: ${expensiveSubscriptions.join(", ")}',
      );
    }

    // Check for overlapping services
    final serviceTypes = _categorizeServices(recurringExpenses);
    serviceTypes.forEach((type, services) {
      if (services.length > 1) {
        recommendations.add(
          'You have multiple $type subscriptions. Consider consolidating.',
        );
      }
    });

    return SpendingInsight(
      title: 'Recurring Expenses Analysis',
      description: 'Review your subscription services',
      confidence: 0.8,
      type: InsightType.spendingPattern,
      recommendations: recommendations,
      metrics: metrics,
    );
  }

  Future<SpendingInsight> _generateInvestmentSuggestions(UserFinancialData data) async {
    final balance = data.currentBalance;
    final monthlyIncome = data.monthlyIncome;
    final monthlyExpenses = data.monthlyExpenses;
    final recommendations = <String>[];
    final metrics = <String, double>{};

    // Calculate savings potential
    final savingsPotential = monthlyIncome - monthlyExpenses;
    metrics['savingsPotential'] = savingsPotential;

    if (savingsPotential > 500) {
      recommendations.add(
        'Consider investing \$${savingsPotential.toStringAsFixed(2)} monthly',
      );
    }

    // Emergency fund check
    final monthsOfExpenses = balance / monthlyExpenses;
    metrics['emergencyFundMonths'] = monthsOfExpenses;

    if (monthsOfExpenses < 3) {
      recommendations.add(
        'Build emergency fund to cover 3-6 months of expenses',
      );
    } else if (monthsOfExpenses > 6) {
      recommendations.add(
        'Consider investing excess emergency fund for better returns',
      );
    }

    return SpendingInsight(
      title: 'Investment Opportunities',
      description: 'Maximize your financial growth',
      confidence: 0.7,
      type: InsightType.investmentSuggestion,
      recommendations: recommendations,
      metrics: metrics,
    );
  }

  Map<String, List<String>> _categorizeServices(
    Map<String, RecurringExpense> expenses,
  ) {
    final categories = <String, List<String>>{};
    
    expenses.forEach((name, expense) {
      final category = expense.category;
      if (!categories.containsKey(category)) {
        categories[category] = [];
      }
      categories[category]!.add(name);
    });

    return categories;
  }

  void dispose() {
    _insightsController.close();
  }
}

class UserFinancialData {
  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final Map<String, double> spendingByCategory;
  final Map<String, double> budgetLimits;
  final Map<String, RecurringExpense> recurringExpenses;
  final List<Transaction> transactions;

  UserFinancialData({
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.spendingByCategory,
    required this.budgetLimits,
    required this.recurringExpenses,
    required this.transactions,
  });
}

class RecurringExpense {
  final String name;
  final String category;
  final double amount;
  final DateTime lastUsed;

  RecurringExpense({
    required this.name,
    required this.category,
    required this.amount,
    required this.lastUsed,
  });
}

class Transaction {
  final String id;
  final double amount;
  final String category;
  final DateTime timestamp;
  final String description;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.timestamp,
    required this.description,
  });
} 