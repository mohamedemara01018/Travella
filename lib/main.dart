import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== INITIALIZING FIREBASE ===');
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  print('=== STARTING APP ===');
  runApp(const WanderlustApp());
}

class WanderlustApp extends StatelessWidget {
  const WanderlustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme, // Or AppTheme.lightTheme depending on your preference
        // 👇 CRITICAL: Always start with SplashScreen. No AuthWrapper here.
        home: const SplashScreen(),
      ),
    );
  }
}