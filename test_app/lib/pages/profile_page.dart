import 'package:flutter/material.dart';
import '../models/user.dart';

class ProfilePage extends StatelessWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${user.name}"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            Text("Email: ${user.email}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("ID: ${user.id}", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}