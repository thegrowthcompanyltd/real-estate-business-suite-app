import 'package:flutter/material.dart';

import '../services/auth_api.dart';
import '../services/property_api.dart';
import '../services/rebs_api_client.dart';

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({required this.property, this.session, super.key});

  final Property property;
  final AuthSession? session;

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final message = TextEditingController();
  final galleryController = PageController();
  bool busy = false;
  String? feedback;
  int galleryIndex = 0;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    message.dispose();
    galleryController.dispose();
    super.dispose();
  }

  Future<void> submitInquiry() async {
    if (name.text.trim().isEmpty || email.text.trim().isEmpty) {
      setState(() => feedback = 'Name and email are required.');
      return;
    }
    if (widget.session == null) {
      setState(() => feedback = 'Sign in to send an inquiry.');
      return;
    }
    setState(() { busy = true; feedback = null; });
    try {
      await RebsApiClient(token: widget.session!.token).submitLead(
        name: name.text,
        email: email.text,
        propertyId: widget.property.id,
        phone: phone.text,
        message: message.text,
      );
      setState(() => feedback = 'Inquiry sent successfully.');
    } on RebsApiException catch (error) {
      setState(() => feedback = error.message);
    } catch (_) {
      setState(() => feedback = 'Unable to send your inquiry right now.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  List<String> get gallery {
    final images = <String>[];
    if (widget.property.image != null) images.add(widget.property.image!);
    for (final image in widget.property.gallery) {
      if (image.isNotEmpty && !images.contains(image)) images.add(image);
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final images = gallery;
    return Scaffold(
      appBar: AppBar(title: const Text('Property details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (images.isNotEmpty)
            Column(children: [
              SizedBox(
                height: 230,
                child: PageView.builder(
                  controller: galleryController,
                  itemCount: images.length,
                  onPageChanged: (value) => setState(() => galleryIndex = value),
                  itemBuilder: (_, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(images[index], fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image))),
                  ),
                ),
              ),
              if (images.length > 1) ...[
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(images.length, (index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Icon(Icons.circle, size: 9, color: index == galleryIndex ? Theme.of(context).colorScheme.primary : Colors.grey.shade400)))),
              ],
            ])
          else
            const SizedBox(height: 120, child: Icon(Icons.apartment, size: 72)),
          const SizedBox(height: 16),
          Text(property.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('${property.currency} ${property.price}', style: Theme.of(context).textTheme.titleLarge),
          Text(property.location),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (property.transaction.isNotEmpty) Chip(label: Text(property.transaction)),
            if (property.propertyType != null) Chip(label: Text(property.propertyType!)),
            if (property.bedrooms != null) Chip(label: Text('${property.bedrooms} bedrooms')),
            if (property.bathrooms != null) Chip(label: Text('${property.bathrooms} bathrooms')),
            if (property.area != null) Chip(label: Text(property.area!)),
          ]),
          if (property.description.isNotEmpty) ...[const SizedBox(height: 20), Text(property.description)],
          const SizedBox(height: 24),
          Text('Send an inquiry', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone (optional)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: message, maxLines: 4, decoration: const InputDecoration(labelText: 'Message (optional)', border: OutlineInputBorder())),
          if (feedback != null) ...[const SizedBox(height: 12), Text(feedback!, style: const TextStyle(color: Colors.blueGrey))],
          const SizedBox(height: 16),
          FilledButton(onPressed: busy ? null : submitInquiry, child: Text(busy ? 'Sending…' : 'Send inquiry')),
        ],
      ),
    );
  }
}
