import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'behavioral_security_service.dart';
import 'session_manager.dart';

class AuthManager {
  static const String _PIN_HASH_KEY = 'pin_hash';
  static const String _LAST_AUTH_TIME_KEY = 'last_auth_time';
  static const String _AUTH_METHOD_KEY = 'auth_method';
  static const Duration _AUTH_TIMEOUT = Duration(minutes: 30);
  
  final BehavioralSecurityService _securityService = BehavioralSecurityService();
  final SessionManager _sessionManager = SessionManager();
  final StreamController<AuthState> _authStateController = 
      StreamController<AuthState>.broadcast();
  
  Stream<AuthState> get authState => _authStateController.stream;
  
  AuthMethod _preferredMethod = AuthMethod.biometric;
  DateTime? _lastAuthTime;
  bool _isAuthenticated = false;

  Future<void> initialize() async {
    await _loadAuthPreferences();
    await _sessionManager.initialize();
  }

  Future<void> _loadAuthPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    _lastAuthTime = DateTime.tryParse(
      prefs.getString(_LAST_AUTH_TIME_KEY) ?? '',
    );
    
    _preferredMethod = AuthMethod.values.firstWhere(
      (method) => method.toString() == prefs.getString(_AUTH_METHOD_KEY),
      orElse: () => AuthMethod.biometric,
    );
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!_isAuthRequired()) {
      _isAuthenticated = true;
      _authStateController.add(AuthState.authenticated);
      return true;
    }

    final result = await _securityService.authenticateWithBiometrics();
    if (result.success) {
      await _handleSuccessfulAuth();
      return true;
    }
    return false;
  }

  Future<bool> authenticateWithPin(String pin) async {
    if (!_isAuthRequired()) {
      _isAuthenticated = true;
      _authStateController.add(AuthState.authenticated);
      return true;
    }

    final storedHash = await _getStoredPinHash();
    if (storedHash == null) {
      // First-time PIN setup
      await _storePinHash(pin);
      await _handleSuccessfulAuth();
      return true;
    }

    final enteredHash = _hashPin(pin);
    if (enteredHash == storedHash) {
      await _handleSuccessfulAuth();
      return true;
    }

    return false;
  }

  Future<void> _handleSuccessfulAuth() async {
    _isAuthenticated = true;
    _lastAuthTime = DateTime.now();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _LAST_AUTH_TIME_KEY,
      _lastAuthTime!.toIso8601String(),
    );

    _authStateController.add(AuthState.authenticated);
  }

  bool _isAuthRequired() {
    if (!_isAuthenticated) return true;
    
    if (_lastAuthTime == null) return true;
    
    final now = DateTime.now();
    return now.difference(_lastAuthTime!) > _AUTH_TIMEOUT;
  }

  Future<String?> _getStoredPinHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_PIN_HASH_KEY);
  }

  Future<void> _storePinHash(String pin) async {
    final hash = _hashPin(pin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_PIN_HASH_KEY, hash);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> setPreferredAuthMethod(AuthMethod method) async {
    _preferredMethod = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_AUTH_METHOD_KEY, method.toString());
  }

  AuthMethod get preferredAuthMethod => _preferredMethod;

  Future<void> logout() async {
    _isAuthenticated = false;
    _lastAuthTime = null;
    await _sessionManager.endSession();
    _authStateController.add(AuthState.unauthenticated);
  }

  void dispose() {
    _authStateController.close();
    _sessionManager.dispose();
  }
}

enum AuthState {
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

enum AuthMethod {
  biometric,
  pin,
} 