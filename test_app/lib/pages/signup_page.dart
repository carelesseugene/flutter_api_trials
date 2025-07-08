import 'package:flutter/material.dart';
import '../services/api_services.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String message = '';

  void _signup() async {
    final success = await ApiService.signup(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
    );

    setState(() {
      message = success ? "Signup successful! Go login." : "Signup failed!";
    });

    if (success) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 12),
            ElevatedButton(onPressed: _signup, child: Text("Sign Up")),
            Text(message),
          ],
        ),
      ),
    );
  }
}
