import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isAuthenticated = userProvider.isAuthenticated;

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        isAuthenticated ? '/dashboard' : '/login',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize app. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3D), // Dark navy background
      body: Stack(
        children: [
          _buildShimmerBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 48),
                if (_errorMessage != null) _buildErrorWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBackground() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ShimmerBackgroundPainter(
            progress: _controller.value,
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 160,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Credit cards stack
              Transform.translate(
                offset: const Offset(-10, -10),
                child: _buildCreditCard(Colors.green.shade300),
              ),
              Transform.translate(
                offset: const Offset(10, 10),
                child: _buildCreditCard(Colors.green.shade400),
              ),
            ],
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        ).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
        ),
        const SizedBox(height: 24),
        Text(
          'VCCM',
          style: TextStyle(
            color: Colors.green.shade300,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ).animate(
          delay: const Duration(milliseconds: 500),
        ).fadeIn(
          duration: const Duration(milliseconds: 800),
        ).slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOutCubic,
        ),
      ],
    );
  }

  Widget _buildCreditCard(Color color) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              width: 30,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _initializeApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green.shade300,
                ),
                child: const Text('Try Alternative Login'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(
          begin: 0.3,
          end: 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
  }
}

class ShimmerBackgroundPainter extends CustomPainter {
  final double progress;

  ShimmerBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.8;

    // Create a radial gradient for the shimmer effect
    final gradient = RadialGradient(
      colors: [
        Colors.green.shade300.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );

    // Animate the gradient position
    final rect = Rect.fromCircle(
      center: Offset(
        center.dx + math.cos(progress * 2 * math.pi) * radius * 0.2,
        center.dy + math.sin(progress * 2 * math.pi) * radius * 0.2,
      ),
      radius: radius,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(ShimmerBackgroundPainter oldDelegate) => true;
} 