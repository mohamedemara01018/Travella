import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'trip_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    print("⏳ Splash: Waiting for animation...");
    
    // 1. Force a delay (e.g., 3 seconds) for the animation/branding
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 2. Check if a user is ALREADY logged in via Firebase
    final user = FirebaseAuth.instance.currentUser;

    // 3. Navigate based on status
    if (user != null) {
      print("✅ Splash: User logged in (${user.email}) -> Going to Home");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TripListScreen()),
      );
    } else {
      print("🔒 Splash: No user -> Going to Login");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.elasticOut,
                builder: (context, scale, child) => Transform.scale(
                  scale: scale,
                  child: child,
                ),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.blueGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.4),
                      width: 2.5,
                    ),
                  ),
                child: const Icon(
                        Icons.flight_takeoff,
                        size: 40,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Travella',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.6,
                  shadows: [
                    Shadow(color: AppTheme.primaryBlue, blurRadius: 16),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Your journey starts here',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 224, 226, 228),
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 54),
              SizedBox(
                width: 220,
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.backgroundCardLight,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 28),
             
            ],
          ),
        ),
      ),
    );
  }
}