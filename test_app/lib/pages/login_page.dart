import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_services.dart';
import '../services/realtime_service.dart';


class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  Future<void> _login() async {
    final ok = await ApiService.login(
        emailController.text.trim(), passwordController.text);

    if (ok) {
      await ref.read(realtimeServiceProvider).ensureConnected(ref.read);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => error = 'Wrong e-mail / password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _login, child: const Text('Login')),
          TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text("Don't have an account? Sign up")),
          if (error.isNotEmpty)
            Text(error, style: const TextStyle(color: Colors.red)),
        ]),
      ),
    );
  }
}
