import 'package:flutter/material.dart';
import 'package:korvan_app/data/services/api_service.dart';

class EmployeeAvatar extends StatefulWidget {
  final String employeeId;
  final String displayName;
  final double radius;

  const EmployeeAvatar({
    super.key,
    required this.employeeId,
    required this.displayName,
    this.radius = 18,
  });

  @override
  State<EmployeeAvatar> createState() => _EmployeeAvatarState();
}

class _EmployeeAvatarState extends State<EmployeeAvatar> {
  bool _imageFailed = false;

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
    final initials = _initials(widget.displayName);

    final avatarUrl =
        "${ApiService.baseUrl}/api/users/${widget.employeeId}/avatar?ts=${DateTime.now().millisecondsSinceEpoch}";

    // If we already know image fails, don't try again
    final provider = _imageFailed ? null : NetworkImage(avatarUrl);

    return CircleAvatar(
      radius: widget.radius,
      backgroundImage: provider,
      onBackgroundImageError: provider != null
          ? (_, __) {
              if (mounted) setState(() => _imageFailed = true);
            }
          : null,
      child: provider == null
          ? Text(initials, style: const TextStyle(fontWeight: FontWeight.w700))
          : null, // ✅ no initials overlay on image
    );
  }
}
