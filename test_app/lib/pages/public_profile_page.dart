import 'package:flutter/material.dart';
import '../services/api_services.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;
  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  Map<String, dynamic>? profile;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await ApiService.getPublicProfile(widget.userId);
      setState(() {
        profile = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
          ? Center(child: Text(error!))
          : profile == null
            ? const Center(child: Text("Profile not found"))
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile!['fullName'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    Text('Email: ${profile!['email']}'),
                    Text('Phone: ${profile!['phoneNumber']}'),
                    Text('Title: ${profile!['title']}'),
                    Text('Position: ${profile!['position']}'),
                  ],
                ),
              ),
    );
  }
}
