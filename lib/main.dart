import 'package:flutter/material.dart';

import 'services/property_api.dart';

void main() {
  runApp(const RealEstateBusinessSuiteApp());
}

class RealEstateBusinessSuiteApp extends StatelessWidget {
  const RealEstateBusinessSuiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Estate Business Suite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A5F)),
        useMaterial3: true,
      ),
      home: const PropertyFeedPage(),
    );
  }
}

class PropertyFeedPage extends StatefulWidget {
  const PropertyFeedPage({super.key});

  @override
  State<PropertyFeedPage> createState() => _PropertyFeedPageState();
}

class _PropertyFeedPageState extends State<PropertyFeedPage> {
  final _api = PropertyApi();
  late Future<List<Property>> _properties;

  @override
  void initState() {
    super.initState();
    _properties = _api.fetchProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Properties')),
      body: FutureBuilder<List<Property>>(
        future: _properties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Unable to load properties: ${snapshot.error}'));
          }
          final properties = snapshot.data ?? const <Property>[];
          if (properties.isEmpty) {
            return const Center(child: Text('No properties found.'));
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() {
              _properties = _api.fetchProperties();
            }),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(property.title),
                    subtitle: Text('${property.location}\n${property.price} ${property.currency}'),
                    isThreeLine: true,
                    trailing: Text(property.transaction),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
