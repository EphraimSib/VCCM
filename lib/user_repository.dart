import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';

class UserRepository {
  final AuthService _authService = AuthService();

  Future<UserModel?> getCurrentUser() async {
    // Stub implementation, replace with actual logic
    return null;
  }

  Future<UserModel?> signUpWithEmail(String email, String password) async {
    // Stub implementation, replace with actual logic
    return null;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    // Stub implementation, replace with actual logic
    return null;
  }

  Future<void> updateUserSubscription(String userId, String subscriptionId) async {
    // Stub implementation, replace with actual logic
    return;
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
