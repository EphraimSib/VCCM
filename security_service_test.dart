import 'package:flutter_test/flutter_test.dart';
import 'package:encrypt/encrypt.dart';
import 'security_service.dart';

void main() {
  late SecurityService securityService;
  // Use the same IV as in SecurityService for testing
  const testIvKey = '1234567890abcdef';

  setUp(() {
    securityService = SecurityService();
  });

  test('Encryption and decryption should work', () {
    const plainText = 'SensitiveData123';
    final iv = IV.fromUtf8(testIvKey);
    final encrypted = securityService.encrypter.encrypt(plainText, iv: iv);
    final decrypted = securityService.encrypter.decrypt(encrypted, iv: iv);
    expect(decrypted, plainText);
  });
}