import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/advanced_analytics_service.dart';

class AdvancedAnalyticsWidget extends StatelessWidget {
  final UserAnalytics analytics;
  final bool showDetails;

  const AdvancedAnalyticsWidget({
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
          _buildFraudDetectionCard(),
          const SizedBox(height: 16),
          _buildSpendingPatternsCard(),
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
            _buildMetricsGrid(),
            const SizedBox(height: 16),
            _buildRiskIndicator(),
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
          'USER ANALYTICS',
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
            color: _getRiskColor(analytics.riskScore).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Risk Score: ${(analytics.riskScore * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: _getRiskColor(analytics.riskScore),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Total Spent',
          'MWK ${analytics.totalSpent.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildMetricCard(
          'Transactions',
          analytics.transactionCount.toString(),
          Icons.receipt,
          Colors.blue,
        ),
        _buildMetricCard(
          'Avg. Transaction',
          'MWK ${analytics.averageTransaction.toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildMetricCard(
          'Subscription Usage',
          '${(analytics.subscriptionUtilization * 100).toStringAsFixed(1)}%',
          Icons.subscriptions,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Risk Assessment',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: analytics.riskScore,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getRiskColor(analytics.riskScore),
          ),
        ),
      ],
    );
  }

  Widget _buildFraudDetectionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FRAUD DETECTION',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (analytics.fraudAlerts.isEmpty)
              const Center(
                child: Text(
                  'No suspicious activity detected',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: analytics.fraudAlerts.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.red.withOpacity(0.1),
                    child: ListTile(
                      leading: const Icon(
                        Icons.warning,
                        color: Colors.red,
                      ),
                      title: Text(
                        analytics.fraudAlerts[index],
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

  Widget _buildSpendingPatternsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SPENDING PATTERNS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryBreakdown(),
            const SizedBox(height: 16),
            _buildDailySpendingChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final categories = analytics.categoryBreakdown.keys.toList();
    final amounts = analytics.categoryBreakdown.values.toList();
    final total = amounts.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final percentage = (amounts[index] / total) * 100;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: _getCategoryColor(categories[index]).withOpacity(0.1),
                child: Icon(
                  _getCategoryIcon(categories[index]),
                  color: _getCategoryColor(categories[index]),
                ),
              ),
              title: Text(
                categories[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'MWK ${amounts[index].toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDailySpendingChart() {
    final dailySpending = analytics.spendingPatterns
        .firstWhere((p) => p['type'] == 'daily_spending')['data']
        as Map<String, double>;

    final dates = dailySpending.keys.toList();
    final amounts = dailySpending.values.toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= dates.length) return const Text('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dates[value.toInt()].split('-').last,
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
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                dates.length,
                (index) => FlSpot(index.toDouble(), amounts[index]),
              ),
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(double riskScore) {
    if (riskScore < 0.3) return Colors.green;
    if (riskScore < 0.7) return Colors.orange;
    return Colors.red;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Colors.blue;
      case 'dining':
        return Colors.green;
      case 'entertainment':
        return Colors.purple;
      case 'utilities':
        return Colors.orange;
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

class AdvancedAnalyticsStream extends StatelessWidget {
  final AdvancedAnalyticsService analyticsService;
  final bool showDetails;

  const AdvancedAnalyticsStream({
    super.key,
    required this.analyticsService,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserAnalytics>(
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

        return AdvancedAnalyticsWidget(
          analytics: snapshot.data!,
          showDetails: showDetails,
        );
      },
    );
  }
} 