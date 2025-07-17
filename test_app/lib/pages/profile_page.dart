import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    user = await ApiService.getProfile();
    if (mounted && user != null) {
      phoneController.text = user!.phone ?? '';
      setState(() {});
    }
  }

  Future<void> _update() async {
    if (user == null) return;
    final ok = await ApiService.updateProfile(
      email: user!.email,
      phone: phoneController.text.trim(),
    );
    if (ok) _load(); // refresh profile after update
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(user!.email),
        actions: [
          IconButton(
            onPressed: () {
              ApiService.logout();
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Text('User-ID: ${user!.id}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 32),
          TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone', prefixText: '+')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _update, child: const Text('Update')),
        ]),
      ),
    );
  }
}
