import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/emergency_controller.dart';
import '../../controllers/journey_controller.dart';
import '../../controllers/location_controller.dart';
import '../../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  Future<void> _initializeServices() async {
    final locationController =
        Provider.of<LocationController>(context, listen: false);
    if (!locationController.locationPermissionGranted) {
      await locationController.getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:
            Consumer3<AuthController, LocationController, EmergencyController>(
          builder: (context, authController, locationController,
              emergencyController, child) {
            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primaryDark,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background Pattern
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.1,
                              child: Image.asset(
                                'assets/images/pattern_bg.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(),
                              ),
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    // Profile Picture
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.white,
                                      child: authController.currentUserModel
                                                  ?.profilePhotoPath !=
                                              null
                                          ? CachedNetworkImage(
                                              imageUrl: authController
                                                  .currentUserModel!
                                                  .profilePhotoPath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const Icon(Icons.person,
                                              color: AppColors.primary,
                                              size: 30),
                                    ),

                                    const SizedBox(width: 15),

                                    // Greeting
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getGreeting(),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            authController
                                                    .currentUserModel?.name ??
                                                'User',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Notification Bell
                                    IconButton(
                                      onPressed: () {
                                        // Navigate to notifications
                                      },
                                      icon: const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                // Location Status
                                Row(
                                  children: [
                                    Icon(
                                      locationController
                                              .locationPermissionGranted
                                          ? Icons.location_on
                                          : Icons.location_off,
                                      color: locationController
                                              .locationPermissionGranted
                                          ? AppColors.safe
                                          : AppColors.warning,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        locationController
                                                .currentAddress.isNotEmpty
                                            ? locationController.currentAddress
                                            : 'Location unavailable',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Content
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Emergency Status Card
                      _buildEmergencyStatusCard(emergencyController),

                      const SizedBox(height: 20),

                      // Quick Actions
                      _buildQuickActions(context),

                      const SizedBox(height: 20),

                      // Safety Features
                      _buildSafetyFeatures(context),

                      const SizedBox(height: 20),

                      // Journey Status
                      _buildJourneyStatus(context),

                      const SizedBox(height: 20),

                      // Emergency Contacts Quick Access
                      _buildEmergencyContacts(emergencyController),

                      const SizedBox(height: 20),

                      // Safety Tips
                      _buildSafetyTips(),

                      const SizedBox(height: 100), // Bottom padding for FAB
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // Floating Action Button - SOS Button
      floatingActionButton: Consumer<EmergencyController>(
        builder: (context, emergencyController, child) {
          return AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: emergencyController.isEmergencyActive
                    ? _pulseAnimation.value
                    : 1.0,
                child: FloatingActionButton.extended(
                  onPressed: () =>
                      _showEmergencyDialog(context, emergencyController),
                  backgroundColor: emergencyController.isEmergencyActive
                      ? AppColors.error
                      : AppColors.emergency,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  icon: Icon(
                    emergencyController.isEmergencyActive
                        ? Icons.stop
                        : Icons.warning,
                    size: 24,
                  ),
                  label: Text(
                    emergencyController.isEmergencyActive ? 'STOP SOS' : 'SOS',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildEmergencyStatusCard(EmergencyController emergencyController) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: emergencyController.isEmergencyActive
            ? AppColors.emergencyLight
            : AppColors.safeLight,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: emergencyController.isEmergencyActive
              ? AppColors.emergency
              : AppColors.safe,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            emergencyController.isEmergencyActive
                ? Icons.warning
                : Icons.shield,
            color: emergencyController.isEmergencyActive
                ? AppColors.emergency
                : AppColors.safe,
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emergencyController.isEmergencyActive
                      ? 'Emergency Active'
                      : 'You\'re Safe',
                  style: TextStyle(
                    color: emergencyController.isEmergencyActive
                        ? AppColors.emergency
                        : AppColors.safe,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  emergencyController.isEmergencyActive
                      ? 'Emergency services notified'
                      : 'All systems operational',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        SlideTransition(
          position: _slideAnimation,
          child: Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.location_on,
                  title: 'Share Location',
                  color: AppColors.info,
                  onTap: () => Get.toNamed('/location-sharing'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.phone,
                  title: 'Fake Call',
                  color: AppColors.warning,
                  onTap: () => _triggerFakeCall(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Safety Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
          children: [
            _buildFeatureCard(
              icon: Icons.route,
              title: 'Journey Tracking',
              subtitle: 'Track your route',
              onTap: () => Get.toNamed('/journey'),
            ),
            _buildFeatureCard(
              icon: Icons.people,
              title: 'Emergency Contacts',
              subtitle:
                  '${context.read<EmergencyController>().emergencyContacts.length} contacts',
              onTap: () => Get.toNamed('/emergency-contacts'),
            ),
            _buildFeatureCard(
              icon: Icons.map,
              title: 'Safe Places',
              subtitle: 'Find nearby help',
              onTap: () => Get.toNamed('/nearby-places'),
            ),
            _buildFeatureCard(
              icon: Icons.group,
              title: 'Community',
              subtitle: 'Report incidents',
              onTap: () => Get.toNamed('/community'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyStatus(BuildContext context) {
    return Consumer<JourneyController>(
      builder: (context, journeyController, child) {
        if (!journeyController.hasActiveJourney) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.info, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.navigation,
                    color: AppColors.info,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Active Journey',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'To: ${journeyController.activeJourney?.endAddress ?? 'Unknown'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed('/journey-tracking'),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Journey'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => journeyController.completeJourney(),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.safe,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmergencyContacts(EmergencyController emergencyController) {
    if (emergencyController.emergencyContacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.warning, width: 1),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.person_add,
              color: AppColors.warning,
              size: 40,
            ),
            const SizedBox(height: 10),
            const Text(
              'No Emergency Contacts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Add emergency contacts for better safety',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => Get.toNamed('/add-contact'),
              child: const Text('Add Contact'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/emergency-contacts'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: emergencyController.emergencyContacts.take(5).length,
            itemBuilder: (context, index) {
              final contact = emergencyController.emergencyContacts[index];
              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 15),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          emergencyController.callEmergencyContact(contact),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          contact.contactName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      contact.contactName,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTips() {
    final tips = [
      'Always inform someone about your travel plans',
      'Keep emergency contacts updated',
      'Trust your instincts in unsafe situations',
      'Stay in well-lit, populated areas at night',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Safety Tips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: tips
                .map((tip) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  void _showEmergencyDialog(
      BuildContext context, EmergencyController emergencyController) {
    if (emergencyController.isEmergencyActive) {
      // Stop emergency
      emergencyController.deactivateEmergency();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert'),
        content: const Text(
          'Are you sure you want to trigger an emergency alert? This will notify your emergency contacts and may contact emergency services.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              emergencyController.activateEmergency();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergency,
            ),
            child: const Text('Trigger SOS'),
          ),
        ],
      ),
    );
  }

  void _triggerFakeCall() {
    // Implement fake call functionality
    Get.toNamed('/fake-call');
  }
}
