import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'trip_list_screen.dart';
import 'login_screen.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  bool _initialDataLoaded = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // --- SAVE FUNCTION ---
  Future<void> _saveAllChanges() async {
    setState(() => _isSaving = true);

    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;
    
    try {
      final newName = _nameController.text.trim();

      // 1. Update Firebase Authentication Display Name
      if (currentUser != null && newName.isNotEmpty && newName != currentUser.displayName) {
        await currentUser.updateDisplayName(newName);
        await currentUser.reload(); 
      }

      // 2. Update Firestore Database
      await databaseService.updateUserProfile({
        'name': newName,
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          // FIX: This ensures the scroll tint is Blue, not the default Purple
          surfaceTintColor: AppTheme.primaryBlue, 
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
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
          disabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: BorderSide(color: Colors.grey[200]!),
          ),
        ),
      ),
      child: StreamBuilder<UserProfile?>(
        stream: databaseService.getUserProfile(),
        builder: (context, snapshot) {
          // Data Loading Logic
          if (!_initialDataLoaded && snapshot.connectionState == ConnectionState.active) {
            final data = snapshot.data;
            
            _nameController.text = data?.name.isNotEmpty == true ? data!.name : (currentUser?.displayName ?? '');
            _emailController.text = data?.email.isNotEmpty == true ? data!.email : (currentUser?.email ?? '');
            _phoneController.text = data?.phone ?? '';
            _locationController.text = data?.location ?? '';
            _bioController.text = data?.bio ?? '';

            _initialDataLoaded = true;
          }

          final headerName = _nameController.text.isNotEmpty ? _nameController.text : 'User';

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const TripListScreen()),
                ),
              ),
              title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // --- PROFILE PICTURE ---
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                          ),
                          child: const Icon(Icons.person, size: 60, color: AppTheme.primaryBlue),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    headerName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  // --- FIELDS ---
                  
                  _buildLabel("Full Name"),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline, color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Email"),
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    enabled: false,
                    style: TextStyle(color: Colors.grey[600]),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                      suffixIcon: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                      fillColor: Color(0xFFF5F5F5),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Phone"),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, 
                      LengthLimitingTextInputFormatter(15),   
                    ],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey),
                      hintText: "e.g. 123456789", 
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Location"),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey),
                      hintText: "e.g. New York, USA", 
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Bio"),
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.info_outline, color: Colors.grey),
                      hintText: "Tell us a little about yourself...", 
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // --- SAVE BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAllChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- LOGOUT BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () async {
                         await FirebaseAuth.instance.signOut();
                         if (context.mounted) {
                           Navigator.pushReplacement(
                             context, 
                             MaterialPageRoute(builder: (_) => const LoginScreen())
                           );
                         }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Log Out", style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
      ),
    );
  }
}