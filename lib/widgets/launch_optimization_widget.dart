import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/launch_optimization_service.dart';

class LaunchOptimizationWidget extends StatelessWidget {
  final LaunchOptimizationService optimizationService;
  final bool showDetails;

  const LaunchOptimizationWidget({
    super.key,
    required this.optimizationService,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLaunchStatus(),
        const SizedBox(height: 16),
        _buildPerformanceMetrics(),
        if (showDetails) ...[
          const SizedBox(height: 16),
          _buildScalabilityInsights(),
          const SizedBox(height: 16),
          _buildSecurityReports(),
          const SizedBox(height: 16),
          _buildBetaFeedback(),
        ],
      ],
    );
  }

  Widget _buildLaunchStatus() {
    return StreamBuilder<LaunchStatus>(
      stream: optimizationService.statusStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final status = snapshot.data!;
        return Card(
          elevation: 4,
          color: _getLaunchStatusColor(status).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  _getLaunchStatusIcon(status),
                  size: 32,
                  color: _getLaunchStatusColor(status),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LAUNCH STATUS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getLaunchStatusColor(status),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLaunchStatusMessage(status),
                        style: TextStyle(
                          color: _getLaunchStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScalabilityInsights() {
    return StreamBuilder<ScalabilityInsight>(
      stream: optimizationService.scalabilityStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final insight = snapshot.data!;
        final loadPercentage = (insight.currentLoad / 100).clamp(0.0, 1.0);
        final projectedPercentage = (insight.projectedLoad / 100).clamp(0.0, 1.0);

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SCALABILITY INSIGHTS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Load (${insight.currentLoad.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: loadPercentage,
                            backgroundColor: Colors.grey[200],
                            color: _getLoadColor(insight.currentLoad),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Projected Load (${insight.projectedLoad.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: projectedPercentage,
                            backgroundColor: Colors.grey[200],
                            color: _getLoadColor(insight.projectedLoad),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.recommendation,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceMetrics() {
    return StreamBuilder<List<PerformanceData>>(
      stream: optimizationService.performanceStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final metrics = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PERFORMANCE METRICS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPerformanceChart(context, metrics),
                const SizedBox(height: 16),
                _buildMetricsGrid(metrics),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceChart(BuildContext context, List<PerformanceData> metrics) {
    final responseTimes = metrics
        .where((m) => m.metric == PerformanceMetric.responseTime)
        .map((m) => m.value)
        .toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(0)}ms',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
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
                responseTimes.length,
                (index) => FlSpot(index.toDouble(), responseTimes[index]),
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

  Widget _buildMetricsGrid(List<PerformanceData> metrics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Response Time',
          '${metrics.firstWhere((m) => m.metric == PerformanceMetric.responseTime).value.toStringAsFixed(1)}ms',
          Icons.speed,
          Colors.blue,
        ),
        _buildMetricCard(
          'Throughput',
          '${metrics.firstWhere((m) => m.metric == PerformanceMetric.transactionThroughput).value.toStringAsFixed(0)} tps',
          Icons.trending_up,
          Colors.green,
        ),
        _buildMetricCard(
          'Error Rate',
          '${(metrics.firstWhere((m) => m.metric == PerformanceMetric.errorRate).value * 100).toStringAsFixed(1)}%',
          Icons.error,
          Colors.red,
        ),
        _buildMetricCard(
          'Resource Usage',
          '${metrics.firstWhere((m) => m.metric == PerformanceMetric.resourceUtilization).value.toStringAsFixed(1)}%',
          Icons.memory,
          Colors.orange,
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

  Widget _buildSecurityReports() {
    return StreamBuilder<List<SecurityReport>>(
      stream: optimizationService.securityStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SECURITY REPORTS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: _getSecurityColor(reports[index].score).withOpacity(0.1),
                      child: ListTile(
                        leading: Icon(
                          _getSecurityIcon(reports[index].test),
                          color: _getSecurityColor(reports[index].score),
                        ),
                        title: Text(
                          reports[index].test.name.toUpperCase(),
                          style: TextStyle(
                            color: _getSecurityColor(reports[index].score),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Score: ${(reports[index].score * 100).toStringAsFixed(1)}%',
                            ),
                            if (reports[index].vulnerabilities.isNotEmpty)
                              Text(
                                'Vulnerabilities: ${reports[index].vulnerabilities.join(', ')}',
                                style: const TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                        trailing: Text(
                          _formatTimestamp(reports[index].timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
      },
    );
  }

  Widget _buildBetaFeedback() {
    return StreamBuilder<List<BetaFeedback>>(
      stream: optimizationService.feedbackStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedback = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BETA FEEDBACK',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (feedback.isEmpty)
                  const Center(
                    child: Text(
                      'No feedback available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: feedback.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: _getRatingColor(feedback[index].rating).withOpacity(0.1),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getRatingColor(feedback[index].rating).withOpacity(0.2),
                            child: Icon(
                              _getRatingIcon(feedback[index].rating),
                              color: _getRatingColor(feedback[index].rating),
                            ),
                          ),
                          title: Text(
                            feedback[index].category,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(feedback[index].feedback),
                              Row(
                                children: List.generate(
                                  5,
                                  (starIndex) => Icon(
                                    starIndex < feedback[index].rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: _getRatingColor(feedback[index].rating),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            _formatTimestamp(feedback[index].timestamp),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
      },
    );
  }

  Color _getSecurityColor(double score) {
    if (score >= 0.9) return Colors.green;
    if (score >= 0.7) return Colors.orange;
    return Colors.red;
  }

  IconData _getSecurityIcon(SecurityTest test) {
    switch (test) {
      case SecurityTest.penetrationTest:
        return Icons.security;
      case SecurityTest.fraudDetection:
        return Icons.warning;
      case SecurityTest.dataEncryption:
        return Icons.lock;
      case SecurityTest.accessControl:
        return Icons.person;
      case SecurityTest.apiSecurity:
        return Icons.api;
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.red;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getRatingIcon(int rating) {
    switch (rating) {
      case 5:
        return Icons.sentiment_very_satisfied;
      case 4:
        return Icons.sentiment_satisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 1:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getLaunchStatusColor(LaunchStatus status) {
    switch (status) {
      case LaunchStatus.ready:
        return Colors.green;
      case LaunchStatus.needsOptimization:
        return Colors.orange;
      case LaunchStatus.criticalIssues:
        return Colors.red;
      case LaunchStatus.notReady:
        return Colors.grey;
    }
  }

  IconData _getLaunchStatusIcon(LaunchStatus status) {
    switch (status) {
      case LaunchStatus.ready:
        return Icons.check_circle;
      case LaunchStatus.needsOptimization:
        return Icons.warning;
      case LaunchStatus.criticalIssues:
        return Icons.error;
      case LaunchStatus.notReady:
        return Icons.hourglass_empty;
    }
  }

  String _getLaunchStatusMessage(LaunchStatus status) {
    switch (status) {
      case LaunchStatus.ready:
        return 'System is ready for launch';
      case LaunchStatus.needsOptimization:
        return 'Minor optimizations recommended';
      case LaunchStatus.criticalIssues:
        return 'Critical issues need attention';
      case LaunchStatus.notReady:
        return 'System not ready for launch';
    }
  }

  Color _getLoadColor(double load) {
    if (load >= 80) return Colors.red;
    if (load >= 60) return Colors.orange;
    return Colors.green;
  }
} 