import 'package:flutter/material.dart';
import 'package:indiepub/services/auth_service.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final auth = AuthService(context);
    // Check if user is logged in
    final String? userId = auth.getCurrentUserId();
    if (userId != null) {
      // If authenticated, redirect to HomeScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to IndiePub',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                semanticsLabel: 'Welcome to IndiePub',
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                  semanticsLabel: 'Login button',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Signup',
                  style: TextStyle(fontSize: 18),
                  semanticsLabel: 'Signup button',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/events'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'View Events',
                  style: TextStyle(fontSize: 18),
                  semanticsLabel: 'View Events button',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}