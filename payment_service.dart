import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:http/http.dart' as http;
import 'package:vccm/utils/constants.dart';

class MobileMoneyService {
  final Encrypter _encrypter;
  static const _tnmBaseUrl = 'https://api.tnmmobilemoney.com/v1';
  static const _airtelBaseUrl = 'https://api.airtelmoney.com/v1';

  MobileMoneyService(this._encrypter);

  Future<String> _encryptData(String data) async {
    final iv = IV.fromLength(16);
    final encrypted = _encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  Future<Map<String, dynamic>> depositViaTnmMpamba({
    required double amount,
    required String phoneNumber,
  }) async {
    try {
      final encryptedPhone = await _encryptData(phoneNumber);
      final encryptedAmount = await _encryptData(amount.toString());

      final response = await http.post(
        Uri.parse('$_tnmBaseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.tnmApiKey}'
        },
        body: jsonEncode({
          'phone': encryptedPhone,
          'amount': encryptedAmount,
          'currency': 'MWK'
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Deposit failed: ${response.body}');
    } catch (e) {
      throw Exception('Deposit error: $e');
    }
  }

  // Similar implementation for Airtel Money
}