import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/trip.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  // Controllers
  final _destinationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  
  // State Variables
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FORCE LIGHT THEME WRAPPER
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: AppTheme.primaryBlue,
        colorScheme: const ColorScheme.light(
          primary: AppTheme.primaryBlue,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // Black text & icons
          elevation: 0,
        ),
        // Global Input Style for this screen
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50], // Light grey background
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
            'New Trip',
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
                // --- DESTINATION ---
                _buildLabel('Where to?'),
                TextField(
                  controller: _destinationController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Enter destination (e.g. Kyoto)',
                    prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),

                // --- DATES ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Date'),
                          TextField(
                            controller: _startDateController,
                            readOnly: true,
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(
                              hintText: 'mm/dd/yyyy',
                              prefixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey),
                            ),
                            onTap: () => _selectDate(true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('End Date'),
                          TextField(
                            controller: _endDateController,
                            readOnly: true,
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(
                              hintText: 'mm/dd/yyyy',
                              prefixIcon: Icon(Icons.event_outlined, color: Colors.grey),
                            ),
                            onTap: () => _selectDate(false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- BUDGET ---
                _buildLabel('Budget'),
                TextField(
                  controller: _budgetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),

                // --- DESCRIPTION ---
                _buildLabel('Description (Optional)'),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Add notes about goals, ideas, or bucket list items...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 40),

                // --- CREATE BUTTON ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createTrip,
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
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create Trip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for Labels
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

  // Date Selection Logic
  Future<void> _selectDate(bool isStart) async {
    final now = DateTime.now();
    final firstDate = isStart ? now : (_startDate ?? now);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = DateFormat('MM/dd/yyyy').format(picked);
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
            _endDateController.clear();
          }
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('MM/dd/yyyy').format(picked);
        }
      });
    }
  }

  // Create Trip Logic
  Future<void> _createTrip() async {
    // 1. Validation
    if (_destinationController.text.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in destination and dates'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isLoading = true);

    // 2. Prepare Data
    final budget = double.tryParse(_budgetController.text) ?? 0.0;
    final destination = _destinationController.text.trim();

    final trip = Trip(
      id: '',
      title: destination,
      destination: destination,
      startDate: _startDate!,
      endDate: _endDate!,
      budget: budget,
      status: 'upcoming', 
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      travelers: [], // Empty travelers list
      createdAt: DateTime.now(),
      // userId is handled by DatabaseService
    );

    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final tripId = await databaseService.createTrip(trip);

      if (mounted) {
        if (tripId != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ Trip created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pop(context);
        } else {
          throw Exception('Database returned null ID');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create trip: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}