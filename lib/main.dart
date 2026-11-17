import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'screens/property_feed_page.dart';
import 'services/auth_api.dart';
import 'services/property_api.dart';

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
  final savedIds = <int>{};

  void toggleSaved(int propertyId) {
    setState(() {
      if (!savedIds.add(propertyId)) savedIds.remove(propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      PropertyFeedPage(session: session, savedIds: savedIds, onToggleSaved: toggleSaved),
      SavedPropertiesPage(savedIds: savedIds, onToggleSaved: toggleSaved),
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

class SavedPropertiesPage extends StatelessWidget {
  const SavedPropertiesPage({required this.savedIds, required this.onToggleSaved, super.key});
  final Set<int> savedIds;
  final ValueChanged<int> onToggleSaved;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Saved properties')),
        body: savedIds.isEmpty
            ? const Center(child: Text('No saved properties yet.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Saved listing IDs are held for this app session. Account sync will be added with the saved-search API.'),
                  const SizedBox(height: 12),
                  for (final id in savedIds)
                    Card(child: ListTile(title: Text('Property #$id'), trailing: IconButton(icon: const Icon(Icons.bookmark), onPressed: () => onToggleSaved(id)))),
                ],
              ),
      );
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
