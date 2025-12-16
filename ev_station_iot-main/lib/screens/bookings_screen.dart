import 'package:flutter/material.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding:
          EdgeInsets.symmetric(horizontal: isTablet ? 64 : 24, vertical: 24),
          child: Column(
            children: [
              Image.asset('lib/assets/images/booked.png',
                  width: isTablet ? 300 : 200, fit: BoxFit.contain),
              const SizedBox(height: 24),
              const Text('Booking Confirmed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Image.asset('lib/assets/images/waiting.png',
                  width: isTablet ? 300 : 200, fit: BoxFit.contain),
              const SizedBox(height: 16),
              const Text('Waiting for your turn',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
