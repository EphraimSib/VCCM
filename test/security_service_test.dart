import 'package:flutter_test/flutter_test.dart';
import '../security_service.dart';
import 'utils/debug_reporter.dart';

void main() {
  late SecurityService securityService;

  setUp(() {
    securityService = SecurityService();
  });

  test('Encryption and decryption should work', () {
    const plainText = 'SensitiveData123';
    final encrypted = securityService.encrypter.encrypt(plainText);
    final decrypted = securityService.encrypter.decrypt(encrypted);
    try {
      expect(decrypted, plainText);
    } catch (e) {
      DebugReporter.reportIfCriticalFailure('Encryption and decryption should work', TestFailure(e.toString()));
      rethrow;
    }
  });
}
