import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/theme.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Records')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadSheet(context),
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Iconsax.document_upload, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medical History Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Medical History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildInfoRow('Blood Type', 'O+'),
                  _buildInfoRow('Allergies', 'None reported'),
                  _buildInfoRow('Pre-existing Conditions', 'None'),
                  _buildInfoRow('Previous Pregnancies', '0'),
                  const SizedBox(height: 12),
                  TextButton.icon(onPressed: () {}, icon: const Icon(Iconsax.edit, size: 18), label: const Text('Edit History')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Documents Section
            Text('Documents', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDocumentCard(context, 'Blood Work Results', 'Jan 15, 2026', Iconsax.document_text, AppTheme.primaryTeal),
            _buildDocumentCard(context, 'Ultrasound Week 12', 'Jan 10, 2026', Iconsax.image, AppTheme.primaryPink),
            _buildDocumentCard(context, 'First Prenatal Visit', 'Dec 28, 2025', Iconsax.clipboard_text, AppTheme.lavender),
            const SizedBox(height: 24),

            // Vaccinations
            Text('Vaccinations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildVaccinationCard(context, 'Flu Shot', 'Completed', 'Nov 2025', true),
            _buildVaccinationCard(context, 'Tdap', 'Recommended Week 27-36', 'Pending', false),
            _buildVaccinationCard(context, 'COVID-19 Booster', 'Recommended', 'Pending', false),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, String title, String date, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Iconsax.document_download, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _buildVaccinationCard(BuildContext context, String name, String status, String date, bool completed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: completed ? AppTheme.success.withOpacity(0.3) : Colors.grey.shade200)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: completed ? AppTheme.success.withOpacity(0.1) : Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(completed ? Iconsax.tick_circle5 : Iconsax.timer_1, color: completed ? AppTheme.success : Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(status, style: TextStyle(fontSize: 12, color: completed ? AppTheme.success : Colors.grey)),
              ],
            ),
          ),
          Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showUploadSheet(BuildContext context) {
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
            Text('Upload Document', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _uploadOption(context, Iconsax.camera, 'Camera', AppTheme.primaryPink)),
              const SizedBox(width: 16),
              Expanded(child: _uploadOption(context, Iconsax.gallery, 'Gallery', AppTheme.primaryTeal)),
              const SizedBox(width: 16),
              Expanded(child: _uploadOption(context, Iconsax.document, 'Files', AppTheme.lavender)),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _uploadOption(BuildContext context, IconData icon, String label, Color color) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
