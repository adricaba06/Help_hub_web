import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F8F7),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFF10B77F),
              child: Icon(Icons.volunteer_activism, color: Colors.white, size: 48),
            ),
            SizedBox(height: 20),
            Text(
              'HelpHub',
              style: TextStyle(
                color: Color(0xFF18181B),
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tu ayuda importa',
              style: TextStyle(color: Color(0xFF52525B), fontSize: 15),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Color(0xFF10B77F),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
