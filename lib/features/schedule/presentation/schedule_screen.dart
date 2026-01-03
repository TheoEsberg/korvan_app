import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korvan_app/data/services/api_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:korvan_app/data/models/shift_model.dart';
import 'package:korvan_app/data/services/schedule_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<ShiftModel>> _events = {};
  bool _loading = false;
  String? _error;

  Color _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) {
      return Colors.blueGrey; // fallback
    }
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // add alpha
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadMonth(_focusedDay);
  }

  DateTime _normalizeDay(DateTime d) => DateTime(d.year, d.month, d.day);

  void _loadMonth(DateTime month) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    try {
      // For now: show only my shifts. Use onlyMine: false for admin view.
      final shifts = await ScheduleService.getShiftsForRange(
        firstDay,
        lastDay,
        onlyMine: false,
      );

      final map = <DateTime, List<ShiftModel>>{};
      for (final shift in shifts) {
        final dayKey = _normalizeDay(shift.date);
        map.putIfAbsent(dayKey, () => []).add(shift);
      }

      setState(() {
        _events = map;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load schedule: $e';
        _loading = false;
      });
    }
  }

  List<ShiftModel> _getShiftsForDay(DateTime day) {
    final key = _normalizeDay(day);
    return _events[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = _selectedDay ?? _focusedDay;
    final shiftsForSelectedDay = _getShiftsForDay(selectedDay);

    return Column(
      children: [
        if (_loading) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        _buildCalendar(),
        const SizedBox(height: 8),
        Expanded(child: _buildShiftList(shiftsForSelectedDay, selectedDay)),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<ShiftModel>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) =>
          _selectedDay != null && isSameDay(day, _selectedDay),
      eventLoader: (day) => _getShiftsForDay(day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _loadMonth(focusedDay);
      },
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFBBDEFB),
        ),
        selectedDecoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent,
        ),
        markersMaxCount: 3,
        // markerDecoration is ignored if markerBuilder is used,
        // but you can leave it here, it's harmless.
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders<ShiftModel>(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox.shrink();

          // events is List<ShiftModel> because of TableCalendar<ShiftModel>
          final shifts = events.cast<ShiftModel>();

          // Get distinct colors per employee
          final colors = shifts
              .map((s) => _colorFromHex(s.employeeColorHex))
              .toSet()
              .toList();

          // Show up to 3 colored dots per day
          return Align(
            alignment: Alignment.bottomCenter,
            child: Wrap(
              spacing: 2,
              children: colors.take(3).map((c) {
                return Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShiftList(List<ShiftModel> shifts, DateTime day) {
    final dateText = DateFormat('EEEE d MMMM').format(day);

    if (shifts.isEmpty) {
      return Center(
        child: Text(
          "No shifts on $dateText",
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: shifts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final shift = shifts[index];
                final color = _colorFromHex(shift.employeeColorHex);
                final name = shift.employeeName ?? "Unassigned";
                final initials = name
                    .trim()
                    .split(' ')
                    .map((e) => e[0])
                    .take(2)
                    .join();

                final avatarUrl =
                    (shift.employeeAvatarUrl != null && shift.employeeHasAvatar)
                    ? "${ApiService.baseUrl}${shift.employeeAvatarUrl!}?ts=${shift.id}"
                    : null;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withAlpha(100),
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              initials,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(shift.formatTimeRange()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
