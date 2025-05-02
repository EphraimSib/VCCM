import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/transaction_analytics_service.dart';

class PredictiveAnalyticsWidget extends StatefulWidget {
  final TransactionAnalytics analytics;
  final bool showDetails;

  const PredictiveAnalyticsWidget({
    super.key,
    required this.analytics,
    this.showDetails = false,
  });

  @override
  State<PredictiveAnalyticsWidget> createState() => _PredictiveAnalyticsWidgetState();
}

class _PredictiveAnalyticsWidgetState extends State<PredictiveAnalyticsWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<FlSpot> _predictedSpots = [];
  List<FlSpot> _historicalSpots = [];
  double _predictedTotal = 0.0;
  String _predictionInsight = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _initializeData();
    _animationController.forward();
  }

  void _initializeData() {
    final patterns = widget.analytics.patterns;
    if (patterns.isEmpty) return;

    // Sort patterns by timestamp
    patterns.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Prepare historical data
    _historicalSpots = patterns.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.amount,
      );
    }).toList();

    // Generate predictions
    _generatePredictions(patterns);
  }

  void _generatePredictions(List<TransactionPattern> patterns) {
    if (patterns.length < 3) return;

    // Calculate trend using linear regression
    final trend = _calculateTrend(patterns);
    
    // Generate predicted spots
    final lastIndex = patterns.length - 1;
    final lastAmount = patterns.last.amount;
    _predictedSpots = List.generate(3, (index) {
      final predictedAmount = lastAmount + trend * (index + 1);
      return FlSpot(
        (lastIndex + index + 1).toDouble(),
        predictedAmount,
      );
    });

    // Calculate predicted total
    _predictedTotal = _predictedSpots.map((spot) => spot.y).reduce((a, b) => a + b);

    // Generate prediction insight
    _predictionInsight = _generatePredictionInsight(trend, patterns);
  }

  double _calculateTrend(List<TransactionPattern> patterns) {
    final n = patterns.length;
    var sumX = 0.0;
    var sumY = 0.0;
    var sumXY = 0.0;
    var sumXX = 0.0;

    for (var i = 0; i < n; i++) {
      sumX += i.toDouble();
      sumY += patterns[i].amount;
      sumXY += i * patterns[i].amount;
      sumXX += i * i;
    }

    return (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  }

  String _generatePredictionInsight(double trend, List<TransactionPattern> patterns) {
    final avgAmount = patterns.map((p) => p.amount).reduce((a, b) => a + b) / patterns.length;
    final monthlyTotal = patterns
        .where((p) => p.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .map((p) => p.amount)
        .fold(0.0, (a, b) => a + b);

    if (trend > 0.1) {
      return 'Your spending is trending upward. At this rate, you may exceed your monthly average of \$${avgAmount.toStringAsFixed(2)}.';
    } else if (trend < -0.1) {
      return 'Your spending is trending downward. You\'re on track to stay below your monthly average of \$${avgAmount.toStringAsFixed(2)}.';
    } else {
      return 'Your spending is stable. Current monthly total: \$${monthlyTotal.toStringAsFixed(2)}.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_historicalSpots.isEmpty) {
      return const Center(
        child: Text('Insufficient data for predictions'),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildPredictionChart(),
            if (widget.showDetails) ...[
              const SizedBox(height: 16),
              _buildPredictionDetails(),
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
          'PREDICTIVE ANALYTICS',
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
            color: _getCategoryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Next 3 Transactions',
            style: TextStyle(
              color: _getCategoryColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionChart() {
    return SizedBox(
      height: 200,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // Historical data
                LineChartBarData(
                  spots: _historicalSpots,
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
                // Predicted data
                LineChartBarData(
                  spots: _predictedSpots,
                  isCurved: true,
                  color: _getCategoryColor().withOpacity(0.5),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: _getCategoryColor(),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  dashArray: [5, 5],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPredictionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prediction Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _predictionInsight,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPredictionCard(
              'Predicted Total',
              '\$${_predictedTotal.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
            _buildPredictionCard(
              'Average Change',
              '${(_predictedTotal / _historicalSpots.length).toStringAsFixed(2)}%',
              Icons.trending_up,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPredictionCard(String title, String value, IconData icon) {
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

  Color _getCategoryColor() {
    switch (widget.analytics.category.toLowerCase()) {
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
} 