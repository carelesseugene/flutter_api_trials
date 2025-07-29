import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_services.dart';
import '../widgets/change_password_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  final phoneController = TextEditingController();
  final fullNameController = TextEditingController();
  final titleController = TextEditingController();
  final positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    user = await ApiService.getProfile();
    if (mounted && user != null) {
      phoneController.text = user!.phone ?? '';
      fullNameController.text = user!.fullName ?? '';
      titleController.text = user!.title ?? '';
      positionController.text = user!.position ?? '';
      
      setState(() {});
    }
  }

  Future<void> _update() async {
    if (user == null) return;
    final ok = await ApiService.updateProfile(
      email: user!.email,
      phone: phoneController.text.trim(),
      fullName: fullNameController.text.trim(),
      title: titleController.text.trim(),
      position: positionController.text.trim(),
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
          Text('Kullanıcı ID: ${user!.id}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 32),
          TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefon No', prefixText: '+')),
          TextField(controller: fullNameController, decoration: InputDecoration(labelText: 'Ad - Soyad')),
          TextField(controller: titleController, decoration: InputDecoration(labelText: 'Unvan')),
          TextField(controller: positionController, decoration: InputDecoration(labelText: 'Pozisyon')),

          const SizedBox(height: 12),
          ElevatedButton(onPressed: _update, child: const Text('Güncelle')),
          ElevatedButton.icon(
              icon: const Icon(Icons.lock_reset),
              label: const Text('Şifreni değiştir'),
              onPressed: () async {
                final success = await showDialog<bool>(
                  context: context,
                  builder: (_) => ChangePasswordDialog(email: user!.email),
                );
                if (success == true && mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Şifre değiştirildi')));
                }
              },
            ),

        ]),
      ),
    );
  }
}
