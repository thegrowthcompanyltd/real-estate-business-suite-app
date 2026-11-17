import 'package:flutter/material.dart';

import '../screens/property_detail_page.dart';
import '../services/auth_api.dart';
import '../services/property_api.dart';

class SavedPropertiesPage extends StatefulWidget {
  const SavedPropertiesPage({required this.savedIds, required this.onToggleSaved, this.session, super.key});

  final Set<int> savedIds;
  final ValueChanged<int> onToggleSaved;
  final AuthSession? session;

  @override
  State<SavedPropertiesPage> createState() => _SavedPropertiesPageState();
}

class _SavedPropertiesPageState extends State<SavedPropertiesPage> {
  final api = PropertyApi();
  late Future<List<Property>> properties;

  @override
  void initState() {
    super.initState();
    properties = api.fetchProperties();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Saved properties')),
        body: FutureBuilder<List<Property>>(
          future: properties,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return _MessageState(message: 'Unable to load saved properties.', onRetry: () => setState(() => properties = api.fetchProperties()));
            final items = (snapshot.data ?? const <Property>[]).where((item) => widget.savedIds.contains(item.id)).toList(growable: false);
            if (items.isEmpty) return const _MessageState(message: 'No saved properties yet.');
            return RefreshIndicator(
              onRefresh: () async => setState(() => properties = api.fetchProperties()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: item.image == null ? const CircleAvatar(child: Icon(Icons.apartment)) : CircleAvatar(backgroundImage: NetworkImage(item.image!)),
                      title: Text(item.title),
                      subtitle: Text('${item.location}\n${item.price} ${item.currency}'),
                      isThreeLine: true,
                      trailing: IconButton(icon: const Icon(Icons.bookmark), tooltip: 'Remove saved property', onPressed: () => widget.onToggleSaved(item.id)),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PropertyDetailPage(property: item, session: widget.session))),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(message), if (onRetry != null) ...[const SizedBox(height: 12), OutlinedButton(onPressed: onRetry, child: const Text('Retry'))]]));
}
