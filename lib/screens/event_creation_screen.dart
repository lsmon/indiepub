import 'package:flutter/material.dart';
import 'package:indiepub/models/event.dart';
import 'package:indiepub/services/auth_service.dart';
import 'package:indiepub/services/repository.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AuthService _auth;
  final Repository _repository = Repository();
  String _name = '';
  final DateTime _date = DateTime.now();
  String _location = '';
  double _price = 0.0;
  int _capacity = 0;

  @override
  Widget build(BuildContext context) {
    _auth = AuthService(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Event Name'),
                onChanged: (val) => _name = val,
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (val) => _location = val,
                validator: (val) => val!.isEmpty ? 'Enter location' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ticket Price'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _price = double.tryParse(val) ?? 0.0,
                validator: (val) => val!.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _capacity = int.tryParse(val) ?? 0,
                validator: (val) => val!.isEmpty ? 'Enter capacity' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final event = Event(
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: _name,
                      date: _date,
                      location: _location,
                      price: _price,
                      capacity: _capacity,
                      creatorId: _auth.getCurrentUserId()!,
                      sold: 0,
                      updatedAt: DateTime.now(),
                    );
                    await _repository.createEvent(event);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}