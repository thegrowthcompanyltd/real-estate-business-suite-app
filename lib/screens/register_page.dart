import 'package:flutter/material.dart';

import '../services/auth_api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({required this.onRegistered, super.key});
  final VoidCallback onRegistered;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final api = AuthApi();
  bool busy = false;
  String? error;
  String? success;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (name.text.trim().isEmpty || email.text.trim().isEmpty || password.text.length < 12) {
      setState(() => error = 'Enter your name, a valid email, and a password of at least 12 characters.');
      return;
    }
    setState(() { busy = true; error = null; success = null; });
    try {
      await api.register(name: name.text, email: email.text, password: password.text);
      setState(() => success = 'Account created. It is awaiting activation.');
    } on AuthApiException catch (e) {
      setState(() => error = e.message);
    } catch (_) {
      setState(() => error = 'Unable to create your account right now.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create account')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Start your workspace', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Your account will be reviewed before access is activated.'),
            const SizedBox(height: 24),
            TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password (12+ characters)', border: OutlineInputBorder())),
            if (error != null) ...[const SizedBox(height: 12), Text(error!, style: const TextStyle(color: Colors.red))],
            if (success != null) ...[const SizedBox(height: 12), Text(success!, style: const TextStyle(color: Colors.green))],
            const SizedBox(height: 16),
            FilledButton(onPressed: busy ? null : register, child: Text(busy ? 'Creating…' : 'Create account')),
            if (success != null) ...[const SizedBox(height: 8), OutlinedButton(onPressed: widget.onRegistered, child: const Text('Return to sign in'))],
          ],
        ),
      );
}
