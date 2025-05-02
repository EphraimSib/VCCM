import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpendingGraphWidget extends StatefulWidget {
  const SpendingGraphWidget({super.key});

  @override
  State<SpendingGraphWidget> createState() => _SpendingGraphWidgetState();
}

class _SpendingGraphWidgetState extends State<SpendingGraphWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedIndex = -1;
  final List<double> _spendingData = [
    1200, 800, 1500, 1000, 2000, 1700, 900,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: SpendingGraphPainter(
                    data: _spendingData,
                    progress: _controller.value,
                    selectedIndex: _selectedIndex,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = DateTime.now().subtract(Duration(days: 6 - index));
        return GestureDetector(
          onTapDown: (_) => setState(() => _selectedIndex = index),
          onTapUp: (_) => setState(() => _selectedIndex = -1),
          onTapCancel: () => setState(() => _selectedIndex = -1),
          child: Text(
            '${day.day}/${day.month}',
            style: TextStyle(
              color: _selectedIndex == index ? Colors.green.shade300 : Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        );
      }),
    );
  }
}

class SpendingGraphPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final int selectedIndex;

  SpendingGraphPainter({
    required this.data,
    required this.progress,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = data.reduce(math.max);
    final width = size.width;
    final height = size.height;
    final segmentWidth = width / (data.length - 1);

    // Draw grid lines
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      final y = height - (height * i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        paint,
      );
    }

    // Draw graph line
    final linePaint = Paint()
      ..color = Colors.green.shade300
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final shadowPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = i * segmentWidth;
      final y = height - (data[i] / maxValue * height * progress);

      if (i == 0) {
        path.moveTo(x, y);
        shadowPath.moveTo(x, height);
        shadowPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        shadowPath.lineTo(x, y);
      }

      // Draw data point
      if (selectedIndex == i) {
        canvas.drawCircle(
          Offset(x, y),
          6,
          Paint()..color = Colors.green.shade300,
        );

        // Draw value popup
        _drawValuePopup(canvas, Offset(x, y), data[i]);
      }
    }

    shadowPath.lineTo(width, height);
    shadowPath.close();

    // Draw gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.green.shade300.withOpacity(0.3),
        Colors.green.shade300.withOpacity(0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, width, height),
      );

    canvas.drawPath(shadowPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  void _drawValuePopup(Canvas canvas, Offset position, double value) {
    const padding = 8.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: '\$${value.toStringAsFixed(0)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position.translate(0, -30),
        width: textPainter.width + padding * 2,
        height: textPainter.height + padding * 2,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(
      rect,
      Paint()..color = Colors.green.shade300,
    );

    textPainter.paint(
      canvas,
      position.translate(
        -(textPainter.width / 2),
        -(textPainter.height / 2) - 30,
      ),
    );
  }

  @override
  bool shouldRepaint(SpendingGraphPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      selectedIndex != oldDelegate.selectedIndex;
} 