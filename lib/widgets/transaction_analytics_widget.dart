import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/transaction_analytics_service.dart';
import 'predictive_analytics_widget.dart';

class TransactionAnalyticsWidget extends StatelessWidget {
  final TransactionAnalytics analytics;
  final bool showDetails;

  const TransactionAnalyticsWidget({
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
          PredictiveAnalyticsWidget(
            analytics: analytics,
            showDetails: true,
          ),
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
            _buildTrendChart(),
            if (showDetails) ...[
              const SizedBox(height: 16),
              _buildMetricsGrid(),
              const SizedBox(height: 16),
              _buildInsights(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              analytics.category.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total: \$${analytics.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _getCategoryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${analytics.transactionCount} transactions',
            style: TextStyle(
              color: _getCategoryColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    final patterns = analytics.patterns;
    if (patterns.isEmpty) {
      return const SizedBox.shrink();
    }

    patterns.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final spots = patterns.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.amount,
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: _getCategoryColor(),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: _getCategoryColor().withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final trend = analytics.insights['trend'] as Map<String, dynamic>;
    final frequency = analytics.insights['frequency'] as Map<String, dynamic>;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Average Amount',
          '\$${analytics.averageAmount.toStringAsFixed(2)}',
          Icons.attach_money,
        ),
        _buildMetricCard(
          'Trend',
          trend['direction'] ?? 'N/A',
          Icons.trending_up,
        ),
        _buildMetricCard(
          'Most Active Day',
          frequency['mostActiveDay'] ?? 'N/A',
          Icons.calendar_today,
        ),
        _buildMetricCard(
          'Peak Time',
          frequency['mostActiveTime'] ?? 'N/A',
          Icons.access_time,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _getCategoryColor(),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    final anomalies = analytics.insights['anomalies'] as List<Map<String, dynamic>>;
    if (anomalies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unusual Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: anomalies.length,
          itemBuilder: (context, index) {
            final anomaly = anomalies[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                '\$${anomaly['amount'].toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'on ${DateTime.parse(anomaly['timestamp']).toString().split(' ')[0]}',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    final recommendations = analytics.insights['recommendations'] as List<String>;
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: _getCategoryColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(recommendations[index]),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (analytics.category.toLowerCase()) {
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
}

class TransactionAnalyticsStream extends StatelessWidget {
  final TransactionAnalyticsService analyticsService;
  final bool showDetails;

  const TransactionAnalyticsStream({
    super.key,
    required this.analyticsService,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TransactionAnalytics>(
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

        return TransactionAnalyticsWidget(
          analytics: snapshot.data!,
          showDetails: showDetails,
        );
      },
    );
  }
} 