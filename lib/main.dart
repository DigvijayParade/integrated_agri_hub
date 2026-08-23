import 'package:flutter/material.dart';
import 'package:integrated_agri_hub/screens/welcome_screen.dart';
import 'package:integrated_agri_hub/screens/farmer_home_screen.dart';
import 'package:integrated_agri_hub/screens/shopkeeper_home_screen.dart';
import 'package:integrated_agri_hub/screens/admin_home_screen.dart';
import 'package:integrated_agri_hub/services/firebase_auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:integrated_agri_hub/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integrated Agri Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

/// AuthGate checks if a user is already logged in.
/// If yes, it routes directly to their home screen.
/// This prevents the back button from going back to the login/welcome screen.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still loading Firebase auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Not logged in — show welcome/login screen
        if (user == null) {
          return const WelcomeScreen();
        }

        // Already logged in — resolve role and route to correct home screen
        return FutureBuilder<String?>(
          future: _authService.getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;
            if (role == 'shopkeeper') {
              return const ShopkeeperHomeScreen();
            } else if (role == 'admin') {
              return const AdminHomeScreen();
            } else {
              // Default to farmer home (or welcome if role is unknown)
              return role != null ? const FarmerHomeScreen() : const WelcomeScreen();
            }
          },
        );
      },
    );
  }
}
