import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import '../../services/behavioral_security_service.dart';
import '../../widgets/security_notification_widget.dart';

class BiometricAuthScreen extends StatefulWidget {
  final Function(bool) onAuthenticationComplete;
  final Function() onFallbackRequested;

  const BiometricAuthScreen({
    super.key,
    required this.onAuthenticationComplete,
    required this.onFallbackRequested,
  });

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final BehavioralSecurityService _securityService = BehavioralSecurityService();
  
  bool _isAuthenticating = false;
  bool _showFallback = false;
  String _statusMessage = 'Verifying your identity...';
  final List<SecurityAlert> _securityAlerts = [];

  @override
  void initState() {
    super.initState();
    _initializeBiometrics();
    _setupSecurityAlerts();
  }

  Future<void> _initializeBiometrics() async {
    final canAuthenticate = await _localAuth.canCheckBiometrics;
    if (!canAuthenticate) {
      setState(() {
        _statusMessage = 'Biometric authentication not available';
        _showFallback = true;
      });
      return;
    }

    final availableBiometrics = await _localAuth.getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      setState(() {
        _statusMessage = 'No biometric methods configured';
        _showFallback = true;
      });
      return;
    }

    _startAuthentication();
  }

  void _setupSecurityAlerts() {
    _securityService.securityAlerts.listen((alert) {
      setState(() {
        _securityAlerts.add(alert);
      });
    });
  }

  Future<void> _startAuthentication() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Verifying your identity...';
    });

    try {
      final result = await _securityService.authenticateWithBiometrics();
      
      if (result.success) {
        // Simulate liveness detection
        await _performLivenessDetection();
        
        setState(() {
          _statusMessage = 'Authentication successful!';
        });
        
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onAuthenticationComplete(true);
      } else {
        setState(() {
          _statusMessage = result.error ?? 'Authentication failed';
          _showFallback = true;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'An error occurred: $e';
        _showFallback = true;
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  Future<void> _performLivenessDetection() async {
    // Simulate AI-based liveness detection
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real implementation, this would:
    // 1. Capture multiple frames
    // 2. Analyze for signs of life (blinking, micro-movements)
    // 3. Check for spoofing attempts
    // 4. Return a confidence score
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
                        // Logo/Icon
                        Icon(
                          Icons.fingerprint,
                          size: 120,
                          color: Colors.white.withOpacity(0.8),
                        )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .shimmer(
                              duration: const Duration(seconds: 2),
                              color: Colors.white.withOpacity(0.2),
                            ),
                        
                        const SizedBox(height: 32),
                        
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
                        
                        const SizedBox(height: 24),
                        
                        // Authentication button
                        if (!_isAuthenticating && !_showFallback)
                          ElevatedButton(
                            onPressed: _startAuthentication,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Authenticate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: const Duration(milliseconds: 500))
                              .slideY(begin: 0.2, end: 0),
                        
                        // Fallback option
                        if (_showFallback)
                          TextButton(
                            onPressed: widget.onFallbackRequested,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Use PIN instead'),
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