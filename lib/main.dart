import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'screens/property_feed_page.dart';
import 'services/auth_api.dart';

void main() => runApp(const RealEstateBusinessSuiteApp());

class RealEstateBusinessSuiteApp extends StatelessWidget {
  const RealEstateBusinessSuiteApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Real Estate Business Suite',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A5F)),
          useMaterial3: true,
        ),
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
      PropertyFeedPage(session: session),
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

class AccountPage extends StatelessWidget {
  const AccountPage({required this.session, required this.onSignOut, super.key});
  final AuthSession session;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(session.user.name.isEmpty ? session.user.email : session.user.name, style: Theme.of(context).textTheme.headlineSmall),
            Text('${session.user.email} · ${session.user.role}'),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: onSignOut, child: const Text('Sign out')),
          ],
        ),
      );
}
