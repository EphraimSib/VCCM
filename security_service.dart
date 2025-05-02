import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SecurityService {
  static const _key = '1234567890abcdef1234567890abcdef'; // 32-character key
  static const _ivKey = '1234567890abcdef'; // 16-character IV
  final _storage = const FlutterSecureStorage();

  Encrypter get encrypter => Encrypter(AES(Key.fromUtf8(_key)));

  Future<void> storeCredentials(String key, String value) async {
    final iv = IV.fromUtf8(_ivKey);
    final encrypted = encrypter.encrypt(value, iv: iv);
    await _storage.write(key: key, value: encrypted.base64);
  }

  Future<String?> getCredentials(String key) async {
    final encryptedValue = await _storage.read(key: key);
    if (encryptedValue == null) return null;
    final iv = IV.fromUtf8(_ivKey);
    return encrypter.decrypt64(encryptedValue, iv: iv);
  }

  // AI Fraud Detection Integration
  Future<String> classifyTransactionRisk(Map<String, dynamic> transactionData) async {
    // Replace with your AI fraud detection API endpoint
    final url = Uri.parse('http://localhost:5000/api/classify_risk');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transactionData),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['riskLevel']; // Expected to be one of: Safe, Medium, High, Critical
    } else {
      throw Exception('Failed to classify transaction risk');
    }
  }

  // Blockchain Security Logging (Placeholder)
  Future<void> logSecurityEvent(String eventDescription) async {
    // Placeholder for blockchain logging integration
    // In real implementation, interact with smart contract to log event
    print('Logging security event to blockchain: $eventDescription');
  }
}
