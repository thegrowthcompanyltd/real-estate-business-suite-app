import 'package:flutter/material.dart';

import '../screens/property_detail_page.dart';
import '../services/auth_api.dart';
import '../services/property_api.dart';

class PropertyFeedPage extends StatefulWidget {
  const PropertyFeedPage({this.session, required this.savedIds, required this.onToggleSaved, super.key});
  final AuthSession? session;
  final Set<int> savedIds;
  final ValueChanged<int> onToggleSaved;

  @override
  State<PropertyFeedPage> createState() => _PropertyFeedPageState();
}

class _PropertyFeedPageState extends State<PropertyFeedPage> {
  final api = PropertyApi();
  late Future<List<Property>> properties;
  String query = '';
  String transactionFilter = 'All';
  String typeFilter = 'All';

  @override
  void initState() {
    super.initState();
    properties = api.fetchProperties();
  }

  List<String> options(List<Property> items, String Function(Property) valueOf) {
    final values = items.map(valueOf).where((value) => value.trim().isNotEmpty).toSet().toList()..sort();
    return ['All', ...values];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Properties')),
        body: FutureBuilder<List<Property>>(
          future: properties,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return MessageState(message: 'Unable to load properties.', onRetry: () => setState(() => properties = api.fetchProperties()));
            final all = snapshot.data ?? const <Property>[];
            final transactionOptions = options(all, (item) => item.transaction);
            final typeOptions = options(all, (item) => item.propertyType ?? '');
            final items = all.where((item) {
              final haystack = '${item.id} ${item.title} ${item.location} ${item.transaction} ${item.propertyType ?? ''}'.toLowerCase();
              final matchesQuery = haystack.contains(query.trim().toLowerCase());
              final matchesTransaction = transactionFilter == 'All' || item.transaction == transactionFilter;
              final matchesType = typeFilter == 'All' || item.propertyType == typeFilter;
              return matchesQuery && matchesTransaction && matchesType;
            }).toList(growable: false);
            return Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: TextField(onChanged: (value) => setState(() => query = value), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search properties', border: OutlineInputBorder()))),
              SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [
                DropdownButton<String>(value: transactionOptions.contains(transactionFilter) ? transactionFilter : 'All', onChanged: (value) => setState(() => transactionFilter = value ?? 'All'), items: transactionOptions.map((value) => DropdownMenuItem(value: value, child: Text('Transaction: $value'))).toList()),
                const SizedBox(width: 16),
                DropdownButton<String>(value: typeOptions.contains(typeFilter) ? typeFilter : 'All', onChanged: (value) => setState(() => typeFilter = value ?? 'All'), items: typeOptions.map((value) => DropdownMenuItem(value: value, child: Text('Type: $value'))).toList()),
              ])),
              Expanded(child: items.isEmpty ? const MessageState(message: 'No matching properties.') : RefreshIndicator(onRefresh: () async => setState(() => properties = api.fetchProperties()), child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: items.length, itemBuilder: (context, index) {
                final item = items[index];
                final saved = widget.savedIds.contains(item.id);
                return Card(child: ListTile(
                  leading: item.image == null ? const CircleAvatar(child: Icon(Icons.apartment)) : CircleAvatar(backgroundImage: NetworkImage(item.image!)),
                  title: Text(item.title),
                  subtitle: Text('${item.location}\n${item.price} ${item.currency}'),
                  isThreeLine: true,
                  trailing: IconButton(icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline), onPressed: () => widget.onToggleSaved(item.id)),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PropertyDetailPage(property: item, session: widget.session))),
                ));
              })))
            ]);
          },
        ),
      );
}

class MessageState extends StatelessWidget {
  const MessageState({required this.message, this.onRetry, super.key});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(message), if (onRetry != null) ...[const SizedBox(height: 12), OutlinedButton(onPressed: onRetry, child: const Text('Retry'))]]));
}
