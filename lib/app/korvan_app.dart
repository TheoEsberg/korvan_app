import 'package:flutter/material.dart';
import 'package:korvan_app/features/auth/presentation/auth_provider.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/login_screen.dart';
import 'theme/app_theme.dart';

class KorvanApp extends StatelessWidget {
  const KorvanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // TODO: Add providers later: AuthProvider, ScheduleProvider, etc.
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Korvan',
        theme: AppTheme.light(),
        home: const LoginScreen(),
      ),
    );
  }
}
