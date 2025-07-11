import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'profile_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  String message = '';

  Future<void> _signup() async {
    final ok = await ApiService.signup(
      email: emailController.text.trim(),
      password: passwordController.text,
      phone: phoneController.text.trim(),
    );

    if (ok) {
      final user = await ApiService.getProfile();
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => ProfilePage(user: user!)));
    } else {
      setState(() => message = 'Sign-up failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone (+90…)')),
          TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _signup, child: const Text('Create')),
          if (message.isNotEmpty) Text(message),
        ]),
      ),
    );
  }
}
