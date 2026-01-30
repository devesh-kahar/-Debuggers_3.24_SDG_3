import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/user_provider.dart';
import '../../utils/theme.dart';
import '../home/main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Form data
  String _name = '';
  int _age = 25;
  double _height = 160;
  double _weight = 60;
  String _goal = 'fertility'; // 'fertility' or 'pregnancy'
  int _cycleLength = 28;
  DateTime? _lastPeriodDate;
  final List<String> _conditions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(5, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _currentPage ? AppTheme.primaryPink : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [_buildNamePage(), _buildBasicInfoPage(), _buildGoalPage(), _buildCyclePage(), _buildConditionsPage()],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(onPressed: _previousPage, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Back')),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _currentPage == 4 ? _completeOnboarding : _nextPage,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(_currentPage == 4 ? 'Get Started' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('What should we call you?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          TextField(
            decoration: InputDecoration(labelText: 'Your name', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            onChanged: (v) => _name = v,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about yourself', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Text('Age: $_age years'), Slider(value: _age.toDouble(), min: 18, max: 50, divisions: 32, activeColor: AppTheme.primaryPink, onChanged: (v) => setState(() => _age = v.toInt())),
          const SizedBox(height: 16),
          Text('Height: ${_height.toInt()} cm'), Slider(value: _height, min: 140, max: 190, divisions: 50, activeColor: AppTheme.primaryTeal, onChanged: (v) => setState(() => _height = v)),
          const SizedBox(height: 16),
          Text('Weight: ${_weight.toInt()} kg'), Slider(value: _weight, min: 40, max: 120, divisions: 80, activeColor: AppTheme.lavender, onChanged: (v) => setState(() => _weight = v)),
        ],
      ),
    );
  }

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What brings you here?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildGoalCard('fertility', '🌸 Trying to Conceive', 'Track fertility & increase chances', AppTheme.primaryTeal),
          const SizedBox(height: 16),
          _buildGoalCard('pregnancy', '🤰 I\'m Pregnant', 'Monitor pregnancy health & baby', AppTheme.primaryPink),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String value, String title, String desc, Color color) {
    final isSelected = _goal == value;
    return GestureDetector(
      onTap: () => setState(() => _goal = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: 2)),
        child: Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? color : null)), const SizedBox(height: 4), Text(desc, style: const TextStyle(color: Colors.grey))])),
            if (isSelected) Icon(Iconsax.tick_circle5, color: color, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your cycle info', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Text('Average cycle length: $_cycleLength days'), Slider(value: _cycleLength.toDouble(), min: 21, max: 40, divisions: 19, activeColor: AppTheme.primaryPink, onChanged: (v) => setState(() => _cycleLength = v.toInt())),
          const SizedBox(height: 24),
          Text('Last period start date', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 60)), lastDate: DateTime.now());
              if (date != null) setState(() => _lastPeriodDate = date);
            },
            icon: const Icon(Iconsax.calendar),
            label: Text(_lastPeriodDate != null ? '${_lastPeriodDate!.day}/${_lastPeriodDate!.month}/${_lastPeriodDate!.year}' : 'Select Date'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsPage() {
    final conditions = ['None', 'PCOS', 'Endometriosis', 'Thyroid disorder', 'Diabetes', 'Hypertension', 'Previous miscarriage'];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Medical history', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Select any that apply', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: conditions.map((c) => FilterChip(
              label: Text(c),
              selected: _conditions.contains(c),
              onSelected: (v) => setState(() => v ? _conditions.add(c) : _conditions.remove(c)),
              selectedColor: AppTheme.primaryPink.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryPink,
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _nextPage() => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  void _previousPage() => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

  void _completeOnboarding() {
    final userProvider = context.read<UserProvider>();
    userProvider.updateUser(name: _name.isEmpty ? 'User' : _name, age: _age, height: _height, weight: _weight, currentMode: _goal);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
  }
}
