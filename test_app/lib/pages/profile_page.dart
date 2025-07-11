import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_services.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final phoneController = TextEditingController();

  Future<void> _update() async {
    final ok = await ApiService.updateProfile(
        email: widget.user.email, phone: phoneController.text.trim());

    if (ok) {
      final refreshed = await ApiService.getProfile();
      if (!mounted) return;
      setState(() => phoneController.text = refreshed?.phone ?? '');
    }
  }

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.user.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.email),
        actions: [
          IconButton(
              onPressed: () {
                ApiService.logout();
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Text('User-ID: ${widget.user.id}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 32),
          TextField(
              controller: phoneController,
              decoration:
                  const InputDecoration(labelText: 'Phone', prefixText: '+')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _update, child: const Text('Update')),
        ]),
      ),
    );
  }
}
