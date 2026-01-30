import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/user_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../utils/theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final cycleProvider = context.watch<CycleProvider>();
    final isFertilityMode = userProvider.isFertilityMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFertilityMode ? 'Cycle Calendar' : 'Pregnancy Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.info_circle),
            onPressed: () => _showLegend(context, isFertilityMode),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Container(
            margin: const EdgeInsets.all(16),
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
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildDayCell(context, day, cycleProvider, isFertilityMode, false);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildDayCell(context, day, cycleProvider, isFertilityMode, true);
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              calendarStyle: const CalendarStyle(outsideDaysVisible: false),
            ),
          ),
          
          // Selected Day Info
          if (_selectedDay != null)
            Expanded(child: _buildDayDetails(context, _selectedDay!, cycleProvider, isFertilityMode)),
        ],
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime day, CycleProvider cycleProvider, bool isFertilityMode, bool isToday) {
    if (!isFertilityMode) {
      return _buildDefaultCell(context, day, isToday);
    }

    final dayType = cycleProvider.getDayType(day);
    final isFuture = cycleProvider.isFutureDate(day);
    
    Color bgColor;
    Color textColor = Colors.white;
    
    if (isFuture) {
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey;
    } else {
      switch (dayType) {
        case 'period':
          bgColor = AppTheme.periodRed;
          break;
        case 'ovulation':
          bgColor = AppTheme.ovulationDarkGreen;
          break;
        case 'fertile':
          bgColor = AppTheme.fertileGreen;
          break;
        default:
          bgColor = AppTheme.safeBlue.withOpacity(0.3);
          textColor = AppTheme.textDark;
      }
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: AppTheme.primaryPink, width: 2) : null,
      ),
      child: Center(
        child: Text('${day.day}', style: TextStyle(color: textColor, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildDefaultCell(BuildContext context, DateTime day, bool isToday) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isToday ? AppTheme.primaryPink : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text('${day.day}', style: TextStyle(color: isToday ? Colors.white : null)),
      ),
    );
  }

  Widget _buildDayDetails(BuildContext context, DateTime day, CycleProvider cycleProvider, bool isFertilityMode) {
    final log = cycleProvider.getLogForDate(day);
    final dayType = cycleProvider.getDayType(day);
    final fertilityScore = cycleProvider.currentCycle?.getFertilityScore(day) ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${day.day}/${day.month}/${day.year}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDayTypeColor(dayType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(dayType.toUpperCase(), style: TextStyle(color: _getDayTypeColor(dayType), fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isFertilityMode) ...[
            Text('Fertility Score: $fertilityScore%', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            if (log != null) ...[
              if (log.bbtTemperature != null) Text('BBT: ${log.bbtTemperature}°C'),
              if (log.cervicalMucus != null) Text('Cervical Mucus: ${log.cervicalMucus}'),
              if (log.symptoms.isNotEmpty) Text('Symptoms: ${log.symptoms.join(", ")}'),
            ] else
              const Text('No data logged for this day', style: TextStyle(color: Colors.grey)),
          ],
        ],
      ),
    );
  }

  Color _getDayTypeColor(String type) {
    switch (type) {
      case 'period': return AppTheme.periodRed;
      case 'ovulation': return AppTheme.ovulationDarkGreen;
      case 'fertile': return AppTheme.fertileGreen;
      default: return AppTheme.safeBlue;
    }
  }

  void _showLegend(BuildContext context, bool isFertilityMode) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calendar Legend', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _legendItem(AppTheme.periodRed, 'Period Days'),
            _legendItem(AppTheme.fertileGreen, 'Fertile Window'),
            _legendItem(AppTheme.ovulationDarkGreen, 'Ovulation Day'),
            _legendItem(AppTheme.safeBlue.withOpacity(0.3), 'Safe Days'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 24, height: 24, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 16),
          Text(label),
        ],
      ),
    );
  }
}
