import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/activity.dart';
import '../models/trip.dart'; // Import Trip model

class AddActivityScreen extends StatefulWidget {
  final String tripId;
  final int? dayNumber;
  const AddActivityScreen({super.key, required this.tripId, this.dayNumber});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPeriod = 'Morning';
  TimeOfDay? _selectedTime;
  int _selectedDay = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.dayNumber != null) {
      _selectedDay = widget.dayNumber!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: AppTheme.primaryBlue,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Add Activity',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.blueGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Activity',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Plan your adventure',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Title Field
                _buildLabel('Activity Title'),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'e.g., Visit Eiffel Tower',
                    prefixIcon: Icon(Icons.event, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),

                // Location Field
                _buildLabel('Location'),
                TextField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'e.g., Champ de Mars',
                    prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),

                // --- DYNAMIC DAY SELECTOR ---
                _buildLabel('Day'),
                StreamBuilder<Trip?>(
                  stream: Provider.of<DatabaseService>(context, listen: false).getTrip(widget.tripId),
                  builder: (context, snapshot) {
                    // Default values while loading
                    int totalDays = 1;
                    bool isReady = snapshot.hasData && snapshot.data != null;

                    if (isReady) {
                      final trip = snapshot.data!;
                      // Calculate difference in days and add 1 to include the start date
                      totalDays = trip.endDate.difference(trip.startDate).inDays + 1;
                      if (totalDays < 1) totalDays = 1;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _selectedDay > totalDays ? 1 : _selectedDay,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixIcon: Icon(Icons.calendar_view_day, color: Colors.grey),
                        ),
                        // Generate list based on Trip duration
                        items: List.generate(totalDays, (index) => index + 1)
                            .map((day) => DropdownMenuItem(
                                  value: day,
                                  child: Text('Day $day'),
                                ))
                            .toList(),
                        onChanged: isReady ? (value) {
                          setState(() {
                            _selectedDay = value ?? 1;
                          });
                        } : null, // Disable until data is loaded
                        hint: !isReady ? const Text("Loading days...") : null,
                      ),
                    );
                  }
                ),
                const SizedBox(height: 24),

                // Time and Period Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Time'),
                          InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime ?? TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppTheme.primaryBlue,
                                        onSurface: Colors.black,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setState(() {
                                  _selectedTime = time;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedTime == null
                                        ? 'Select'
                                        : _selectedTime!.format(context),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedTime == null
                                          ? Colors.grey[400]
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Period'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedPeriod,
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black87, fontSize: 16),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              items: ['Morning', 'Afternoon', 'Evening', 'Night']
                                  .map((period) => DropdownMenuItem(
                                        value: period,
                                        child: Text(period),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPeriod = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description Field
                _buildLabel('Description (Optional)'),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Add notes about this activity...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Add Activity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _saveActivity() async {
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Combine date and time
    final now = DateTime.now();
    final activityDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final activity = Activity(
      id: '',
      tripId: widget.tripId,
      dayNumber: _selectedDay,
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      time: activityDateTime,
      period: _selectedPeriod,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      icon: 'event',
      createdAt: DateTime.now(),
    );

    final databaseService = Provider.of<DatabaseService>(context, listen: false);

    try {
      final activityId = await databaseService.createActivity(activity);

      setState(() => _isLoading = false);

      if (activityId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Activity added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}