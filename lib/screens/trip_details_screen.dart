import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/trip.dart';
import 'itinerary_screen.dart';
import 'trip_notes_screen.dart' as tripnotes;
import 'trip_budget_screen.dart';
import 'add_activity_screen.dart';
import 'add_expense_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final String? tripId;
  final int initialIndex; // 👈 1. Added parameter

  const TripDetailsScreen({
    super.key,
    this.tripId,
    this.initialIndex = 0, // 👈 2. Default to 0 (Itinerary)
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 👈 3. Set the starting tab based on what was passed
    _tabController = TabController(
      length: 3, 
      vsync: this, 
      initialIndex: widget.initialIndex 
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleFABPress() {
    final tripId = widget.tripId ?? '';

    if (_tabController.index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddActivityScreen(tripId: tripId),
        ),
      );
    } else if (_tabController.index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddExpenseScreen(tripId: tripId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Use the Quick Note form above to add notes'),
          backgroundColor: AppTheme.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. Static Custom App Bar
      appBar: _buildStaticAppBar(),
      // 2. Body is just the TabBarView
      body: TabBarView(
        controller: _tabController,
        children: [
          ItineraryScreen(tripId: widget.tripId ?? ''),
          tripnotes.TripNotesScreen(tripId: widget.tripId ?? ''),
          TripBudgetScreen(tripId: widget.tripId ?? ''),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ========================= STATIC APP BAR =========================

  PreferredSizeWidget _buildStaticAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(240),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.blueGradientLight,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Back Button ---
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              const Spacer(), 
              
              // --- 2. Trip Info (Title & Chips) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _tripHeader(),
              ),
              
              const SizedBox(height: 20),

              // --- 3. Tab Bar (Pill Shape) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    labelColor: AppTheme.primaryBlue,
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'Itinerary'),
                      Tab(text: 'Notes'),
                      Tab(text: 'Budget'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================= HEADER INFO =========================

  Widget _tripHeader() {
    if (widget.tripId == null) return const SizedBox();

    return StreamBuilder<Trip?>(
      stream: Provider.of<DatabaseService>(context).getTrip(widget.tripId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox(
             height: 60, 
             child: Center(child: CircularProgressIndicator(color: Colors.white))
          );
        }

        final trip = snapshot.data!;
        final dateFormat = DateFormat('MMM d');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trip.destination,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _infoChip(
                  Icons.calendar_today,
                  '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                ),
                _infoChip(
                  Icons.account_balance_wallet,
                  'Budget \$${trip.budget.toStringAsFixed(0)}',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ========================= FAB =========================

  Widget? _buildFAB() {
    if (_tabController.index == 1) return null; // No FAB for Notes tab

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        elevation: 0,
        backgroundColor: Colors.white,
        icon: const Icon(Icons.add, color: AppTheme.accentBlue),
        label: Text(
          _tabController.index == 0 ? 'Add Activity' : 'Add Expense',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.accentBlue,
          ),
        ),
        onPressed: _handleFABPress,
      ),
    );
  }
}