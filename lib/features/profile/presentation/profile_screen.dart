import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:korvan_app/data/models/user_profile_model.dart';
import 'package:korvan_app/data/services/user_service.dart';
import 'package:korvan_app/features/auth/presentation/auth_provider.dart';
import 'package:korvan_app/features/auth/presentation/login_screen.dart';
import 'package:korvan_app/data/services/auth_service.dart';
import '../../admin/presentation/create_shift_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileModel? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _colorHex;

  final List<String> _colorOptions = [
    "#2196F3",
    "#E91E63",
    "#4CAF50",
    "#FF9800",
    "#9C27B0",
    "#03A9F4",
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await UserService.getMe();
      setState(() {
        _profile = profile;
        _colorHex = profile.profileColorHex ?? "#2196F3";
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _toColor(String hex) {
    hex = hex.replaceAll("#", "");
    return Color(int.parse("FF$hex", radix: 16));
  }

  Future<void> _save() async {
    if (_profile == null) return;

    setState(() => _saving = true);

    try {
      await UserService.updatePreferences(
        profileColorHex: _colorHex,
        avatarUrl: _profile!.avatarUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Saved!")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_profile == null) {
      return const Center(child: Text("Failed to load profile"));
    }

    final color = _toColor(_colorHex!);
    final initials = _profile!.displayName.isNotEmpty
        ? _profile!.displayName
              .trim()
              .split(' ')
              .map((e) => e[0])
              .take(2)
              .join()
        : "?";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: color.withOpacity(0.2),
                    backgroundImage:
                        (_profile!.avatarUrl != null &&
                            _profile!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(_profile!.avatarUrl!)
                        : null,
                    child:
                        (_profile!.avatarUrl == null ||
                            _profile!.avatarUrl!.isEmpty)
                        ? Text(
                            initials,
                            style: TextStyle(
                              color: color,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _profile!.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profile!.email,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  // Color picker
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Profile Color",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    children: _colorOptions.map((hex) {
                      final c = _toColor(hex);
                      final selected = hex == _colorHex;

                      return GestureDetector(
                        onTap: () => setState(() => _colorHex = hex),
                        child: CircleAvatar(
                          radius: selected ? 20 : 18,
                          backgroundColor: c,
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const CircularProgressIndicator()
                        : const Text("Save"),
                  ),

                  const SizedBox(height: 24),

                  FutureBuilder<String?>(
                    future: AuthService.getUserRole(),
                    builder: (context, snapshot) {
                      final role = snapshot.data;
                      if (role == "Admin" || role == "Owner") {
                        return Column(
                          children: [
                            const Divider(),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.admin_panel_settings),
                              label: const Text("Admin: Create Schedule"),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CreateShiftScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: () async {
                      await auth.logout();
                      if (!context.mounted) return;

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
