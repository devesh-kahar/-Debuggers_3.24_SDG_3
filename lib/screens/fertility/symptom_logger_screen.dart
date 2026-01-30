import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/cycle_provider.dart';
import '../../utils/theme.dart';

class SymptomLoggerScreen extends StatefulWidget {
  const SymptomLoggerScreen({super.key});

  @override
  State<SymptomLoggerScreen> createState() => _SymptomLoggerScreenState();
}

class _SymptomLoggerScreenState extends State<SymptomLoggerScreen> {
  final Set<String> _selectedSymptoms = {};
  double _energyLevel = 5;
  double _sleepHours = 8;
  String? _selectedMucus;
  String _notes = '';

  final List<Map<String, dynamic>> _symptoms = [
    {'name': 'Cramping', 'icon': Iconsax.flash_circle},
    {'name': 'Bloating', 'icon': Iconsax.blur},
    {'name': 'Headache', 'icon': Iconsax.activity},
    {'name': 'Back Pain', 'icon': Iconsax.electricity},
    {'name': 'Breast Tenderness', 'icon': Iconsax.lovely},
    {'name': 'Nausea', 'icon': Iconsax.blend},
    {'name': 'Mood Swings', 'icon': Iconsax.emoji_normal},
    {'name': 'Fatigue', 'icon': Iconsax.battery_empty},
    {'name': 'Acne', 'icon': Iconsax.moon},
    {'name': 'Food Cravings', 'icon': Iconsax.cake},
    {'name': 'Anxiety', 'icon': Iconsax.cloud},
    {'name': 'Insomnia', 'icon': Iconsax.timer_start},
  ];

  final List<Map<String, dynamic>> _mucusTypes = [
    {'type': 'dry', 'label': 'Dry', 'desc': 'No noticeable mucus', 'fertility': 'Low'},
    {'type': 'sticky', 'label': 'Sticky', 'desc': 'Thick, tacky texture', 'fertility': 'Low'},
    {'type': 'creamy', 'label': 'Creamy', 'desc': 'Lotiony, white', 'fertility': 'Medium'},
    {'type': 'watery', 'label': 'Watery', 'desc': 'Clear, wet', 'fertility': 'High'},
    {'type': 'eggWhite', 'label': 'Egg White', 'desc': 'Stretchy, clear', 'fertility': 'Peak'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Symptoms')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Physical Symptoms
            Text('Physical Symptoms', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Tap to select', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1),
              itemCount: _symptoms.length,
              itemBuilder: (context, index) {
                final symptom = _symptoms[index];
                final isSelected = _selectedSymptoms.contains(symptom['name']);
                return GestureDetector(
                  onTap: () => setState(() => isSelected ? _selectedSymptoms.remove(symptom['name']) : _selectedSymptoms.add(symptom['name'])),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryPink.withOpacity(0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppTheme.primaryPink : Colors.transparent, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(symptom['icon'], color: isSelected ? AppTheme.primaryPink : Colors.grey, size: 28),
                        const SizedBox(height: 8),
                        Text(symptom['name'], style: TextStyle(fontSize: 11, color: isSelected ? AppTheme.primaryPink : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Energy Level
            Text('Energy Level', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('😴', style: TextStyle(fontSize: 24)),
                Expanded(child: Slider(value: _energyLevel, min: 1, max: 10, divisions: 9, activeColor: AppTheme.primaryTeal, label: _energyLevel.toInt().toString(), onChanged: (v) => setState(() => _energyLevel = v))),
                const Text('⚡', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 24),

            // Sleep Hours
            Text('Sleep (last night)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Iconsax.moon5, color: AppTheme.lavender),
                const SizedBox(width: 8),
                Expanded(child: Slider(value: _sleepHours, min: 0, max: 12, divisions: 24, activeColor: AppTheme.lavender, label: '${_sleepHours.toStringAsFixed(1)} hrs', onChanged: (v) => setState(() => _sleepHours = v))),
                Text('${_sleepHours.toStringAsFixed(1)} hrs', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),

            // Cervical Mucus
            Text('Cervical Mucus', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...(_mucusTypes.map((m) => _buildMucusOption(m))),
            const SizedBox(height: 32),

            // Notes
            Text('Notes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(hintText: 'Any additional notes...', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              onChanged: (v) => _notes = v,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: () => _saveLog(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Save Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMucusOption(Map<String, dynamic> mucus) {
    final isSelected = _selectedMucus == mucus['type'];
    final fertilityColor = mucus['fertility'] == 'Peak' ? AppTheme.ovulationDarkGreen : mucus['fertility'] == 'High' ? AppTheme.fertileGreen : mucus['fertility'] == 'Medium' ? AppTheme.warning : Colors.grey;

    return GestureDetector(
      onTap: () => setState(() => _selectedMucus = mucus['type']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryTeal : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Radio<String>(value: mucus['type'], groupValue: _selectedMucus, onChanged: (v) => setState(() => _selectedMucus = v), activeColor: AppTheme.primaryTeal),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mucus['label'], style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryTeal : null)),
                  Text(mucus['desc'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: fertilityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(mucus['fertility'], style: TextStyle(color: fertilityColor, fontSize: 11, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  void _saveLog(BuildContext context) {
    final cycleProvider = context.read<CycleProvider>();
    cycleProvider.logDailyEntry(cervicalMucus: _selectedMucus, sleepHours: _sleepHours, energyLevel: _energyLevel.toInt(), notes: _notes);
    for (final symptom in _selectedSymptoms) {
      cycleProvider.logSymptom(symptom, 5);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Symptoms logged successfully! ✓')));
  }
}
