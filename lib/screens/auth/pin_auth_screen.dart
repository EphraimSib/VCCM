import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/behavioral_security_service.dart';
import '../../widgets/security_notification_widget.dart';

class PinAuthScreen extends StatefulWidget {
  final Function(bool) onAuthenticationComplete;
  final Function() onBiometricRequested;

  const PinAuthScreen({
    super.key,
    required this.onAuthenticationComplete,
    required this.onBiometricRequested,
  });

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
  final TextEditingController _pinController = TextEditingController();
  final BehavioralSecurityService _securityService = BehavioralSecurityService();
  
  String _enteredPin = '';
  bool _isAuthenticating = false;
  String _statusMessage = 'Enter your PIN';
  final List<SecurityAlert> _securityAlerts = [];

  @override
  void initState() {
    super.initState();
    _setupSecurityAlerts();
  }

  void _setupSecurityAlerts() {
    _securityService.securityAlerts.listen((alert) {
      setState(() {
        _securityAlerts.add(alert);
      });
    });
  }

  void _onPinDigitEntered(String digit) {
    if (_enteredPin.length >= 6) return;

    setState(() {
      _enteredPin += digit;
      _statusMessage = 'Enter your PIN';
    });

    if (_enteredPin.length == 6) {
      _verifyPin();
    }
  }

  void _onPinDigitRemoved() {
    if (_enteredPin.isEmpty) return;

    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _statusMessage = 'Enter your PIN';
    });
  }

  Future<void> _verifyPin() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Verifying PIN...';
    });

    try {
      // Simulate PIN verification
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real implementation, this would:
      // 1. Hash the entered PIN
      // 2. Compare with stored hash
      // 3. Check for brute force attempts
      // 4. Update security metrics
      
      if (_enteredPin == '123456') { // Replace with actual verification
        setState(() {
          _statusMessage = 'PIN verified successfully!';
        });
        
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onAuthenticationComplete(true);
      } else {
        setState(() {
          _statusMessage = 'Incorrect PIN';
          _enteredPin = '';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'An error occurred: $e';
        _enteredPin = '';
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background animation
          _buildBackgroundAnimation(),
          
          // Main content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Security alerts
                if (_securityAlerts.isNotEmpty)
                  SecurityNotificationWidget(
                    alerts: _securityAlerts,
                    onAlertDismissed: (alert) {
                      setState(() {
                        _securityAlerts.remove(alert);
                      });
                    },
                    onAlertActionPressed: (alert) {
                      // Handle security alert actions
                    },
                  ),
                
                // Authentication UI
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status message
                        Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 500))
                            .slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 32),
                        
                        // PIN dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            return Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index < _enteredPin.length
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                              ),
                            );
                          }),
                        )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 500))
                            .slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 48),
                        
                        // Numeric keypad
                        _buildNumericKeypad(),
                        
                        const SizedBox(height: 24),
                        
                        // Biometric fallback
                        TextButton(
                          onPressed: widget.onBiometricRequested,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Use biometrics instead'),
                        )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 500))
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        for (var i = 1; i <= 9; i++)
          _buildKeypadButton(
            i.toString(),
            onPressed: () => _onPinDigitEntered(i.toString()),
          ),
        _buildKeypadButton(
          'Biometric',
          onPressed: widget.onBiometricRequested,
          icon: Icons.fingerprint,
        ),
        _buildKeypadButton(
          '0',
          onPressed: () => _onPinDigitEntered('0'),
        ),
        _buildKeypadButton(
          '⌫',
          onPressed: _onPinDigitRemoved,
          icon: Icons.backspace,
        ),
      ],
    );
  }

  Widget _buildKeypadButton(
    String label, {
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundAnimation() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900,
            Colors.purple.shade900,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _BackgroundPainter(),
        child: Container(),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw animated circles
    for (var i = 0; i < 5; i++) {
      final radius = size.width * 0.2 * (i + 1);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 