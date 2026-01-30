import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/theme.dart';

class PartnerScreen extends StatelessWidget {
  const PartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Access')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Partner Invite Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: AppTheme.pregnancyGradient, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Iconsax.people, color: Colors.white, size: 40)),
                  const SizedBox(height: 16),
                  Text('Invite Your Partner', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Share your fertility journey together', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showInviteSheet(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primaryPink, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                    icon: const Icon(Iconsax.send_2),
                    label: const Text('Send Invite'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // What Partner Can See
            Text('What Your Partner Can See', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPrivacyOption(context, 'Fertile Window Alerts', 'Get notified about fertile days', true),
            _buildPrivacyOption(context, 'Pregnancy Progress', 'Baby size, week updates', true),
            _buildPrivacyOption(context, 'Appointment Reminders', 'Prenatal visit dates', true),
            _buildPrivacyOption(context, 'Symptom Details', 'Specific symptom logs', false),
            _buildPrivacyOption(context, 'Medical Records', 'Lab results, ultrasounds', false),
            const SizedBox(height: 32),

            // Partner Resources
            Text('For Partners', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildResourceCard(context, 'How to Support During Fertility Journey', Iconsax.heart, AppTheme.primaryPink),
            _buildResourceCard(context, 'Understanding Pregnancy Changes', Iconsax.lovely, AppTheme.primaryTeal),
            _buildResourceCard(context, 'Preparing for Labor & Delivery', Iconsax.timer, AppTheme.lavender),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(BuildContext context, String title, String desc, bool enabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
          Switch(value: enabled, onChanged: (_) {}, activeColor: AppTheme.primaryPink),
        ],
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Invite Partner', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(decoration: InputDecoration(labelText: 'Partner\'s Email', prefixIcon: const Icon(Iconsax.sms), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent! ✓'))); },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 52)),
              child: const Text('Send Invitation'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
