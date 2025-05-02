import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vccm/utils/constants.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> processSubscription(String userId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'isSubscribed': true,
      'subscriptionExpiry': DateTime.now().add(const Duration(days: 365)),
      'lastPaymentDate': DateTime.now(),
    });
  }

  Future<bool> checkSubscriptionStatus(String userId) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(userId).get();
    final expiry = doc['subscriptionExpiry']?.toDate();
    return doc['isSubscribed'] == true && expiry != null && expiry.isAfter(DateTime.now());
  }

  Future<void> handleSubscriptionRenewal(String userId) async {
    final status = await checkSubscriptionStatus(userId);
    if (!status) {
      await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
        'isSubscribed': false,
      });
    }
  }
}