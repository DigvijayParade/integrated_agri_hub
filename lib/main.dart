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
          return const _AppSplashScreen();
        }

        final user = snapshot.data;

        // Not logged in — show informative Welcome / App Discovery screen
        if (user == null) {
          return const WelcomeScreen();
        }

        // Already logged in — resolve role and route directly to their dashboard
        return FutureBuilder<String?>(
          future: _authService.getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const _AppSplashScreen();
            }

            final role = roleSnapshot.data;
            if (role == 'shopkeeper') {
              return const ShopkeeperHomeScreen();
            } else if (role == 'admin') {
              return const AdminHomeScreen();
            } else {
              // Default to farmer home whenever an active session exists
              return const FarmerHomeScreen();
            }
          },
        );
      },
    );
  }
}

/// Branded splash screen shown during fast session verification
class _AppSplashScreen extends StatelessWidget {
  const _AppSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.lightGreen, AppTheme.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Integrated Agri Hub',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connecting Farmers & Agri-Commerce',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
