import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/journey_controller.dart';
import '../../controllers/location_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/common_widgets.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journey Tracking'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer2<JourneyController, LocationController>(
          builder: (context, journeyController, locationController, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active Journey Card
                  _buildActiveJourneyCard(
                      journeyController, locationController),

                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildQuickActions(journeyController, locationController),

                  const SizedBox(height: 20),

                  // Journey History
                  _buildJourneyHistory(journeyController),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveJourneyCard(
    JourneyController journeyController,
    LocationController locationController,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: journeyController.hasActiveJourney
              ? [AppColors.info, AppColors.info.withOpacity(0.8)]
              : [AppColors.grey200, AppColors.grey100],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                journeyController.hasActiveJourney
                    ? Icons.navigation
                    : Icons.route,
                color: journeyController.hasActiveJourney
                    ? Colors.white
                    : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                journeyController.hasActiveJourney
                    ? 'Active Journey'
                    : 'No Active Journey',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: journeyController.hasActiveJourney
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (journeyController.hasActiveJourney)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          if (journeyController.hasActiveJourney) ...[
            // Journey Details
            _buildJourneyDetail(
              'Destination',
              journeyController.activeJourney?.endAddress ?? 'Unknown',
              Icons.location_on,
            ),
            const SizedBox(height: 10),
            _buildJourneyDetail(
              'Started',
              _formatTime(journeyController.activeJourney?.startTime),
              Icons.access_time,
            ),
            const SizedBox(height: 10),
            _buildJourneyDetail(
              'Expected Arrival',
              _formatTime(journeyController.activeJourney?.estimatedArrival),
              Icons.schedule,
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Complete',
                    onPressed: () => _completeJourney(journeyController),
                    backgroundColor: AppColors.safe,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    text: 'Extend Time',
                    onPressed: () => _extendJourneyTime(journeyController),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    textColor: Colors.white,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    text: 'Cancel',
                    onPressed: () => _cancelJourney(journeyController),
                    backgroundColor: AppColors.error,
                    height: 40,
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Start tracking your journey to keep your emergency contacts informed about your whereabouts.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Start New Journey',
              onPressed: () =>
                  _startNewJourney(journeyController, locationController),
              backgroundColor: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJourneyDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    JourneyController journeyController,
    LocationController locationController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.share_location,
                title: 'Share Location',
                subtitle: 'Share with contacts',
                color: AppColors.info,
                onTap: () => _shareCurrentLocation(locationController),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: 'View History',
                subtitle: 'Past journeys',
                color: AppColors.secondary,
                onTap: () => _showJourneyHistory(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.settings,
                title: 'Journey Settings',
                subtitle: 'Configure alerts',
                color: AppColors.warning,
                onTap: () => _showJourneySettings(journeyController),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                icon: Icons.help_outline,
                title: 'How it Works',
                subtitle: 'Learn more',
                color: AppColors.primary,
                onTap: () => _showHowItWorks(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyHistory(JourneyController journeyController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Journeys',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => _showJourneyHistory(),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (journeyController.journeyHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: AppColors.grey400,
                ),
                SizedBox(height: 15),
                Text(
                  'No journey history yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your completed journeys will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...journeyController.journeyHistory.take(3).map((journey) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(journey.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(journey.status),
                      color: _getStatusColor(journey.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journey.endAddress ?? 'Unknown destination',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatJourneyDate(journey.startTime),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _getStatusText(journey.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(journey.status),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // Helper methods
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatJourneyDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Color _getStatusColor(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.completed:
        return AppColors.safe;
      case JourneyStatus.cancelled:
        return AppColors.error;
      case JourneyStatus.overdue:
        return AppColors.warning;
      case JourneyStatus.alert:
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'overdue':
        return Icons.warning;
      default:
        return Icons.navigation;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'overdue':
        return 'Overdue';
      default:
        return 'Active';
    }
  }

  // Action methods
  void _startNewJourney(
    JourneyController journeyController,
    LocationController locationController,
  ) {
    final startLocationController = TextEditingController();
    final endLocationController = TextEditingController();
    DateTime selectedDateTime = DateTime.now().add(const Duration(hours: 1));
    JourneyType selectedType = JourneyType.walking;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Start New Journey'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: startLocationController,
                  label: 'From',
                  hint: locationController.currentAddress.isNotEmpty
                      ? 'Current location'
                      : 'Enter starting location',
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: endLocationController,
                  label: 'To',
                  hint: 'Enter destination',
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<JourneyType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Journey Type',
                    border: OutlineInputBorder(),
                  ),
                  items: JourneyType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last.capitalize!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 15),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Expected Arrival'),
                  subtitle: Text(_formatTime(selectedDateTime)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (time != null) {
                      setState(() {
                        selectedDateTime = DateTime(
                          selectedDateTime.year,
                          selectedDateTime.month,
                          selectedDateTime.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            AppButton(
              text: 'Start Journey',
              onPressed: () {
                if (endLocationController.text.isNotEmpty) {
                  journeyController.startJourney(
                    startLocation: startLocationController.text.isNotEmpty
                        ? startLocationController.text
                        : 'Current Location',
                    endLocation: endLocationController.text,
                    expectedArrivalTime: selectedDateTime,
                    journeyType: selectedType,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _completeJourney(JourneyController journeyController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Journey'),
        content: const Text('Are you sure you want to complete this journey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          AppButton(
            text: 'Complete',
            onPressed: () {
              journeyController.completeJourney();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _extendJourneyTime(JourneyController journeyController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extend Journey Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How much time do you need?'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeExtensionButton('15 min', () {
                  journeyController
                      .extendJourneyTime(const Duration(minutes: 15));
                  Navigator.of(context).pop();
                }),
                _buildTimeExtensionButton('30 min', () {
                  journeyController
                      .extendJourneyTime(const Duration(minutes: 30));
                  Navigator.of(context).pop();
                }),
                _buildTimeExtensionButton('1 hour', () {
                  journeyController.extendJourneyTime(const Duration(hours: 1));
                  Navigator.of(context).pop();
                }),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeExtensionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text),
    );
  }

  void _cancelJourney(JourneyController journeyController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Journey'),
        content: const Text('Are you sure you want to cancel this journey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          AppButton(
            text: 'Yes, Cancel',
            backgroundColor: AppColors.error,
            onPressed: () {
              journeyController.cancelJourney();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _shareCurrentLocation(LocationController locationController) {
    // Implementation for sharing current location
    Get.toNamed('/location-sharing');
  }

  void _showJourneyHistory() {
    Get.toNamed('/journey-history');
  }

  void _showJourneySettings(JourneyController journeyController) {
    // Implementation for journey settings
    Get.toNamed('/journey-settings');
  }

  void _showHowItWorks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How Journey Tracking Works'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Start a Journey',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Enter your destination and expected arrival time.'),
              SizedBox(height: 10),
              Text(
                '2. Live Tracking',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'Your location is tracked and shared with emergency contacts.'),
              SizedBox(height: 10),
              Text(
                '3. Safety Alerts',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'Automatic alerts if you\'re overdue or deviate from route.'),
              SizedBox(height: 10),
              Text(
                '4. Complete Journey',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Mark journey as complete when you arrive safely.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
