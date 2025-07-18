import 'package:flutter/material.dart';
import '../styles/common_styles.dart';
import '../widgets/button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: CommonStyles.wrapper,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Smart Student Transport Tracker',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Track your child\'s school transport in real-time',
              style: TextStyle(fontSize: 16, color: Color(0xFFB0BEC5)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Column(
              children: [
                Text(
                  '• Real-time vehicle tracking',
                  style: TextStyle(fontSize: 14, color: Color(0xFF90CAF9)),
                ),
                Text(
                  '• Pickup & drop-off notifications',
                  style: TextStyle(fontSize: 14, color: Color(0xFF90CAF9)),
                ),
                Text(
                  '• Attendance management',
                  style: TextStyle(fontSize: 14, color: Color(0xFF90CAF9)),
                ),
                Text(
                  '• Secure parent-driver communication',
                  style: TextStyle(fontSize: 14, color: Color(0xFF90CAF9)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                AppButton(
                  text: 'Login',
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  backgroundColor: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Register',
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  backgroundColor: Colors.transparent,
                  textColor: const Color(0xFF2196F3),
                  borderColor: const Color(0xFF2196F3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}