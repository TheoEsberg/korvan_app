import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korvan_app/data/models/day_plan_model.dart';
import 'package:korvan_app/data/models/template_model.dart';
import 'package:korvan_app/data/services/api_service.dart';
import 'package:korvan_app/data/services/day_plan_service.dart';
import 'package:korvan_app/data/services/template_service.dart';
import 'package:korvan_app/data/services/user_service.dart';
import 'package:korvan_app/data/models/user_list_model.dart';
import 'package:korvan_app/features/admin/presentation/create_template_screen.dart';
import 'package:korvan_app/shared/widgets/employee_avatar.dart';

class AdminScheduleBuilderScreen extends StatefulWidget {
  const AdminScheduleBuilderScreen({super.key});

  @override
  State<AdminScheduleBuilderScreen> createState() =>
      _AdminScheduleBuilderScreenState();
}

class _AdminScheduleBuilderScreenState
    extends State<AdminScheduleBuilderScreen> {
  DateTime _selectedDate = DateTime.now();

  List<TemplateListModel> _templates = [];
  TemplateListModel? _selectedTemplate;

  DayPlanModel? _dayPlan;

  bool _loadingTemplates = true;
  bool _loadingPlan = false;
  bool _publishing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _loadingTemplates = true;
      _error = null;
    });

    try {
      final list = await TemplateService.getTemplates();
      setState(() {
        _templates = list;
        _selectedTemplate = list.isNotEmpty ? list.first : null;
        _loadingTemplates = false;
      });

      if (_selectedTemplate != null) {
        await _loadDayPlan();
      }
    } catch (e) {
      setState(() {
        _error = "Failed to load templates: $e";
        _loadingTemplates = false;
      });
    }
  }

  Future<void> _loadDayPlan() async {
    if (_selectedTemplate == null) return;

    setState(() {
      _loadingPlan = true;
      _error = null;
    });

    try {
      final plan = await DayPlanService.getOrCreateDayPlan(
        date: _selectedDate,
        templateId: _selectedTemplate!.id,
      );

      setState(() {
        _dayPlan = plan;
        _loadingPlan = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load day plan: $e";
        _loadingPlan = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() => _selectedDate = picked);
    await _loadDayPlan();
  }

  String _fmtTime(String t) {
    // supports "HH:mm:ss" or "HH:mm"
    final parts = t.split(':');
    final hh = parts[0].padLeft(2, '0');
    final mm = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
    return "$hh:$mm";
  }

  Future<void> _openEmployeePicker(DayPlanSlotModel slot) async {
    if (_dayPlan == null) return;
    if (_dayPlan!.isPublished) return;

    final users = await UserService.getEmployees(); // must exist in your app
    if (!mounted) return;

    final chosen = await showModalBottomSheet<UserListModel?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EmployeePickerSheet(users: users),
    );

    if (chosen == null) return;

    await DayPlanService.assignEmployee(
      dayPlanId: _dayPlan!.id,
      slotId: slot.slotId,
      employeeId: chosen.id,
    );

    await _loadDayPlan();
  }

  Future<void> _publish() async {
    if (_dayPlan == null) return;

    if (_dayPlan!.isPublished) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Already published")));
      return;
    }

    setState(() => _publishing = true);

    try {
      final resp = await DayPlanService.publish(_dayPlan!.id);

      final warnings =
          (resp["warnings"] as List<dynamic>?)?.cast<String>() ?? [];
      final created = resp["createdShifts"]?.toString() ?? "?";

      if (!mounted) return;

      if (warnings.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Published ($created). ${warnings.join(' ')}"),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Published ($created shifts)")));
      }

      await _loadDayPlan();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Publish failed: $e")));
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('EEE d MMM').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Builder"),
        actions: [
          if (_dayPlan != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Chip(
                  label: Text(_dayPlan!.isPublished ? "Published" : "Draft"),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_loadingTemplates || _loadingPlan)
            const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(dateText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<TemplateListModel>(
                          initialValue: _selectedTemplate,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Template",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          selectedItemBuilder: (context) {
                            // This controls how the selected item renders in the "closed" dropdown.
                            // We ellipsis long template names so it never overflows.
                            return _templates.map((t) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  t.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList();
                          },
                          items: _templates.map((t) {
                            // Dropdown menu items: also ellipsis just in case
                            return DropdownMenuItem(
                              value: t,
                              child: Text(
                                t.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (t) async {
                            setState(() => _selectedTemplate = t);
                            await _loadDayPlan();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Make the + button a fixed size so it doesn't steal layout space oddly
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: "New template",
                          onPressed: () async {
                            final created = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreateTemplateScreen(),
                              ),
                            );

                            if (created == null) return;

                            await _loadTemplates();

                            final match = _templates
                                .where((t) => t.id == created.id)
                                .toList();
                            if (match.isNotEmpty) {
                              setState(() => _selectedTemplate = match.first);
                              await _loadDayPlan();
                            }
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _dayPlan == null
                ? const Center(child: Text("Select a template to begin"))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _dayPlan!.slots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final slot = _dayPlan!.slots[index];

                      final assigned = slot.employeeId != null;
                      final timeText =
                          "${_fmtTime(slot.startTime)} - ${_fmtTime(slot.endTime)}";

                      final hasAvatar =
                          slot.employeeHasAvatar && slot.employeeId != null;

                      final avatarProvider = hasAvatar
                          ? NetworkImage(
                              "${ApiService.baseUrl}/api/users/${slot.employeeId}/avatar?ts=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : null;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          onTap: _dayPlan!.isPublished
                              ? null
                              : () => _openEmployeePicker(slot),
                          title: Text(
                            timeText,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            assigned
                                ? (slot.employeeName ?? "Assigned")
                                : "Unassigned",
                          ),
                          trailing: assigned
                              ? CircleAvatar(
                                  radius: 18,
                                  backgroundImage: avatarProvider,
                                  onBackgroundImageError: hasAvatar
                                      ? (_, __) {}
                                      : null, // ✅ important
                                  child: hasAvatar
                                      ? null
                                      : (slot.employeeName != null &&
                                            slot.employeeName!.isNotEmpty)
                                      ? Text(
                                          slot.employeeName!
                                              .trim()
                                              .split(RegExp(r'\s+'))
                                              .where((p) => p.isNotEmpty)
                                              .map((p) => p[0])
                                              .take(2)
                                              .join()
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : const Icon(Icons.person),
                                )
                              : const Icon(Icons.person_add_alt_1),
                        ),
                      );
                    },
                  ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed:
                      (_dayPlan == null || _dayPlan!.isPublished || _publishing)
                      ? null
                      : _publish,
                  icon: const Icon(Icons.publish),
                  label: _publishing
                      ? const Text("Publishing...")
                      : const Text("Publish Shifts"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeePickerSheet extends StatelessWidget {
  final List<UserListModel> users;

  const _EmployeePickerSheet({required this.users});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Material(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select employee",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final u = users[index];
                    final initials = _initials(u.displayName);

                    // We *try* to show avatar via anonymous endpoint.
                    // If user has no avatar, it may 404 and you might see console logs.
                    final avatarUrl =
                        "${ApiService.baseUrl}/api/users/${u.id}/avatar?ts=${DateTime.now().millisecondsSinceEpoch}";

                    return ListTile(
                      leading: EmployeeAvatar(
                        employeeId: u.id,
                        displayName: u.displayName,
                        radius: 18,
                      ),
                      title: Text(u.displayName),
                      onTap: () => Navigator.pop(context, u),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
