import 'package:get/get.dart';

import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/community/community_screen.dart';
import '../views/contacts/emergency_contacts_screen.dart';
import '../views/emergency/sos_screen.dart';
import '../views/home/home_screen.dart';
import '../views/home/main_navigation_screen.dart';
import '../views/journey/journey_screen.dart';
import '../views/onboarding_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/splash_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String mainNavigation = '/main-navigation';
  static const String sos = '/sos';
  static const String journey = '/journey';
  static const String emergencyContacts = '/emergency-contacts';
  static const String profile = '/profile';
  static const String community = '/community';

  // Route pages
  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: signup,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: mainNavigation,
      page: () => const MainNavigationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: sos,
      page: () => const SOSScreen(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: journey,
      page: () => const JourneyScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: emergencyContacts,
      page: () => const EmergencyContactsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: community,
      page: () => const CommunityScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
