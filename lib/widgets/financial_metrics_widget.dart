import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/fee_management_service.dart';

class FinancialMetricsWidget extends StatelessWidget {
  final FinancialMetrics metrics;
  final bool showDetails;

  const FinancialMetricsWidget({
    super.key,
    required this.metrics,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMetricsCard(),
        if (showDetails) ...[
          const SizedBox(height: 16),
          _buildRevenueAllocationCard(),
          const SizedBox(height: 16),
          _buildRecentTransactionsCard(),
        ],
      ],
    );
  }

  Widget _buildMetricsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildRevenueChart(),
            if (showDetails) ...[
              const SizedBox(height: 16),
              _buildCategoryBreakdown(),
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
            const Text(
              'FINANCIAL METRICS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total Revenue: \$${metrics.totalRevenue.toStringAsFixed(2)}',
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
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${metrics.recentTransactions.length} Transactions',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    final categories = metrics.categoryBreakdown.keys.toList();
    final amounts = metrics.categoryBreakdown.values.toList();

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
                      _formatCategoryName(categories[value.toInt()]),
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

  Widget _buildCategoryBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revenue Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.categoryBreakdown.length,
          itemBuilder: (context, index) {
            final category = metrics.categoryBreakdown.keys.elementAt(index);
            final amount = metrics.categoryBreakdown[category]!;
            final percentage = (amount / metrics.totalRevenue) * 100;
            
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
                _formatCategoryName(category),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '\$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRevenueAllocationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Allocation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    _buildPieSection(
                      'Operational Costs',
                      metrics.allocation.operationalCosts,
                      Colors.blue,
                    ),
                    _buildPieSection(
                      'Business Growth',
                      metrics.allocation.businessGrowth,
                      Colors.green,
                    ),
                    _buildPieSection(
                      'Reserve Fund',
                      metrics.allocation.reserveFund,
                      Colors.orange,
                    ),
                    _buildPieSection(
                      'Marketing',
                      metrics.allocation.marketing,
                      Colors.purple,
                    ),
                    _buildPieSection(
                      'R&D',
                      metrics.allocation.researchDevelopment,
                      Colors.red,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAllocationLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationLegend() {
    return Column(
      children: [
        _buildLegendItem('Operational Costs', Colors.blue, metrics.allocation.operationalCosts),
        _buildLegendItem('Business Growth', Colors.green, metrics.allocation.businessGrowth),
        _buildLegendItem('Reserve Fund', Colors.orange, metrics.allocation.reserveFund),
        _buildLegendItem('Marketing', Colors.purple, metrics.allocation.marketing),
        _buildLegendItem('R&D', Colors.red, metrics.allocation.researchDevelopment),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, double amount) {
    final percentage = (amount / metrics.allocation.total) * 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metrics.recentTransactions.length,
              itemBuilder: (context, index) {
                final transaction = metrics.recentTransactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTransactionColor(transaction['type']).withOpacity(0.1),
                      child: Icon(
                        _getTransactionIcon(transaction['type']),
                        color: _getTransactionColor(transaction['type']),
                      ),
                    ),
                    title: Text(
                      '\$${transaction['amount'].toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${transaction['type']} on ${transaction['timestamp'].toString().split(' ')[0]}',
                    ),
                    trailing: transaction['fee'] != null
                        ? Text(
                            'Fee: \$${transaction['fee'].toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.grey),
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieSection(String title, double value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '\$${value.toStringAsFixed(2)}',
      radius: 100,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  String _formatCategoryName(String category) {
    return category.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'subscription':
        return Colors.blue;
      case 'transaction_fees':
        return Colors.green;
      case 'withdrawal_fees':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'subscription':
        return Icons.subscriptions;
      case 'transaction_fees':
        return Icons.payment;
      case 'withdrawal_fees':
        return Icons.money_off;
      default:
        return Icons.category;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'withdrawal':
        return Colors.orange;
      case 'subscription':
        return Colors.blue;
      case 'transaction':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'withdrawal':
        return Icons.money_off;
      case 'subscription':
        return Icons.subscriptions;
      case 'transaction':
        return Icons.payment;
      default:
        return Icons.category;
    }
  }
}

class FinancialMetricsStream extends StatelessWidget {
  final FeeManagementService feeService;
  final bool showDetails;

  const FinancialMetricsStream({
    super.key,
    required this.feeService,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FinancialMetrics>(
      stream: feeService.metricsStream,
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

        return FinancialMetricsWidget(
          metrics: snapshot.data!,
          showDetails: showDetails,
        );
      },
    );
  }
} 