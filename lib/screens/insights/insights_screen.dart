import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/pregnancy_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/charts.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pregnancyProvider = context.watch<PregnancyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Health Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.pregnancyGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Week ${pregnancyProvider.currentWeek}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('${pregnancyProvider.vitalsCount} vitals logged this week', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Iconsax.chart, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // BP Chart
            Text('Blood Pressure', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BPChart(data: pregnancyProvider.bpChartData),
            const SizedBox(height: 24),

            // Weight Chart
            Text('Weight Tracking', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            WeightChart(data: pregnancyProvider.weightChartData),
            const SizedBox(height: 24),

            // Risk Timeline
            Text('Risk Score Trend', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRiskTimeline(context, pregnancyProvider),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskTimeline(BuildContext context, PregnancyProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRiskPoint('Week 20', 25, AppTheme.riskLow),
              _buildRiskPoint('Week 22', 30, AppTheme.riskLow),
              _buildRiskPoint('Week 24', provider.riskScore.toInt(), provider.riskScore < 30 ? AppTheme.riskLow : provider.riskScore < 60 ? AppTheme.riskMedium : AppTheme.riskHigh),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.riskLow, AppTheme.riskMedium, AppTheme.riskHigh]),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskPoint(String label, int score, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
          child: Text('$score', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
