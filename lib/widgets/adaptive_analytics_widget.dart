import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/adaptive_analytics_service.dart';

class AdaptiveAnalyticsWidget extends StatelessWidget {
  final AdaptiveAnalytics analytics;
  final bool showDetails;

  const AdaptiveAnalyticsWidget({
    super.key,
    required this.analytics,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAnalyticsCard(),
        if (showDetails) ...[
          const SizedBox(height: 16),
          _buildFinancialGoalsCard(),
          const SizedBox(height: 16),
          _buildFraudAlertsCard(),
        ],
      ],
    );
  }

  Widget _buildAnalyticsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSpendingChart(),
            if (showDetails) ...[
              const SizedBox(height: 16),
              _buildBehavioralInsights(),
              const SizedBox(height: 16),
              _buildRecommendations(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ADAPTIVE ANALYTICS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${analytics.fraudAlerts.length} Alerts',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingChart() {
    final categories = analytics.spendingPatterns.keys.toList();
    final amounts = analytics.spendingPatterns.values.toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: amounts.reduce((a, b) => a > b ? a : b) * 1.2,
          barGroups: categories.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: amounts[entry.key],
                  color: _getCategoryColor(categories[entry.key]),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      categories[value.toInt()],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildBehavioralInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Behavioral Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: analytics.behavioralInsights.length,
          itemBuilder: (context, index) {
            final category = analytics.behavioralInsights.keys.elementAt(index);
            final insights = analytics.behavioralInsights[category] as Map<String, dynamic>;
            
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: _getCategoryColor(category).withOpacity(0.1),
                child: Icon(
                  _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                ),
              ),
              title: Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Trend: ${insights['${category}_trend']}, Frequency: ${insights['${category}_frequency']}',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart Recommendations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: analytics.recommendations.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(analytics.recommendations[index]),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFinancialGoalsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Goals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: analytics.financialGoals.length,
              itemBuilder: (context, index) {
                final goal = analytics.financialGoals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              goal.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${goal.currentAmount.toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: goal.progress / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCategoryColor(goal.category),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${goal.daysRemaining} days remaining',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (goal.milestones.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            goal.milestones.last,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getCategoryColor(goal.category),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFraudAlertsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fraud Alerts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: analytics.fraudAlerts.length,
              itemBuilder: (context, index) {
                final alert = analytics.fraudAlerts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.red[50],
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.warning,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '\$${alert['amount'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      '${alert['category']} on ${alert['timestamp'].toString().split(' ')[0]}',
                    ),
                    trailing: Text(
                      alert['severity'].toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Colors.blue;
      case 'dining':
        return Colors.orange;
      case 'entertainment':
        return Colors.purple;
      case 'utilities':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_cart;
      case 'dining':
        return Icons.restaurant;
      case 'entertainment':
        return Icons.movie;
      case 'utilities':
        return Icons.home;
      default:
        return Icons.category;
    }
  }
}

class AdaptiveAnalyticsStream extends StatelessWidget {
  final AdaptiveAnalyticsService analyticsService;
  final bool showDetails;

  const AdaptiveAnalyticsStream({
    super.key,
    required this.analyticsService,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AdaptiveAnalytics>(
      stream: analyticsService.analyticsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return AdaptiveAnalyticsWidget(
          analytics: snapshot.data!,
          showDetails: showDetails,
        );
      },
    );
  }
} 