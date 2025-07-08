import 'package:flutter/material.dart';
import '/services/api_services.dart';
import 'signup_page.dart';
import 'profile_page.dart';
import '/models/user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = 'error';

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final user = await ApiService.login(email, password);
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
      );
    } else {
      setState(() {
        error = "Invalid credentials";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 12),
            ElevatedButton(onPressed: _login, child: Text("Login")),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: Text("Don't have an account? Sign Up"),
            ),
            if (error.isNotEmpty) Text(error, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}