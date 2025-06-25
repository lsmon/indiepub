import 'package:flutter/material.dart';
import 'package:indiepub/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthService _auth;
  final _formKey = GlobalKey<FormState>();
  String _email = 'lsmon714@gmail.com';
  String _password = 'password';

  @override
  Widget build(BuildContext context) {
    _auth = AuthService(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: 'lsmon714@gmail.com',
                onChanged: (val) => _email = val,
                validator: (val) => val!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: 'password',
                onChanged: (val) => _password = val,
                validator: (val) => val!.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String? userId = await _auth.login(context, _email, _password);
                    if (userId != null) {
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login failed')),
                      );
                    }
                  }
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}