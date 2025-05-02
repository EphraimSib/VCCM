import 'package:flutter/material.dart';
import '../services/premium_analytics_service.dart';

class PremiumFeaturesWidget extends StatelessWidget {
  final PremiumAnalyticsService premiumService;
  final String userId;
  final bool showDetails;

  const PremiumFeaturesWidget({
    super.key,
    required this.premiumService,
    required this.userId,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSubscriptionTiers(),
        if (showDetails) ...[
          const SizedBox(height: 16),
          _buildPredictiveAlerts(),
          const SizedBox(height: 16),
          _buildCrossBorderTransactions(),
          const SizedBox(height: 16),
          _buildRecommendations(),
        ],
      ],
    );
  }

  Widget _buildSubscriptionTiers() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SUBSCRIPTION TIERS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...SubscriptionTier.values.map((tier) => _buildTierCard(tier)),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(SubscriptionTier tier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTierColor(tier).withOpacity(0.1),
          child: Icon(
            _getTierIcon(tier),
            color: _getTierColor(tier),
          ),
        ),
        title: Text(
          tier.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'MWK ${tier.price.toStringAsFixed(2)}/month',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: ElevatedButton(
          onPressed: () => premiumService.setUserTier(userId, tier),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getTierColor(tier),
          ),
          child: const Text('SELECT'),
        ),
      ),
    );
  }

  Widget _buildPredictiveAlerts() {
    return StreamBuilder<List<PredictiveAlert>>(
      stream: premiumService.alertsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final alerts = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PREDICTIVE ALERTS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (alerts.isEmpty)
                  const Center(
                    child: Text(
                      'No alerts detected',
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
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: _getAlertColor(alerts[index].type).withOpacity(0.1),
                        child: ListTile(
                          leading: Icon(
                            _getAlertIcon(alerts[index].type),
                            color: _getAlertColor(alerts[index].type),
                          ),
                          title: Text(
                            alerts[index].message,
                            style: TextStyle(
                              color: _getAlertColor(alerts[index].type),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Confidence: ${(alerts[index].confidence * 100).toStringAsFixed(1)}%',
                          ),
                          trailing: Text(
                            _formatTimestamp(alerts[index].timestamp),
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

  Widget _buildCrossBorderTransactions() {
    return StreamBuilder<List<CrossBorderTransaction>>(
      stream: premiumService.transactionsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CROSS-BORDER TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (transactions.isEmpty)
                  const Center(
                    child: Text(
                      'No cross-border transactions',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: const Icon(
                              Icons.currency_exchange,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            '${transaction.fromCurrency.symbol} → ${transaction.toCurrency.symbol}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount: ${transaction.amount.toStringAsFixed(2)} ${transaction.toCurrency.symbol}',
                              ),
                              Text(
                                'Fee: ${transaction.fee.toStringAsFixed(2)} ${transaction.toCurrency.symbol}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Text(
                            _formatTimestamp(transaction.timestamp),
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

  Widget _buildRecommendations() {
    return StreamBuilder<List<String>>(
      stream: premiumService.recommendationsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final recommendations = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SMART RECOMMENDATIONS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (recommendations.isEmpty)
                  const Center(
                    child: Text(
                      'No recommendations available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.green.withOpacity(0.1),
                        child: ListTile(
                          leading: const Icon(
                            Icons.lightbulb,
                            color: Colors.green,
                          ),
                          title: Text(
                            recommendations[index],
                            style: const TextStyle(
                              color: Colors.green,
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
      },
    );
  }

  Color _getTierColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic:
        return Colors.grey;
      case SubscriptionTier.premium:
        return Colors.blue;
      case SubscriptionTier.enterprise:
        return Colors.purple;
    }
  }

  IconData _getTierIcon(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic:
        return Icons.star_border;
      case SubscriptionTier.premium:
        return Icons.star_half;
      case SubscriptionTier.enterprise:
        return Icons.star;
    }
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'spending_alert':
        return Colors.orange;
      case 'currency_risk':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'spending_alert':
        return Icons.warning;
      case 'currency_risk':
        return Icons.currency_exchange;
      default:
        return Icons.info;
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
} 