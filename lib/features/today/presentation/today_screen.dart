import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korvan_app/data/models/shift_model.dart';
import 'package:korvan_app/data/services/schedule_service.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateText = DateFormat('d MMMM').format(today); // e.g. "3 September"

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: FutureBuilder<ShiftModel?>(
          future: ScheduleService.getTodayShift(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return const Text('Could not load today\'s shift');
            }

            final shift = snapshot.data;

            if (shift == null) {
              return _TodayCard(
                title: "Day off 🎉",
                subtitle: "You have no shifts today",
                dateText: dateText,
                timeText: "",
                isWorking: false,
              );
            }

            final timeText =
                "${shift.startTime.formatHHmm()} - ${shift.endTime.formatHHmm()}";

            return _TodayCard(
              title: "Working",
              subtitle: "You have a shift today",
              dateText: dateText,
              timeText: timeText,
              isWorking: true,
            );
          },
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateText;
  final String timeText;
  final bool isWorking;

  const _TodayCard({
    required this.title,
    required this.subtitle,
    required this.dateText,
    required this.timeText,
    required this.isWorking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isWorking ? Colors.blueAccent : Colors.greenAccent;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWorking ? Icons.work_outline : Icons.weekend,
              size: 48,
              color: accent,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(dateText, style: theme.textTheme.titleMedium),
            if (timeText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                timeText,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
