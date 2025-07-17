import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/projects_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/dashboard_page.dart';  // <-- add this import
import 'pages/profile_page.dart';    // <-- for profile route, create if not exists
void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini-Trello',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      initialRoute: '/',   // explicitly define initial route
      routes: {
        '/':        (_) => const LoginPage(),
        '/signup':  (_) => const SignupPage(),
        '/home':    (_) => const DashboardPage(), // <-- Dashboard after login
        '/projects':(_) => const ProjectsPage(),
        '/profile': (_) => const ProfilePage(),   // <-- Add profile route
      },
    );
  }
}
