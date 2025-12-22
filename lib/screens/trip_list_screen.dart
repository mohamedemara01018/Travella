import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/trip.dart';
import '../widgets/trip_card.dart';
import 'new_trip_screen.dart';
import 'trip_details_screen.dart';
import 'profile_screen.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      // 1. Static Custom App Bar
      appBar: _buildStaticAppBar(),
      // 2. Body is just the TabBarView
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTripsList(),
          _buildFavoritesList(),
          _buildPastTripsList(),
        ],
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ========================= STATIC APP BAR =========================

  PreferredSizeWidget _buildStaticAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 30,
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 80,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.blueGradientLight,
            ),
          ),
        ),
      ),
      title: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          'My Trips',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: Color.fromARGB(255, 228, 228, 228),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
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
                tabs: const [
                  Tab(text: 'Trips'),
                  Tab(text: 'Favorites'),
                  Tab(text: 'Finished'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================= FAB =========================

  Widget _buildFAB() {
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        icon: const Icon(Icons.add, color: AppTheme.accentBlue),
        label: const Text(
          'New Trip',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.accentBlue,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewTripScreen()),
          );
        },
      ),
    );
  }

  // ========================= BOTTOM NAV =========================

  Widget _buildBottomNav() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: BottomNavigationBar(
          backgroundColor: Colors.white.withOpacity(0.9),
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: AppTheme.textSecondary,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ========================= LISTS =========================

  Widget _buildAllTripsList() {
    final databaseService = Provider.of<DatabaseService>(context);

    return StreamBuilder<List<Trip>>(
      stream: databaseService.getTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBlue),
          );
        }

        final trips = snapshot.data ?? [];

        final upcoming = trips.where((t) =>
            t.status != 'completed' &&
            t.endDate.isAfter(DateTime.now())).toList();

        final completed =
            trips.where((t) => t.status == 'completed').toList();

        if (trips.isEmpty) {
          return _emptyState(
            icon: Icons.flight_takeoff,
            title: 'No trips yet',
            subtitle: 'Create your first trip to get started',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (upcoming.isNotEmpty) ...[
              _section('Upcoming'),
              const SizedBox(height: 12),
              ...upcoming.map(_tripTile),
              const SizedBox(height: 32),
            ],
            if (completed.isNotEmpty) ...[
              _section('Completed'),
              const SizedBox(height: 12),
              ...completed.map(_tripTile),
            ],
            const SizedBox(height: 120),
          ],
        );
      },
    );
  }

  Widget _buildFavoritesList() {
    final databaseService = Provider.of<DatabaseService>(context);

    return StreamBuilder<List<Trip>>(
      stream: databaseService.getFavoriteTrips(),
      builder: (context, snapshot) {
        final trips = snapshot.data ?? [];

        if (trips.isEmpty) {
          return _emptyState(
            icon: Icons.favorite_border,
            title: 'No favorites yet',
            subtitle: 'Heart a trip to save it',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...trips.map(_tripTile),
            const SizedBox(height: 120),
          ],
        );
      },
    );
  }

  Widget _buildPastTripsList() {
    final databaseService = Provider.of<DatabaseService>(context);

    return StreamBuilder<List<Trip>>(
      stream: databaseService.getTripsByStatus('completed'),
      builder: (context, snapshot) {
        final trips = snapshot.data ?? [];

        if (trips.isEmpty) {
          return _emptyState(
            icon: Icons.history,
            title: 'No completed trips',
            subtitle: 'Your past adventures will appear here',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...trips.map(_tripTile),
            const SizedBox(height: 120),
          ],
        );
      },
    );
  }

  // ========================= HELPERS =========================

  Widget _tripTile(Trip trip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(trip.id),
        direction: DismissDirection.endToStart, // Swipe Right to Left
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 28),
              SizedBox(height: 4),
              Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text("Delete Trip"),
                content: const Text("Are you sure you want to delete this trip? This action cannot be undone."),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          Provider.of<DatabaseService>(context, listen: false).deleteTrip(trip.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip deleted successfully'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: TripCard(
          trip: trip,
          onTap: () {
            // PASSING initialIndex: 0 IS WHAT CAUSED YOUR ERROR.
            // YOU MUST UPDATE TripDetailsScreen TO FIX IT.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TripDetailsScreen(tripId: trip.id, initialIndex: 0),
              ),
            );
          },
          onFavoriteTap: (isFav) {
            Provider.of<DatabaseService>(context, listen: false)
                .toggleFavorite(trip.id, isFav);
          },
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        letterSpacing: 1.3,
        fontWeight: FontWeight.w700,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppTheme.primaryBlue),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}