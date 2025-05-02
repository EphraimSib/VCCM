import 'package:flutter/foundation.dart';
import 'package:vccm/models/user_model.dart';
import 'package:vccm/user_repository.dart';
import 'package:vccm/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  UserModel? get user => _user;

  Future<bool> checkAuthStatus() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      _user = await _userRepository.getUserData(user.uid);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    _user = await _authService.signUpWithEmail(
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> purchaseSubscription() async {
    if (_user != null) {
      await _userRepository.updateUserSubscription(_user!.uid, true);
      _user = await _userRepository.getUserData(_user!.uid);
      notifyListeners();
    }
  }
}