import 'package:get/get.dart';import 'package:get  static const String signup = '/signup';

  const String home = '/home';

import '../views/auth/login_screen.dart';  const String mainNavigation = '/mainNavigation';

import '../views/auth/register_screen.dart';  const String sos = '/sos';

import '../views/community/community_screen.dart';  const String journey = '/journey';

import '../views/contacts/emergency_contacts_screen.dart';  const String emergencyContacts = '/emergencyContacts';

import '../views/emergency/sos_screen.dart';  const String profile = '/profile';

import '../views/home/home_screen.dart';  const String community = '/community';mport '../views/auth/login_screen.dart';

import '../views/home/main_navigation_screen.dart';import '../views/auth/register_screen.dart';

import '../views/journey/journey_screen.dart';import '../views/community/community_screen.dart';

import '../views/onboarding_screen.dart';import '../views/contacts/emergency_contacts_screen.dart';

import '../views/profile/profile_screen.dart';import '../views/emergency/sos_screen.dart';

import '../views/splash_screen.dart';import '../views/home/home_screen.dart';

import '../views/home/main_navigation_screen.dart';

class AppRoutes {import '../views/journey/journey_screen.dart';

  // Route namesimport '../views/onboarding_screen.dart';

  static const String splash = '/splash';import '../views/profile/profile_screen.dart';

  static const String onboarding = '/onboarding';import '../views/splash_screen.dart';

  static const String login = '/login';

  static const String signup = '/signup';class AppRoutes {

  static const String home = '/home';  // Route names

  static const String mainNavigation = '/main-navigation';  static const String splash = '/splash';

  static const String sos = '/sos';  static const String onboarding = '/onboarding';

  static const String journey = '/journey';  static const String login = '/login';

  static const String emergencyContacts = '/emergency-contacts';  static const String signup = '/signup';

  static const String profile = '/profile';  static const String forgotPassword = '/forgot-password';

  static const String community = '/community';  static const String home = '/home';

  static const String mainNavigation = '/main-navigation';

  // Route pages  static const String emergency = '/emergency';

  static List<GetPage> pages = [  static const String sos = '/sos';

    GetPage(  static const String journey = '/journey';

      name: splash,  static const String journeyTracking = '/journey-tracking';

      page: () => const SplashScreen(),  static const String emergencyContacts = '/emergency-contacts';

      transition: Transition.fade,  static const String addContact = '/add-contact';

    ),  static const String profile = '/profile';

    GetPage(  static const String settings = '/settings';

      name: onboarding,  static const String community = '/community';

      page: () => const OnboardingScreen(),  static const String reportIncident = '/report-incident';

      transition: Transition.rightToLeft,  static const String safetyResources = '/safety-resources';

    ),  static const String nearbyPlaces = '/nearby-places';

    GetPage(

      name: login,  // Route pages

      page: () => const LoginScreen(),  static List<GetPage> pages = [

      transition: Transition.rightToLeft,    GetPage(

    ),      name: splash,

    GetPage(      page: () => const SplashScreen(),

      name: signup,      transition: Transition.fade,

      page: () => const RegisterScreen(),    ),

      transition: Transition.rightToLeft,    GetPage(

    ),      name: onboarding,

    GetPage(      page: () => const OnboardingScreen(),

      name: home,      transition: Transition.rightToLeft,

      page: () => const HomeScreen(),    ),

      transition: Transition.fadeIn,    GetPage(

    ),      name: login,

    GetPage(      page: () => const LoginScreen(),

      name: mainNavigation,      transition: Transition.rightToLeft,

      page: () => const MainNavigationScreen(),    ),

      transition: Transition.fadeIn,    GetPage(

    ),      name: signup,

    GetPage(      page: () => const SignupScreen(),

      name: sos,      transition: Transition.rightToLeft,

      page: () => const SOSScreen(),    ),

      transition: Transition.zoom,    GetPage(

    ),      name: forgotPassword,

    GetPage(      page: () => const ForgotPasswordScreen(),

      name: journey,      transition: Transition.rightToLeft,

      page: () => const JourneyScreen(),    ),

      transition: Transition.rightToLeft,    GetPage(

    ),      name: home,

    GetPage(      page: () => const HomeScreen(),

      name: emergencyContacts,      transition: Transition.fadeIn,

      page: () => const EmergencyContactsScreen(),    ),

      transition: Transition.rightToLeft,    GetPage(

    ),      name: mainNavigation,

    GetPage(      page: () => const MainNavigationScreen(),

      name: profile,      transition: Transition.fadeIn,

      page: () => const ProfileScreen(),    ),

      transition: Transition.rightToLeft,    GetPage(

    ),      name: emergency,

    GetPage(      page: () => const EmergencyScreen(),

      name: community,      transition: Transition.fadeIn,

      page: () => const CommunityScreen(),    ),

      transition: Transition.rightToLeft,    GetPage(

    ),      name: sos,

  ];      page: () => const SOSScreen(),

}      transition: Transition.zoom,
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
