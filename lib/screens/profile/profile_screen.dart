import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/user_provider.dart';
import '../../utils/theme.dart';
import 'reminder_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: userProvider.isFertilityMode ? AppTheme.fertilityGradient : AppTheme.pregnancyGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 35, backgroundColor: Colors.white.withOpacity(0.2), child: Text(user?.name.substring(0, 1) ?? 'S', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'User', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Health Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Health Profile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatRow('Age', '${user?.age ?? 25} years'),
                  _buildStatRow('Height', '${user?.height ?? 160} cm'),
                  _buildStatRow('Weight', '${user?.weight ?? 60} kg'),
                  _buildStatRow('BMI', user?.bmi.toStringAsFixed(1) ?? '--'),
                  _buildStatRow('Blood Type', user?.bloodType ?? 'Unknown'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildSettingsTile(context, Iconsax.notification, 'Reminders', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderSettingsScreen()));
                  }),
                  _buildSettingsTile(context, Iconsax.moon, 'Dark Mode', () => userProvider.toggleDarkMode(), trailing: Switch(value: user?.isDarkMode ?? false, onChanged: (_) => userProvider.toggleDarkMode(), activeColor: AppTheme.primaryPink)),
                  _buildSettingsTile(context, Iconsax.document, 'Privacy Policy', () {}),
                  _buildSettingsTile(context, Iconsax.info_circle, 'About', () {}),
                  _buildSettingsTile(context, Iconsax.logout, 'Logout', () => userProvider.logout(), isDestructive: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Version
            Text('MomAI v1.0.0', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Made with 💕 for moms everywhere', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {Widget? trailing, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppTheme.error : AppTheme.textMedium),
      title: Text(title, style: TextStyle(color: isDestructive ? AppTheme.error : null)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
