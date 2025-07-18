import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/foundation.dart'; // Added for kDebugMode
import '../widgets/button.dart'; // Removed unused import '../styles/common_styles.dart'

// Assuming AppButton is defined in widgets/button.dart and doesn't rely on common_styles.dart here

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to Smart Transport',
      'description': 'Track your child’s school vehicle in real-time with ease.',
      'lottie': 'assets/animations/vehicle_tracking.json',
    },
    {
      'title': 'Stay Notified',
      'description': 'Get instant alerts for pickups, drops, and vehicle updates.',
      'lottie': 'assets/animations/notifications.json',
    },
    {
      'title': 'Connect with Drivers',
      'description': 'Securely communicate with drivers for peace of mind.',
      'lottie': 'assets/animations/communication.json',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 300,
                        child: Builder(
                          builder: (context) {
                            try {
                              return Lottie.asset(
                                onboardingData[index]['lottie']!,
                                height: 300,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  if (kDebugMode) {
                                    print('Lottie error: $error\nStack trace: $stackTrace');
                                  }
                                  return const Icon(Icons.error, size: 100, color: Colors.red);
                                },
                              );
                            } catch (e) {
                              if (kDebugMode) {
                                print('Unexpected error loading Lottie: $e');
                              }
                              return const Icon(Icons.error, size: 100, color: Colors.red);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        onboardingData[index]['title']!,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        onboardingData[index]['description']!,
                        style: const TextStyle(fontSize: 16, color: Color(0xFFB0BEC5)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? const Color(0xFF2196F3) : const Color(0xFFB0BEC5),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _currentPage == onboardingData.length - 1
                ? AppButton(
                    text: 'Get Started',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    backgroundColor: const Color(0xFF2196F3),
                  )
                : AppButton(
                    text: 'Next',
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    backgroundColor: const Color(0xFF2196F3),
                  ),
          ),
        ],
      ),
    );
  }
}