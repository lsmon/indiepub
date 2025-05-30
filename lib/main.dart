import 'package:flutter/material.dart';
import 'package:indiepub/screens/login_screen.dart';
import 'package:indiepub/screens/signup_screen.dart';
import 'package:indiepub/screens/home_screen.dart';
import 'package:indiepub/screens/event_creation_screen.dart';
import 'package:indiepub/screens/profile_screen.dart';
import 'package:indiepub/screens/forum_screen.dart';
import 'package:indiepub/screens/analytics_screen.dart';
import 'package:indiepub/screens/venue_calendar_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndiePub',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/create-event': (context) => const EventCreationScreen(),
        '/profile': (context) => ProfileScreen(),
        '/forum': (context) => const ForumScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/venue-calendar': (context) => const VenueCalendarScreen(),
      },
    );
  }
}