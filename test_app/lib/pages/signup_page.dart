import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_services.dart';
import '../services/realtime_service.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  String error = '';

  Future<void> _signup() async {
    final ok = await ApiService.signup(
      email: emailController.text.trim(),
      password: passwordController.text,
      phone: phoneController.text,
    );
    if (ok) {
      await ref.read(realtimeServiceProvider).ensureConnected(ref.read);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => error = 'Kayıt başarısız oldu. Lütfen tekrar deneyin.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Şifre')),
          TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefon No')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _signup, child: const Text('Kayıt Ol')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hesabınız var mı? Giriş yapın')),
          if (error.isNotEmpty)
            Text(error, style: const TextStyle(color: Colors.red)),
        ]),
      ),
    );
  }
}
