import 'package:flutter/material.dart';
import 'package:indiepub/services/auth_service.dart';
import 'package:indiepub/services/database_service.dart';
import 'package:indiepub/models/user.dart';

class ProfileScreen extends StatelessWidget {
  late final AuthService _auth;
  final DatabaseService _dbService = DatabaseService();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _auth = AuthService(context);
    String? uid = _auth.getCurrentUserId();
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please log in to view your profile')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder(
        future: _dbService.getUser(uid),
        builder: (context, AsyncSnapshot<AppUser?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Error loading profile'));
          }
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Email: ${user.email}'),
                Text('Role: ${user.role}'),
              ],
            ),
          );
        },
      ),
    );
  }
}