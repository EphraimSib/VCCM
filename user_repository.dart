import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vccm/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> updateUserSubscription(String uid, bool status) async {
    await _firestore.collection('users').doc(uid).update({
      'isSubscribed': status,
      'subscriptionExpiry': DateTime.now().add(const Duration(days: 365)),
    });
  }
}