import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/theme.dart';

class CycleInfoCard extends StatelessWidget {
  final int cycleLength;
  final int periodLength;
  final DateTime fertileWindowStart;
  final DateTime ovulationDate;

  const CycleInfoCard({
    super.key,
    required this.cycleLength,
    required this.periodLength,
    required this.fertileWindowStart,
    required this.ovulationDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    
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
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  context,
                  label: 'Cycle Length',
                  value: '$cycleLength days',
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoTile(
                  context,
                  label: 'Period Length',
                  value: '$periodLength days',
                  color: AppTheme.periodRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateTile(
                  context,
                  label: 'Fertile Window',
                  date: dateFormat.format(fertileWindowStart),
                  icon: Icons.favorite_border,
                  color: AppTheme.fertileGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateTile(
                  context,
                  label: 'Ovulation',
                  date: dateFormat.format(ovulationDate),
                  icon: Icons.egg_outlined,
                  color: AppTheme.ovulationDarkGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(BuildContext context, {
    required String label,
    required String date,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
            Text(
              date,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
