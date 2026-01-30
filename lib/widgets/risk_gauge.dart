import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/theme.dart';

class RiskGauge extends StatelessWidget {
  final double riskScore;
  final String riskLevel;
  final List<String> riskFactors;

  const RiskGauge({
    super.key,
    required this.riskScore,
    required this.riskLevel,
    this.riskFactors = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gauge
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background arc
                CustomPaint(
                  size: const Size(200, 100),
                  painter: _GaugePainter(
                    percentage: riskScore / 100,
                    backgroundColor: Colors.grey.shade200,
                    progressColor: _getRiskColor(),
                  ),
                ),
                // Score in center
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      '${riskScore.toInt()}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getRiskColor(),
                      ),
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRiskColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        riskLevel.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _getRiskColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Risk labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low', style: TextStyle(color: AppTheme.riskLow, fontWeight: FontWeight.w600)),
                Text('Medium', style: TextStyle(color: AppTheme.riskMedium, fontWeight: FontWeight.w600)),
                Text('High', style: TextStyle(color: AppTheme.riskHigh, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          
          // Risk factors
          if (riskFactors.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Risk Factors',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: riskFactors.map((factor) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRiskColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getRiskColor().withOpacity(0.3)),
                ),
                child: Text(
                  factor,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getRiskColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRiskColor() {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return AppTheme.riskLow;
      case 'medium':
        return AppTheme.riskMedium;
      case 'high':
        return AppTheme.riskHigh;
      default:
        return AppTheme.riskLow;
    }
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color backgroundColor;
  final Color progressColor;

  _GaugePainter({
    required this.percentage,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 20;
    
    // Background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );
    
    // Gradient for progress
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: [
        AppTheme.riskLow,
        AppTheme.riskMedium,
        AppTheme.riskHigh,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * percentage,
      false,
      progressPaint,
    );
    
    // Indicator dot
    final angle = math.pi + (math.pi * percentage);
    final dotX = center.dx + radius * math.cos(angle);
    final dotY = center.dy + radius * math.sin(angle);
    
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final dotBorderPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(Offset(dotX, dotY), 12, dotPaint);
    canvas.drawCircle(Offset(dotX, dotY), 12, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
