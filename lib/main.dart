import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'screens/property_feed_page.dart';
import 'screens/saved_properties_page.dart';
import 'services/auth_api.dart';
import 'services/auth_session_store.dart';
import 'services/rebs_api_client.dart';
import 'services/saved_properties_store.dart';

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
  final savedIds = <int>{};
  final savedStore = SavedPropertiesStore();
  final sessionStore = AuthSessionStore();
  bool ready = false;

  @override
  void initState() {
    super.initState();
    initialise();
  }

  Future<void> initialise() async {
    final saved = await savedStore.load();
    final restoredSession = await sessionStore.load();
    savedIds.addAll(saved);
    if (restoredSession != null) await syncSavedProperties(restoredSession);
    if (!mounted) return;
    setState(() {
      session = restoredSession;
      ready = true;
    });
  }

  Future<void> syncSavedProperties(AuthSession activeSession) async {
    try {
      final client = RebsApiClient(token: activeSession.token);
      final remoteIds = await client.fetchSavedPropertyIds();
      final mergedIds = {...savedIds, ...remoteIds};
      savedIds
        ..clear()
        ..addAll(mergedIds);
      await savedStore.save(savedIds);
      await client.updateSavedPropertyIds(savedIds);
    } on RebsApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await sessionStore.clear();
        session = null;
      }
    } catch (_) {
      // Local saved properties remain available when the network is unavailable.
    }
  }

  Future<void> toggleSaved(int propertyId) async {
    setState(() {
      if (!savedIds.add(propertyId)) savedIds.remove(propertyId);
    });
    await savedStore.save(savedIds);
    final activeSession = session;
    if (activeSession == null) return;
    try {
      final synced = await RebsApiClient(token: activeSession.token).updateSavedPropertyIds(savedIds);
      if (!mounted) return;
      setState(() {
        savedIds
          ..clear()
          ..addAll(synced);
      });
      await savedStore.save(savedIds);
    } catch (_) {
      // Keep the optimistic local change; it will be retried at next startup.
    }
  }

  Future<void> handleAuthenticated(AuthSession value) async {
    await sessionStore.save(value);
    session = value;
    await syncSavedProperties(value);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> signOut() async {
    await sessionStore.clear();
    if (!mounted) return;
    setState(() => session = null);
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final pages = <Widget>[
      PropertyFeedPage(session: session, savedIds: savedIds, onToggleSaved: toggleSaved),
      SavedPropertiesPage(savedIds: savedIds, onToggleSaved: toggleSaved, session: session),
      session == null ? LoginPage(onAuthenticated: handleAuthenticated) : AccountPage(session: session!, onSignOut: signOut),
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
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(session.user.name.isEmpty ? session.user.email : session.user.name, style: Theme.of(context).textTheme.headlineSmall),
            Text('${session.user.email} · ${session.user.role}'),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: () { onSignOut(); }, child: const Text('Sign out')),
          ],
        ),
      );
}
