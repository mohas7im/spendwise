import 'package:flutter/material.dart';
import 'dart:ui';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Track Every Penny',
      'description': 'Log your daily expenses instantly and keep a close eye on your financial health with beautiful analytics.',
      'icon': Icons.insights_rounded,
      'color': Colors.blueAccent,
    },
    {
      'title': 'Smart Budgets',
      'description': 'Set weekly, monthly, and yearly budgets. We will notify you before you overspend so you stay on track.',
      'icon': Icons.track_changes_rounded,
      'color': Colors.greenAccent,
    },
    {
      'title': 'Split Bills Seamlessly',
      'description': 'Going out with friends? Split bills instantly and keep track of who owes who without the awkwardness.',
      'icon': Icons.receipt_long_rounded,
      'color': Colors.orangeAccent,
    },
    {
      'title': 'Secure Vault',
      'description': 'Store your sensitive documents and bank cards securely in your personal encrypted vault.',
      'icon': Icons.security_rounded,
      'color': Colors.purpleAccent,
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background ambient glow
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            top: _currentPage == 0 ? -100 : (_currentPage == 1 ? 100 : (_currentPage == 2 ? 300 : 0)),
            left: _currentPage == 0 ? -100 : (_currentPage == 1 ? 200 : (_currentPage == 2 ? -50 : 150)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_currentPage]['color'].withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => const LoginScreen()));
                      },
                      child: Text('Skip', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon with glowing rings
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _pages[index]['color'].withValues(alpha: 0.1),
                                border: Border.all(color: _pages[index]['color'].withValues(alpha: 0.3), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: _pages[index]['color'].withValues(alpha: 0.2),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _pages[index]['icon'],
                                size: 80,
                                color: _pages[index]['color'],
                              ),
                            ),
                            const SizedBox(height: 64),
                            Text(
                              _pages[index]['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _pages[index]['description'],
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16, height: 1.6),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 32 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? _pages[_currentPage]['color'] : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: _currentPage == index ? [
                                BoxShadow(color: _pages[_currentPage]['color'].withValues(alpha: 0.5), blurRadius: 8)
                              ] : [],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
                            } else {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => const LoginScreen()));
                            }
                          },
                          child: Text(
                            _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
