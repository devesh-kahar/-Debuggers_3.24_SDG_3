import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/user_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/fertility_score_card.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/cycle_info_card.dart';

class FertilityHome extends StatelessWidget {
  const FertilityHome({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final cycleProvider = context.watch<CycleProvider>();
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user?.name ?? 'there'} 👋',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                        const SizedBox(height: 4),
                        Text(
                          'How are you feeling today?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                    _buildModeToggle(context, userProvider),
                  ],
                ),
              ),
            ),

            // Fertility Score Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FertilityScoreCard(
                  cycleDay: cycleProvider.currentCycleDay,
                  fertilityScore: cycleProvider.todaysFertilityScore,
                  daysUntilOvulation: cycleProvider.predictedOvulationDate != null
                      ? cycleProvider.predictedOvulationDate!.difference(DateTime.now()).inDays
                      : 0,
                  daysUntilPeriod: cycleProvider.daysUntilNextPeriod,
                ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
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
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionCard(
                            icon: Iconsax.note_add,
                            label: 'Log Symptom',
                            color: AppTheme.primaryPink,
                            onTap: () => _showSymptomLogger(context, cycleProvider),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickActionCard(
                            icon: Iconsax.chart_2,
                            label: 'Log BBT',
                            color: AppTheme.primaryTeal,
                            onTap: () => _showBBTLogger(context, cycleProvider),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionCard(
                            icon: Iconsax.drop,
                            label: 'Cervical Mucus',
                            color: AppTheme.info,
                            onTap: () => _showMucusLogger(context, cycleProvider),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickActionCard(
                            icon: Iconsax.heart,
                            label: 'Intimacy',
                            color: AppTheme.lavender,
                            onTap: () => _showIntimacyLogger(context, cycleProvider),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Cycle Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cycle Insights',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 16),
                    CycleInfoCard(
                      cycleLength: cycleProvider.currentCycle?.cycleLength ?? 28,
                      periodLength: cycleProvider.currentCycle?.periodLength ?? 5,
                      fertileWindowStart: cycleProvider.fertileWindow.isNotEmpty 
                          ? cycleProvider.fertileWindow.first 
                          : DateTime.now(),
                      ovulationDate: cycleProvider.predictedOvulationDate ?? DateTime.now(),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
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
                    gradient: AppTheme.fertilityGradient,
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
                              'Daily Tip',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDailyTip(cycleProvider.currentCycleDay),
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
                ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
          gradient: AppTheme.fertilityGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.heart, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Fertility',
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.lovely,
                size: 40,
                color: AppTheme.primaryPink,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Switch to Pregnancy Mode?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Congratulations! 🎉 Your fertility data will be used to personalize your pregnancy journey.',
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
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Not Yet'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      userProvider.switchToPregnancyMode();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("I'm Pregnant!"),
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

  String _getDailyTip(int cycleDay) {
    if (cycleDay <= 5) {
      return 'Rest and take care of yourself during your period. Stay hydrated!';
    } else if (cycleDay <= 10) {
      return 'Your body is preparing for ovulation. Track your cervical mucus changes.';
    } else if (cycleDay <= 16) {
      return 'You\'re in or near your fertile window! This is the best time to try to conceive.';
    } else {
      return 'Two-week wait! Stay positive and avoid stressing about results.';
    }
  }

  void _showSymptomLogger(BuildContext context, CycleProvider cycleProvider) {
    _showQuickLogSheet(context, 'Log Symptom', Iconsax.note_add, AppTheme.primaryPink, () {
      cycleProvider.logSymptom('Cramping', 5);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Symptom logged! ✓')),
      );
    });
  }

  void _showBBTLogger(BuildContext context, CycleProvider cycleProvider) {
    _showQuickLogSheet(context, 'Log Temperature', Iconsax.chart_2, AppTheme.primaryTeal, () {
      cycleProvider.logDailyEntry(bbtTemperature: 36.5);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Temperature logged! ✓')),
      );
    });
  }

  void _showMucusLogger(BuildContext context, CycleProvider cycleProvider) {
    _showQuickLogSheet(context, 'Cervical Mucus', Iconsax.drop, AppTheme.info, () {
      cycleProvider.logDailyEntry(cervicalMucus: 'eggWhite');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cervical mucus logged! ✓')),
      );
    });
  }

  void _showIntimacyLogger(BuildContext context, CycleProvider cycleProvider) {
    _showQuickLogSheet(context, 'Log Intimacy', Iconsax.heart, AppTheme.lavender, () {
      cycleProvider.logDailyEntry(hadIntercourse: true);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intimacy logged! ✓')),
      );
    });
  }

  void _showQuickLogSheet(BuildContext context, String title, IconData icon, Color color, VoidCallback onConfirm) {
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
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirm'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
