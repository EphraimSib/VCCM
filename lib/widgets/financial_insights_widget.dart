import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FinancialInsightsWidget extends StatefulWidget {
  const FinancialInsightsWidget({super.key});

  @override
  State<FinancialInsightsWidget> createState() => _FinancialInsightsWidgetState();
}

class _FinancialInsightsWidgetState extends State<FinancialInsightsWidget> {
  final List<InsightCard> _insights = [
    InsightCard(
      title: 'Spending Pattern',
      description: 'Your restaurant spending is 15% higher than last month. Consider setting a dining budget.',
      icon: Icons.restaurant,
      color: Colors.orange,
      action: 'Set Budget',
    ),
    InsightCard(
      title: 'Savings Opportunity',
      description: 'Based on your income, you could save an extra \$300 monthly by optimizing subscriptions.',
      icon: Icons.savings,
      color: Colors.green,
      action: 'View Details',
    ),
    InsightCard(
      title: 'Investment Tip',
      description: 'Market conditions suggest diversifying your portfolio. Check our recommendations.',
      icon: Icons.trending_up,
      color: Colors.blue,
      action: 'Explore',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI Financial Insights',
                style: TextStyle(
                  color: Colors.white,
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
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.green.shade300,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Powered',
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _insights.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildInsightCard(_insights[index])
                .animate()
                .fadeIn(delay: Duration(milliseconds: 200 * index))
                .slideX(begin: 0.2, end: 0);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(InsightCard insight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  insight.icon,
                  color: insight.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                insight.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.description,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: insight.color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(insight.action),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InsightCard {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String action;

  InsightCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.action,
  });
} 