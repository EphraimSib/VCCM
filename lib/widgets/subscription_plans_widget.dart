import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../services/fee_management_service.dart';

class SubscriptionPlansWidget extends StatelessWidget {
  final String userId;
  final SubscriptionService subscriptionService;
  final FeeManagementService feeService;

  const SubscriptionPlansWidget({
    super.key,
    required this.userId,
    required this.subscriptionService,
    required this.feeService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Subscription>(
      stream: subscriptionService.subscriptionStream,
      builder: (context, snapshot) {
        final currentSubscription = subscriptionService.getSubscription(userId);
        final isActive = subscriptionService.isSubscriptionActive(userId);

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(currentSubscription, isActive),
                const SizedBox(height: 16),
                _buildPlanCards(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Subscription? subscription, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SUBSCRIPTION PLANS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isActive
                  ? 'Current Plan: ${subscription?.plan.name}'
                  : 'No Active Subscription',
              style: TextStyle(
                fontSize: 16,
                color: isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        if (isActive)
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
              'Active until ${subscription?.endDate.toString().split(' ')[0]}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlanCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPlanCard(
            context,
            SubscriptionPlan.monthly,
            'Monthly Plan',
            'Perfect for short-term users',
            Icons.calendar_today,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPlanCard(
            context,
            SubscriptionPlan.annual,
            'Annual Plan',
            'Best value for long-term users',
            Icons.calendar_month,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlan plan,
    String title,
    String description,
    IconData icon,
  ) {
    final isCurrentPlan = subscriptionService.getSubscription(userId)?.plan == plan;
    final isActive = subscriptionService.isSubscriptionActive(userId);

    return Card(
      elevation: 2,
      color: isCurrentPlan && isActive
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
      child: InkWell(
        onTap: () => _handlePlanSelection(context, plan),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'MWK ${plan.amount}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              if (isCurrentPlan && isActive)
                ElevatedButton(
                  onPressed: () => _handleCancelSubscription(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Cancel Subscription'),
                )
              else
                ElevatedButton(
                  onPressed: () => _handlePlanSelection(context, plan),
                  child: Text(
                    isCurrentPlan ? 'Renew Plan' : 'Subscribe Now',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlanSelection(
    BuildContext context,
    SubscriptionPlan plan,
  ) async {
    try {
      await feeService.processSubscription(userId, plan);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully subscribed to ${plan.name} plan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCancelSubscription(BuildContext context) async {
    try {
      await subscriptionService.cancelSubscription(userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 