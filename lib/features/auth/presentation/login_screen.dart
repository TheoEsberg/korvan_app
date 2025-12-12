import 'package:flutter/material.dart';
import 'package:korvan_app/features/auth/presentation/auth_provider.dart';
import 'package:korvan_app/features/home/presentation/home_screen.dart';
import 'package:korvan_app/features/schedule/presentation/schedule_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final username = _username.text.trim();
    final password = _password.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter username and password.")),
      );
      return;
    }

    setState(() => loading = true);
    final success = await auth.login(username, password);
    setState(() => loading = false);

    if (success) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      if (!mounted) return;
      final msg = auth.errorMessage ?? "Login failed";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthProvider>().status;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 90,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _username,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: (loading || authStatus == AuthStatus.loading)
                        ? null
                        : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: (loading || authStatus == AuthStatus.loading)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Login"),
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
