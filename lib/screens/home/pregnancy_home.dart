import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/user_provider.dart';
import '../../providers/pregnancy_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/risk_gauge.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/vitals_card.dart';
import '../../widgets/baby_size_card.dart';
import '../../widgets/gamification_widgets.dart';

class PregnancyHome extends StatelessWidget {
  const PregnancyHome({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final pregnancyProvider = context.watch<PregnancyProvider>();
    final gamificationProvider = context.watch<GamificationProvider>();
    final user = userProvider.user;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.name ?? 'Mama'} 💕',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                          const SizedBox(height: 4),
                          Text(
                            'Week ${pregnancyProvider.currentWeek} of 40',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Streak Counter
                    StreakWidget(
                      currentStreak: gamificationProvider.currentStreak,
                      isCompact: true,
                    ).animate().fadeIn(delay: 150.ms).scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(width: 8),
                    _buildModeToggle(context, userProvider),
                  ],
                ),
              ),
            ),

            // Baby Size & Progress Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BabySizeCard(
                  currentWeek: pregnancyProvider.currentWeek,
                  babySizeComparison: pregnancyProvider.babySizeComparison,
                  daysRemaining: pregnancyProvider.daysRemaining,
                  progressPercentage: pregnancyProvider.progressPercentage,
                  trimesterName: pregnancyProvider.trimesterName,
                ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Risk Assessment
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Assessment',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),
                    RiskGauge(
                      riskScore: pregnancyProvider.riskScore,
                      riskLevel: pregnancyProvider.riskLevel,
                      riskFactors: pregnancyProvider.pregnancy?.riskFactors ?? [],
                    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.95, 0.95)),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionCard(
                            icon: Iconsax.heart,
                            label: 'Log BP',
                            color: AppTheme.primaryPink,
                            onTap: () => _showBPLogger(context, pregnancyProvider),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickActionCard(
                            icon: Iconsax.weight,
                            label: 'Log Weight',
                            color: AppTheme.primaryTeal,
                            onTap: () => _showWeightLogger(context, pregnancyProvider),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionCard(
                            icon: Iconsax.lovely,
                            label: 'Count Kicks',
                            color: AppTheme.lavender,
                            onTap: () => _showKickCounter(context, pregnancyProvider),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickActionCard(
                            icon: Iconsax.timer,
                            label: 'Contractions',
                            color: AppTheme.warning,
                            onTap: () => _showContractionTimer(context, pregnancyProvider),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Latest Vitals
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Vitals',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 900.ms),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: VitalsCard(
                            icon: Iconsax.heart,
                            label: 'Blood Pressure',
                            value: pregnancyProvider.latestBP?.displayValue ?? '--/--',
                            status: pregnancyProvider.latestBP?.bpCategory ?? 'No data',
                            color: pregnancyProvider.latestBP?.isHighBP == true 
                                ? AppTheme.error 
                                : AppTheme.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: VitalsCard(
                            icon: Iconsax.weight,
                            label: 'Weight',
                            value: pregnancyProvider.latestWeight?.displayValue ?? '--',
                            status: 'Last logged',
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1000.ms),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Daily Tip
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.pregnancyGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Iconsax.lamp_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Week ${pregnancyProvider.currentWeek} Tip',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getWeeklyTip(pregnancyProvider.currentWeek),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.1),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Gamification Summary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 1150.ms),
                    const SizedBox(height: 16),
                    GamificationSummaryCard(
                      streak: gamificationProvider.currentStreak,
                      level: gamificationProvider.level,
                      levelTitle: gamificationProvider.levelTitle,
                      points: gamificationProvider.totalPoints,
                      recentBadges: gamificationProvider.recentBadges,
                    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Emergency Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () => _showEmergencySheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Iconsax.warning_2),
                  label: const Text('Emergency Help'),
                ).animate().fadeIn(delay: 1200.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context, UserProvider userProvider) {
    return GestureDetector(
      onTap: () => _showModeConfirmation(context, userProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppTheme.pregnancyGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPink.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.lovely, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Pregnant',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  void _showModeConfirmation(BuildContext context, UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Switch to Fertility Mode?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your pregnancy data will be saved.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      userProvider.switchToFertilityMode();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Switch'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getWeeklyTip(int week) {
    if (week <= 12) {
      return 'First trimester! Rest when needed and take your prenatal vitamins daily.';
    } else if (week <= 27) {
      return 'Second trimester energy boost! Great time for gentle exercise and nursery planning.';
    } else if (week <= 36) {
      return 'Third trimester! Start packing your hospital bag and practicing breathing exercises.';
    } else {
      return 'Almost there! Watch for signs of labor and rest as much as possible.';
    }
  }

  void _showBPLogger(BuildContext context, PregnancyProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BPLoggerSheet(provider: provider),
    );
  }

  void _showWeightLogger(BuildContext context, PregnancyProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WeightLoggerSheet(provider: provider),
    );
  }

  void _showKickCounter(BuildContext context, PregnancyProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _KickCounterSheet(provider: provider),
    );
  }

  void _showContractionTimer(BuildContext context, PregnancyProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContractionTimerSheet(provider: provider),
    );
  }

  void _showEmergencySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.warning_2,
                size: 40,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Emergency Help',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEmergencyButton(context, 'Call Emergency (911)', Iconsax.call, AppTheme.error),
            const SizedBox(height: 12),
            _buildEmergencyButton(context, 'Call My Doctor', Iconsax.user, AppTheme.primaryPink),
            const SizedBox(height: 12),
            _buildEmergencyButton(context, 'Find Nearest Hospital', Iconsax.location, AppTheme.primaryTeal),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context, String label, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label - Demo mode')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

// BP Logger Sheet
class _BPLoggerSheet extends StatefulWidget {
  final PregnancyProvider provider;
  const _BPLoggerSheet({required this.provider});

  @override
  State<_BPLoggerSheet> createState() => _BPLoggerSheetState();
}

class _BPLoggerSheetState extends State<_BPLoggerSheet> {
  double systolic = 120;
  double diastolic = 80;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Iconsax.heart, size: 40, color: AppTheme.primaryPink),
          const SizedBox(height: 16),
          Text(
            'Log Blood Pressure',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('Systolic', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(
                      '${systolic.toInt()}',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: systolic,
                      min: 70,
                      max: 200,
                      activeColor: AppTheme.primaryPink,
                      onChanged: (v) => setState(() => systolic = v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Diastolic', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(
                      '${diastolic.toInt()}',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: diastolic,
                      min: 40,
                      max: 120,
                      activeColor: AppTheme.primaryTeal,
                      onChanged: (v) => setState(() => diastolic = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.provider.logBloodPressure(systolic, diastolic);
              context.read<GamificationProvider>().recordLog(LogType.vitals);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Blood pressure logged! ✓')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Weight Logger Sheet
class _WeightLoggerSheet extends StatefulWidget {
  final PregnancyProvider provider;
  const _WeightLoggerSheet({required this.provider});

  @override
  State<_WeightLoggerSheet> createState() => _WeightLoggerSheetState();
}

class _WeightLoggerSheetState extends State<_WeightLoggerSheet> {
  double weight = 65;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Iconsax.weight, size: 40, color: AppTheme.primaryTeal),
          const SizedBox(height: 16),
          Text(
            'Log Weight',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${weight.toStringAsFixed(1)} kg',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.primaryTeal,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: weight,
            min: 40,
            max: 150,
            activeColor: AppTheme.primaryTeal,
            onChanged: (v) => setState(() => weight = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.provider.logWeight(weight);
              context.read<GamificationProvider>().recordLog(LogType.vitals);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Weight logged! ✓')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Kick Counter Sheet
class _KickCounterSheet extends StatefulWidget {
  final PregnancyProvider provider;
  const _KickCounterSheet({required this.provider});

  @override
  State<_KickCounterSheet> createState() => _KickCounterSheetState();
}

class _KickCounterSheetState extends State<_KickCounterSheet> {
  int kickCount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Kick Counter 👶',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart when baby kicks',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => setState(() => kickCount++),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: AppTheme.pregnancyGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.heart5, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    '$kickCount',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'kicks',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<GamificationProvider>().recordLog(LogType.checkIn);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$kickCount kicks logged! ✓')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// Contraction Timer Sheet
class _ContractionTimerSheet extends StatefulWidget {
  final PregnancyProvider provider;
  const _ContractionTimerSheet({required this.provider});

  @override
  State<_ContractionTimerSheet> createState() => _ContractionTimerSheetState();
}

class _ContractionTimerSheetState extends State<_ContractionTimerSheet> {
  bool isTiming = false;
  int seconds = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Contraction Timer ⏱️',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: isTiming ? AppTheme.warning.withOpacity(0.1) : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: isTiming ? AppTheme.warning : Colors.grey.shade300,
                width: 4,
              ),
            ),
            child: Center(
              child: Text(
                '${seconds}s',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: isTiming ? AppTheme.warning : AppTheme.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isTiming = !isTiming;
                if (!isTiming) {
                  // Save contraction
                  context.read<GamificationProvider>().recordLog(LogType.checkIn);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraction ($seconds sec) logged! ✓')),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isTiming ? AppTheme.error : AppTheme.warning,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(isTiming ? 'Stop' : 'Start'),
          ),
        ],
      ),
    );
  }
}
