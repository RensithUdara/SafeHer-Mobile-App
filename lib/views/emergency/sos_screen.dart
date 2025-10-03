import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/emergency_controller.dart';
import '../../controllers/location_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/common_widgets.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  final bool _isCountdownActive = false;
  final int _countdown = 10;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.emergency,
      body: SafeArea(
        child: Consumer2<EmergencyController, LocationController>(
          builder: (context, emergencyController, locationController, child) {
            return Column(
              children: [
                // Header
                _buildHeader(context, emergencyController),

                // Main SOS Button Area
                Expanded(
                  child: _buildSOSButtonArea(
                    context,
                    emergencyController,
                    locationController,
                    size,
                  ),
                ),

                // Emergency Options
                _buildEmergencyOptions(context, emergencyController),

                // Bottom Section
                _buildBottomSection(context, emergencyController),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, EmergencyController emergencyController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emergencyController.isEmergencyActive
                      ? 'EMERGENCY ACTIVE'
                      : 'EMERGENCY SOS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  emergencyController.isEmergencyActive
                      ? 'Help is on the way'
                      : 'Tap the button if you need help',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: emergencyController.isEmergencyActive
                  ? Colors.red
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              emergencyController.isEmergencyActive ? 'ACTIVE' : 'READY',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButtonArea(
    BuildContext context,
    EmergencyController emergencyController,
    LocationController locationController,
    Size size,
  ) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location Status
          if (locationController.currentAddress.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Current Location:\n${locationController.currentAddress}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // SOS Button with Ripple Effect
          Stack(
            alignment: Alignment.center,
            children: [
              // Ripple Effects
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _rippleAnimation.value * (1 + index * 0.3),
                      child: Container(
                        width: size.width * 0.6,
                        height: size.width * 0.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              (1 - _rippleAnimation.value) * 0.5,
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Main SOS Button
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: emergencyController.isEmergencyActive
                        ? _pulseAnimation.value
                        : 1.0,
                    child: GestureDetector(
                      onTap: () => _handleSOSPress(emergencyController),
                      onLongPress: () =>
                          _handleSOSLongPress(emergencyController),
                      child: Container(
                        width: size.width * 0.5,
                        height: size.width * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: emergencyController.isEmergencyActive
                              ? Colors.red
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (emergencyController.isCountdownActive) ...[
                              // Countdown Display
                              Text(
                                '${emergencyController.emergencyCallCountdown}',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: emergencyController.isEmergencyActive
                                      ? Colors.white
                                      : AppColors.emergency,
                                ),
                              ),
                              Text(
                                'CALLING...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: emergencyController.isEmergencyActive
                                      ? Colors.white70
                                      : AppColors.emergency,
                                ),
                              ),
                            ] else ...[
                              // SOS Icon
                              Icon(
                                emergencyController.isEmergencyActive
                                    ? Icons.stop
                                    : Icons.warning,
                                size: 60,
                                color: emergencyController.isEmergencyActive
                                    ? Colors.white
                                    : AppColors.emergency,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                emergencyController.isEmergencyActive
                                    ? 'STOP'
                                    : 'SOS',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: emergencyController.isEmergencyActive
                                      ? Colors.white
                                      : AppColors.emergency,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Instructions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        emergencyController.isEmergencyActive
                            ? 'Tap to stop emergency alert'
                            : 'Tap to send emergency alert',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!emergencyController.isEmergencyActive) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.gesture,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hold for 3 seconds to auto-call emergency services',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyOptions(
      BuildContext context, EmergencyController emergencyController) {
    if (emergencyController.isEmergencyActive) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              icon: Icons.phone,
              label: 'Call 911',
              onTap: () => _callEmergencyServices(),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildQuickAction(
              icon: Icons.message,
              label: 'Send SMS',
              onTap: () => _sendEmergencySMS(emergencyController),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildQuickAction(
              icon: Icons.location_on,
              label: 'Share Location',
              onTap: () => _shareLocation(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(
      BuildContext context, EmergencyController emergencyController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Emergency Contacts Status
          if (emergencyController.emergencyContacts.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.contacts,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${emergencyController.emergencyContacts.length} emergency contacts will be notified',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (emergencyController.emergencyContacts.isEmpty)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No emergency contacts added. Add contacts for better safety.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/emergency-contacts'),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Cancel Button (if countdown is active)
          if (emergencyController.isCountdownActive)
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Cancel Emergency Call',
                onPressed: () =>
                    emergencyController.cancelEmergencyCallCountdown(),
                backgroundColor: Colors.white.withOpacity(0.2),
                textColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _handleSOSPress(EmergencyController emergencyController) {
    HapticFeedback.heavyImpact();

    if (emergencyController.isEmergencyActive) {
      _showStopEmergencyDialog(emergencyController);
    } else {
      _showSOSConfirmationDialog(emergencyController);
    }
  }

  void _handleSOSLongPress(EmergencyController emergencyController) {
    if (!emergencyController.isEmergencyActive) {
      HapticFeedback.heavyImpact();
      emergencyController.activateEmergency();
    }
  }

  void _showSOSConfirmationDialog(EmergencyController emergencyController) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.emergency),
            SizedBox(width: 10),
            Text('Emergency Alert'),
          ],
        ),
        content: const Text(
          'This will send an emergency alert to your contacts and may contact emergency services. Are you sure?',
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
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  void _showStopEmergencyDialog(EmergencyController emergencyController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.safe),
            SizedBox(width: 10),
            Text('Stop Emergency'),
          ],
        ),
        content: const Text(
          'Are you safe now? This will stop the emergency alert and notify your contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              emergencyController.deactivateEmergency();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.safe,
            ),
            child: const Text('Yes, I\'m Safe'),
          ),
        ],
      ),
    );
  }

  void _callEmergencyServices() {
    // Implementation for calling emergency services
    HapticFeedback.mediumImpact();
    // Add your emergency call logic here
  }

  void _sendEmergencySMS(EmergencyController emergencyController) {
    // Implementation for sending emergency SMS
    HapticFeedback.mediumImpact();
    // Add your SMS sending logic here
  }

  void _shareLocation() {
    // Implementation for sharing location
    HapticFeedback.mediumImpact();
    Get.toNamed('/location-sharing');
  }
}
