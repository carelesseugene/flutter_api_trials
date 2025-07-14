import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/projects_page.dart';
import 'pages/login_page.dart';    // your existing login page
import 'pages/signup_page.dart';   // your existing signup page

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini-Trello',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const LoginPage(),
      routes: {
        '/projects': (_) => const ProjectsPage(),
        '/signup':   (_) => const SignupPage(),
      },
    );
  }
}
