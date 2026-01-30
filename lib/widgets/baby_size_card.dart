import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BabySizeCard extends StatelessWidget {
  final int currentWeek;
  final String babySizeComparison;
  final int daysRemaining;
  final double progressPercentage;
  final String trimesterName;

  const BabySizeCard({
    super.key,
    required this.currentWeek,
    required this.babySizeComparison,
    required this.daysRemaining,
    required this.progressPercentage,
    required this.trimesterName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.pregnancyGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(_getBabyEmoji(), style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week $currentWeek',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Baby is the size of a',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    Text(
                      babySizeComparison,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(trimesterName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
              Text('$daysRemaining days to go!', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  String _getBabyEmoji() {
    if (currentWeek <= 12) return '🫘';
    if (currentWeek <= 20) return '🍋';
    if (currentWeek <= 30) return '🥒';
    return '🍉';
  }
}
