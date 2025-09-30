import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import '../utils/routes.dart';
import '../utils/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: Icons.shield_outlined,
      title: 'Your Personal Safety Guardian',
      description:
          'SafeHer is designed to keep you safe during your daily travels. With one-tap emergency alerts and real-time location sharing.',
      backgroundColor: AppColors.primary,
    ),
    OnboardingPage(
      image: Icons.emergency_outlined,
      title: 'Instant SOS Emergency Alert',
      description:
          'One tap to alert your emergency contacts and authorities. Automatic location sharing and voice recording for evidence.',
      backgroundColor: AppColors.error,
    ),
    OnboardingPage(
      image: Icons.location_on_outlined,
      title: 'Live Journey Tracking',
      description:
          'Share your real-time location with trusted contacts. Get alerts if you deviate from your route or don\'t reach safely.',
      backgroundColor: AppColors.info,
    ),
    OnboardingPage(
      image: Icons.people_outline,
      title: 'Trusted Emergency Contacts',
      description:
          'Add your family and friends as emergency contacts. They\'ll be notified instantly if you need help.',
      backgroundColor: AppColors.success,
    ),
    OnboardingPage(
      image: Icons.security_outlined,
      title: 'Community Safety Features',
      description:
          'Report unsafe areas, view community alerts, and access safety resources. Together we create safer communities.',
      backgroundColor: AppColors.secondary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isFirstLaunch, false);
    Get.offNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Skip Button (top right)
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 50,
              right: 20,
              child: SafeArea(
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicators(),
                    ),

                    const SizedBox(height: 30),

                    // Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous Button
                        if (_currentPage > 0)
                          TextButton(
                            onPressed: _previousPage,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios,
                                  size: 16,
                                  color: AppColors.grey600,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Previous',
                                  style: TextStyle(
                                    color: AppColors.grey600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Next/Get Started Button
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _pages[_currentPage].backgroundColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            page.backgroundColor,
            page.backgroundColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Image/Icon
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  page.image,
                  size: 100,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 60),

              // Title
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 30),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicators() {
    return List.generate(
      _pages.length,
      (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: _currentPage == index ? 20 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: _currentPage == index
              ? _pages[_currentPage].backgroundColor
              : AppColors.grey300,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData image;
  final String title;
  final String description;
  final Color backgroundColor;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });
}
