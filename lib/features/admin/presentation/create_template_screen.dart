import 'package:flutter/material.dart';
import 'package:korvan_app/data/services/template_service.dart';

class CreateTemplateScreen extends StatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _nameCtrl = TextEditingController();
  final List<_SlotDraft> _slots = [];

  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addSlot() async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (start == null) return;

    if (!mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 16, minute: 0),
    );
    if (end == null) return;

    // basic validation: end after start (same day)
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    if (endMinutes <= startMinutes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End time must be after start time")),
      );
      return;
    }

    setState(() => _slots.add(_SlotDraft(start: start, end: end)));
  }

  String _fmt(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Template name is required")),
      );
      return;
    }

    if (_slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one time slot")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // Convert slots to API format
      final slotPayload = _slots
          .map((s) => {"startTime": _fmt(s.start), "endTime": _fmt(s.end)})
          .toList();

      final created = await TemplateService.createTemplate(
        name: name,
        slots: slotPayload,
      );

      if (!mounted) return;
      Navigator.pop(context, created); // return created template to caller
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Template")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Template name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    "Slots",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _addSlot,
                  icon: const Icon(Icons.add),
                  label: const Text("Add slot"),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _slots.isEmpty
                  ? const Center(child: Text("No slots yet"))
                  : ListView.separated(
                      itemCount: _slots.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final s = _slots[index];
                        final label = "${_fmt(s.start)} - ${_fmt(s.end)}";
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            title: Text(label),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  setState(() => _slots.removeAt(index)),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const Text("Saving...")
                      : const Text("Save template"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotDraft {
  final TimeOfDay start;
  final TimeOfDay end;

  _SlotDraft({required this.start, required this.end});
}
