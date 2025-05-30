import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:share_plus/share_plus.dart';
import 'package:indiepub/models/event.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;
  final logger = Logger();

  EventDetailsScreen({super.key, required this.event});

  Future<void> _buyTicket() async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: 'your-client-secret-from-backend',
          merchantDisplayName: 'IndiePub',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      logger.e('Payment error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location: ${event.location}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Date: ${DateFormat('MMMM d, yyyy').format(event.date)}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Price: \$${event.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Capacity: ${event.capacity} - Sold: ${event.sold}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _buyTicket,
              child: const Text('Buy Ticket'),
            ),
            ElevatedButton(
              onPressed: () {
                Share.share('Check out ${event.name} on IndiePub! Location: ${event.location} on ${DateFormat('MMMM d, yyyy').format(event.date)}');
              },
              child: const Text('Share Event'),
            ),
          ],
        ),
      ),
    );
  }
}