import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/activity.dart';
import '../models/trip.dart';
import '../widgets/activity_card.dart';

class ItineraryScreen extends StatefulWidget {
  final String tripId;
  const ItineraryScreen({super.key, required this.tripId});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _selectedDay = 1;

  // Colors matching TripNotesScreen
  final Color _textPrimary = const Color(0xFF0F172A);
  final Color _textSecondary = const Color(0xFF334155);
  final Color _textMuted = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Trip?>(
      stream: Provider.of<DatabaseService>(context).getTrip(widget.tripId),
      builder: (context, tripSnapshot) {
        if (!tripSnapshot.hasData || tripSnapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final trip = tripSnapshot.data!;
        final days = trip.endDate.difference(trip.startDate).inDays + 1;
        final dateFormat = DateFormat('d EEE');

        return StreamBuilder<List<Activity>>(
          stream: Provider.of<DatabaseService>(context)
              .getActivitiesByDay(widget.tripId, _selectedDay),
          builder: (context, snapshot) {
            final activities = snapshot.data ?? [];

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // --- SECTION 1: DAY SELECTOR ---
                    SliverToBoxAdapter(
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: days,
                          itemBuilder: (context, index) {
                            final dayNumber = index + 1;
                            final isSelected = _selectedDay == dayNumber;
                            final dayDate = trip.startDate.add(Duration(days: index));

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => setState(() => _selectedDay = dayNumber),
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: isSelected ? AppTheme.blueGradient : null,
                                    color: isSelected ? null : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.primaryBlue.withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Day $dayNumber',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.white : _textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFormat.format(dayDate).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white70 : _textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // --- SECTION 2: ACTIVITIES LIST (OR EMPTY STATE) ---
                    if (activities.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppTheme.blueGradientLight.scale(0.1),
                                  ),
                                  child: Icon(Icons.event_note, size: 40, color: AppTheme.primaryBlue.withOpacity(0.5)),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No activities for Day $_selectedDay',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add your first activity',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: _buildActivityItemFromModel(context, activities[index]),
                            );
                          },
                          childCount: activities.length,
                        ),
                      ),

                    // Bottom padding so FAB doesn't cover content
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityItemFromModel(BuildContext context, Activity activity) {
    return ActivityCard(
      activity: activity,
      onTap: () {
        _showActivityDetails(context, activity);
      },
      onEdit: () {
        _showEditActivityDialog(context, activity);
      },
      onDelete: () async {
        final databaseService = Provider.of<DatabaseService>(context, listen: false);
        final success = await databaseService.deleteActivity(activity.id);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Activity deleted'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
    );
  }

  // --- 1. DETAILS DIALOG (View Mode) ---
  void _showActivityDetails(BuildContext context, Activity activity) {
    final timeFormat = DateFormat('h:mm a');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  gradient: AppTheme.blueGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 16,
                      top: 16,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              activity.period,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 250,
                            child: Text(
                              activity.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: AppTheme.primaryBlue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          timeFormat.format(activity.time),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activity.location,
                            style: TextStyle(
                              fontSize: 16,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ),
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        (activity.description != null && activity.description!.isNotEmpty)
                            ? activity.description!
                            : "No additional notes provided for this activity.",
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: (activity.description != null && activity.description!.isNotEmpty)
                              ? _textSecondary
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. EDIT DIALOG (Fixed Visibility) ---
  void _showEditActivityDialog(BuildContext context, Activity activity) {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final titleController = TextEditingController(text: activity.title);
    final locationController = TextEditingController(text: activity.location);
    final descriptionController = TextEditingController(text: activity.description ?? '');
    String selectedPeriod = activity.period;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(activity.time);
    int selectedDay = activity.dayNumber;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Edit Activity',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: _textMuted),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: 'Location',
                  labelStyle: TextStyle(color: _textMuted),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: _textMuted),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: _textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              
              final now = DateTime.now();
              final updatedDateTime = DateTime(
                now.year,
                now.month,
                now.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              
              final updatedActivity = activity.copyWith(
                title: titleController.text.trim(),
                location: locationController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
                period: selectedPeriod,
                dayNumber: selectedDay,
                time: updatedDateTime,
              );
              
              final success = await databaseService.updateActivity(updatedActivity);
              
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Activity updated successfully!'),
                    backgroundColor: AppTheme.primaryBlue,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update activity'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}