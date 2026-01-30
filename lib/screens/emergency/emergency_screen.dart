import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/theme.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency'), backgroundColor: AppTheme.error),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Emergency Call Buttons
            _buildEmergencyButton(context, '🚨 Call 911', 'Emergency Services', AppTheme.error, () => _makeCall('911')),
            _buildEmergencyButton(context, '👨‍⚕️ Call My Doctor', 'Dr. Sarah Johnson', AppTheme.primaryPink, () => _makeCall('555-0123')),
            _buildEmergencyButton(context, '🏥 Nearest Hospital', 'Share Location', AppTheme.primaryTeal, () {}),
            const SizedBox(height: 32),

            // Warning Signs
            Text('When to Seek Immediate Help', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.error)),
            const SizedBox(height: 16),
            _buildWarningCard(context, 'Severe Bleeding', 'Heavy vaginal bleeding or passing clots', Iconsax.drop),
            _buildWarningCard(context, 'Severe Headache + Vision Changes', 'Could indicate preeclampsia', Iconsax.eye),
            _buildWarningCard(context, 'Decreased Fetal Movement', 'No kicks for 2+ hours after 28 weeks', Iconsax.lovely),
            _buildWarningCard(context, 'Severe Abdominal Pain', 'Sharp or persistent cramping', Iconsax.flash),
            _buildWarningCard(context, 'Water Breaking Early', 'Fluid leaking before 37 weeks', Iconsax.info_circle),
            _buildWarningCard(context, 'Difficulty Breathing', 'Chest pain or shortness of breath', Iconsax.wind),
            const SizedBox(height: 32),

            // Emergency Contacts
            Text('Emergency Contacts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildContactCard(context, 'Partner', 'John Doe', '555-0100'),
            _buildContactCard(context, 'Emergency Contact', 'Mom', '555-0101'),
            _buildContactCard(context, 'OB-GYN', 'Dr. Sarah Johnson', '555-0123'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context, String title, String subtitle, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Iconsax.call, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context, String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.error.withOpacity(0.2))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppTheme.error, size: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, String role, String name, String phone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppTheme.primaryPink.withOpacity(0.1), child: Text(name[0], style: const TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold))),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(role, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: IconButton(icon: const Icon(Iconsax.call5, color: AppTheme.success), onPressed: () => _makeCall(phone)),
      ),
    );
  }

  void _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
