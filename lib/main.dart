import 'package:flutter/material.dart';

import 'services/auth_api.dart';
import 'services/property_api.dart';

void main() => runApp(const RealEstateBusinessSuiteApp());

class RealEstateBusinessSuiteApp extends StatelessWidget {
  const RealEstateBusinessSuiteApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Real Estate Business Suite',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A5F)), useMaterial3: true),
        home: const AppShell(),
      );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  AuthSession? session;
  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const PropertyFeedPage(),
      const Scaffold(body: Center(child: Text('Saved searches will be connected next.'))),
      session == null
          ? LoginPage(onAuthenticated: (value) => setState(() => session = value))
          : AccountPage(session: session!, onSignOut: () => setState(() => session = null)),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Properties'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}

class PropertyFeedPage extends StatefulWidget {
  const PropertyFeedPage({super.key});
  @override
  State<PropertyFeedPage> createState() => _PropertyFeedPageState();
}

class _PropertyFeedPageState extends State<PropertyFeedPage> {
  final api = PropertyApi();
  late Future<List<Property>> properties;
  @override
  void initState() {
    super.initState();
    properties = api.fetchProperties();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Properties')),
        body: FutureBuilder<List<Property>>(
          future: properties,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return MessageState(message: 'Unable to load properties.', onRetry: () => setState(() => properties = api.fetchProperties()));
            final items = snapshot.data ?? const <Property>[];
            if (items.isEmpty) return const MessageState(message: 'No properties found.');
            return RefreshIndicator(
              onRefresh: () async => setState(() => properties = api.fetchProperties()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.apartment)), title: Text(item.title), subtitle: Text('${item.location}\n${item.price} ${item.currency}'), isThreeLine: true, trailing: Text(item.transaction)));
                },
              ),
            );
          },
        ),
      );
}

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
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
          if (error != null) ...[const SizedBox(height: 12), Text(error!, style: const TextStyle(color: Colors.red))],
          const SizedBox(height: 20),
          FilledButton(onPressed: busy ? null : login, child: Text(busy ? 'Signing in…' : 'Sign in')),
        ]),
      );
}

class AccountPage extends StatelessWidget {
  const AccountPage({required this.session, required this.onSignOut, super.key});
  final AuthSession session;
  final VoidCallback onSignOut;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Account')), body: ListView(padding: const EdgeInsets.all(24), children: [Text(session.user.name.isEmpty ? session.user.email : session.user.name, style: Theme.of(context).textTheme.headlineSmall), Text('${session.user.email} · ${session.user.role}'), const SizedBox(height: 24), OutlinedButton(onPressed: onSignOut, child: const Text('Sign out'))]));
}

class MessageState extends StatelessWidget {
  const MessageState({required this.message, this.onRetry, super.key});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(message), if (onRetry != null) ...[const SizedBox(height: 12), OutlinedButton(onPressed: onRetry, child: const Text('Retry'))]]));
}
