import 'dart:async';

enum SubscriptionPlan {
  monthly(amount: 1500, name: 'Monthly'),
  annual(amount: 5000, name: 'Annual');

  final int amount;
  final String name;
  const SubscriptionPlan({required this.amount, required this.name});
}

class Subscription {
  final String userId;
  final SubscriptionPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Subscription({
    required this.userId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });
}

class SubscriptionService {
  final _subscriptions = <String, Subscription>{};
  final _subscriptionController = StreamController<Subscription>.broadcast();
  
  Stream<Subscription> get subscriptionStream => _subscriptionController.stream;

  Future<void> subscribeUser(String userId, SubscriptionPlan plan) async {
    final now = DateTime.now();
    final endDate = plan == SubscriptionPlan.monthly
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(days: 365));

    final subscription = Subscription(
      userId: userId,
      plan: plan,
      startDate: now,
      endDate: endDate,
      isActive: true,
    );

    _subscriptions[userId] = subscription;
    _subscriptionController.add(subscription);
  }

  Future<void> cancelSubscription(String userId) async {
    if (_subscriptions.containsKey(userId)) {
      final subscription = _subscriptions[userId]!;
      _subscriptions[userId] = Subscription(
        userId: userId,
        plan: subscription.plan,
        startDate: subscription.startDate,
        endDate: subscription.endDate,
        isActive: false,
      );
      _subscriptionController.add(_subscriptions[userId]!);
    }
  }

  Subscription? getSubscription(String userId) {
    return _subscriptions[userId];
  }

  bool isSubscriptionActive(String userId) {
    final subscription = _subscriptions[userId];
    if (subscription == null) return false;
    return subscription.isActive && DateTime.now().isBefore(subscription.endDate);
  }

  void dispose() {
    _subscriptionController.close();
  }
} 