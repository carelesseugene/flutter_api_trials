import 'package:flutter/material.dart';
import '../services/api_services.dart';

class ChangePasswordDialog extends StatefulWidget {
  final String email; const ChangePasswordDialog({super.key, required this.email});
  @override _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final cur = TextEditingController();
  final neu = TextEditingController();
  final rep = TextEditingController();
  bool loading = false; String error = '';

  Future<void> _submit() async {
    if (neu.text != rep.text) { setState(()=>error='Passwords do not match'); return; }
    setState(()=>loading=true);
    final ok = await ApiService.changePassword(
        email: widget.email, currentPwd: cur.text, newPwd: neu.text);
    if (!mounted) return;
    if (ok) Navigator.pop(context, true);
    else setState(()=> error='Wrong current password');
    setState(()=>loading=false);
  }

  @override Widget build(BuildContext ctx) => AlertDialog(
    title: const Text('Change password'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: cur, obscureText: true, decoration: const InputDecoration(labelText:'Current')),
      TextField(controller: neu, obscureText: true, decoration: const InputDecoration(labelText:'New')),
      TextField(controller: rep, obscureText: true, decoration: const InputDecoration(labelText:'Repeat')),
      if (error.isNotEmpty) Padding(
        padding: const EdgeInsets.only(top:6),
        child: Text(error, style: const TextStyle(color: Colors.red)),
      ),
    ]),
    actions: [
      TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Cancel')),
      ElevatedButton(onPressed: loading?null:_submit, child: const Text('Save')),
    ],
  );
}
