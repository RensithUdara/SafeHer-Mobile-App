import 'package:get  static const String signup = '/signup';
  const String home = '/home';
  const String mainNavigation = '/mainNavigation';
  const String sos = '/sos';
  const String journey = '/journey';
  const String emergencyContacts = '/emergencyContacts';
  const String profile = '/profile';
  const String community = '/community';mport '../views/auth/login_screen.dart';
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
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String mainNavigation = '/main-navigation';
  static const String emergency = '/emergency';
  static const String sos = '/sos';
  static const String journey = '/journey';
  static const String journeyTracking = '/journey-tracking';
  static const String emergencyContacts = '/emergency-contacts';
  static const String addContact = '/add-contact';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String community = '/community';
  static const String reportIncident = '/report-incident';
  static const String safetyResources = '/safety-resources';
  static const String nearbyPlaces = '/nearby-places';

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
      page: () => const SignupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
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
      name: emergency,
      page: () => const EmergencyScreen(),
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
      name: journeyTracking,
      page: () => const JourneyTrackingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: emergencyContacts,
      page: () => const EmergencyContactsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: addContact,
      page: () => const AddContactScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: community,
      page: () => const CommunityScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: reportIncident,
      page: () => const ReportIncidentScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: safetyResources,
      page: () => const SafetyResourcesScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: nearbyPlaces,
      page: () => const NearbyPlacesScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
