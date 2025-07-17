import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../pages/login_page.dart';
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget dashTile(String title, IconData icon, VoidCallback onTap) => Card(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              height: 80,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 32),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ),
        );

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 64), // Space from top
          dashTile("Projects", Icons.work, () {
            Navigator.pushNamed(context, '/projects');
          }),
          dashTile("Profile", Icons.person, () {
            Navigator.pushNamed(context, '/profile');
          }),
          dashTile("Page 3", Icons.settings, () {
          }),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () async {
                  await ApiService.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false,
                        );   
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
