import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korvan_app/data/models/user_list_model.dart';
import 'package:korvan_app/data/models/user_model.dart';
import 'package:korvan_app/data/services/admin_schedule_service.dart';
import 'package:korvan_app/data/services/user_service.dart';

class CreateShiftScreen extends StatefulWidget {
  const CreateShiftScreen({super.key});

  @override
  State<CreateShiftScreen> createState() => _CreateShiftScreenState();
}

class _CreateShiftScreenState extends State<CreateShiftScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedUserId;

  late Future<List<UserListModel>> _usersFuture;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = UserService.getEmployees();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime(bool start) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        start ? _startTime = time : _endTime = time;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedUserId == null ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => loading = true);

    await AdminScheduleService.createShift(
      userId: _selectedUserId!,
      date: _selectedDate!,
      start: _startTime!,
      end: _endTime!,
    );

    setState(() => loading = false);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? "Pick date"
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final startText = _startTime == null
        ? "Start time"
        : _startTime!.format(context);
    final endText = _endTime == null ? "End time" : _endTime!.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Schedule")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Employee dropdown populated from backend
            FutureBuilder<List<UserListModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text("Failed to load employees");
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return const Text("No employees found");
                }

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Employee"),
                  initialValue: _selectedUserId,
                  items: users.map((user) {
                    return DropdownMenuItem(
                      value: user.id, // GUID from backend
                      child: Text(user.displayName),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => _selectedUserId = v);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            ListTile(
              title: Text(dateText),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickDate,
            ),
            ListTile(
              title: Text(startText),
              trailing: const Icon(Icons.schedule),
              onTap: () => _pickTime(true),
            ),
            ListTile(
              title: Text(endText),
              trailing: const Icon(Icons.schedule),
              onTap: () => _pickTime(false),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Create Shift"),
            ),
          ],
        ),
      ),
    );
  }
}
