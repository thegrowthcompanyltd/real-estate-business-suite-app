import 'package:flutter/material.dart';

import '../services/auth_api.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.onAuthenticated, super.key});
  final ValueChanged<AuthSession> onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final api = AuthApi();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => error = 'Enter your email and password.');
      return;
    }
    setState(() { busy = true; error = null; });
    try {
      widget.onAuthenticated(await api.login(email: email.text, password: password.text));
    } on AuthApiException catch (e) {
      setState(() => error = e.message);
    } catch (_) {
      setState(() => error = 'Unable to sign in right now.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sign in')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            if (error != null) ...[const SizedBox(height: 12), Text(error!, style: const TextStyle(color: Colors.red))],
            const SizedBox(height: 20),
            FilledButton(onPressed: busy ? null : login, child: Text(busy ? 'Signing in…' : 'Sign in')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RegisterPage(onRegistered: () => Navigator.of(context).pop()))),
              child: const Text('Create an account'),
            ),
          ],
        ),
      );
}
