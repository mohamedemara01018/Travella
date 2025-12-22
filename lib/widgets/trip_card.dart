import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../theme/app_theme.dart';
import '../screens/trip_details_screen.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final Function(bool)? onFavoriteTap;
  
  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    final isCompleted = trip.status == 'completed';
    final isUpcoming = trip.status != 'completed' && trip.endDate.isAfter(DateTime.now());
    final statusText = isCompleted ? 'COMPLETED' : (isUpcoming ? 'UPCOMING' : 'DRAFT');

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: isUpcoming
              ? AppTheme.blueGradient
              : AppTheme.blueGradientLight,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.18),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.12),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ROW ---
                Row(
                  children: [
                    // Icon/Image placeholder
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: AppTheme.blueGradientLight,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.25),
                            blurRadius: 16,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_city,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 18),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.destination,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.4,
                              shadows: [
                                Shadow(
                                  color: AppTheme.primaryBlue,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color.fromARGB(255, 238, 238, 238).withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Favorite and chevron
                    GestureDetector(
                      onTap: () => onFavoriteTap?.call(!trip.isFavorite),
                      child: AnimatedSwitcher(  
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          trip.isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(trip.isFavorite),
                          color: trip.isFavorite ? AppTheme.accentBlue : const Color.fromARGB(255, 238, 238, 238).withOpacity(0.8),
                          size: 26,
                          shadows: trip.isFavorite
                              ? [Shadow(color: AppTheme.accentBlue.withOpacity(0.5), blurRadius: 12)]
                              : [],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppTheme.accentBlue, size: 22),
                  ],
                ),
                const SizedBox(height: 16),
                
                // --- FOOTER ROW (Status Badge & Quick Actions) ---
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isCompleted
                          ? null
                          : AppTheme.blueGradientLight,
                        color: isCompleted
                          ? AppTheme.textHint.withOpacity(0.18)
                          : null,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCompleted
                              ? AppTheme.textHint.withOpacity(0.25)
                              : const Color.fromARGB(255, 255, 255, 255).withOpacity(0.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? AppTheme.textSecondary
                              : const Color.fromARGB(255, 255, 255, 255),
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    
                    if (isUpcoming) ...[
                      const Spacer(),
                      // Wallet Icon -> Opens Budget (Index 2)
                      _buildQuickActionButton(
                        context, 
                        Icons.account_balance_wallet_outlined, 
                        2
                      ),
                      const SizedBox(width: 8),
                      
                      // Calendar Icon -> Opens Itinerary (Index 0)
                      _buildQuickActionButton(
                        context, 
                        Icons.calendar_today_outlined, 
                        0
                      ),
                      const SizedBox(width: 8),
                      
                      // Notes Icon -> Opens Notes (Index 1)
                      _buildQuickActionButton(
                        context, 
                        Icons.description_outlined, // 👈 CHANGED ICON HERE
                        1
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method: Creates clickable, bigger buttons
  Widget _buildQuickActionButton(BuildContext context, IconData icon, int tabIndex) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TripDetailsScreen(
                tripId: trip.id,
                initialIndex: tabIndex, // Opens specific tab
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppTheme.blueGradientLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.12),
                blurRadius: 8,
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 6,
              )
            ],
          ),
        ),
      ),
    );
  }
}