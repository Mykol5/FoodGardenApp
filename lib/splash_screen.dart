// lib/splash_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF9F8F6),
              const Color(0xFFE8F3F0),
              const Color(0xFF39AC86),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39AC86).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.eco,
                  size: 80,
                  color: const Color(0xFF39AC86),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // App Name
            const Text(
              'Harvest Hub',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101816),
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Grow, Share, Sustain',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF101816),
              ),
            ),

            const SizedBox(height: 60),

            // Loading text
            const Text(
              'Cultivating your garden...',
              style: TextStyle(
                color: Color(0xFF101816),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 16),

            // Progress Bar
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF39AC86).withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 2),
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF39AC86),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Version
            const Text(
              'VERSION 1.0.10',
              style: TextStyle(
                color: Color(0xFF101816),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
