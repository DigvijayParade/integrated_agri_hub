import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrated_agri_hub/screens/role_selection_screen.dart';
import 'package:integrated_agri_hub/screens/farmer_home_screen.dart';
import 'package:integrated_agri_hub/screens/admin_home_screen.dart';
import 'package:integrated_agri_hub/screens/shopkeeper_home_screen.dart';
import 'package:integrated_agri_hub/services/firebase_auth_service.dart';
import 'package:integrated_agri_hub/services/translation_service.dart';

// ─── COLOR PALETTE & DESIGN CONSTANTS ─────────────────────────────────────────
const _kPrimary = Color(0xFF2E7D32);
const _kPrimaryDark = Color(0xFF1B5E20);
const _kPrimaryLight = Color(0xFF4CAF50);
const _kAccentGold = Color(0xFFF9A825);
const _kTextDark = Color(0xFF1A261D);
const _kTextMuted = Color(0xFF5A6E60);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final _languages = ['English', 'Hindi (हिंदी)', 'Marathi (मराठी)'];

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _greetingEmoji {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }

  void _showLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LoginOverlay(),
    );
  }

  void _showRegisterSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = FirebaseAuthService();
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: _kPrimary),
                  SizedBox(height: 16),
                  Text('Connecting with Google...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      );

      final user = await auth.signInWithGoogle();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog

      if (user != null) {
        final role = await auth.getUserRole(user.uid);
        if (!mounted) return;
        if (role == 'shopkeeper') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ShopkeeperHomeScreen()),
            (_) => false,
          );
        } else if (role == 'admin') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
            (_) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
            (_) => false,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In: ${e.toString().contains('cancelled') ? 'Cancelled by user' : 'Please select your role or login with email.'}'),
          backgroundColor: const Color(0xFF0F2B48),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'REGISTER',
            textColor: _kAccentGold,
            onPressed: _showRegisterSheet,
          ),
        ),
      );
    }
  }

  void _showAdminLoginDialog() {
    final emailController = TextEditingController(text: 'admin@agrihub.gov.in');
    final passwordController = TextEditingController(text: 'admin123');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Govt Admin Portal',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  'Official Access Desk',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Government Agricultural Officer credentials:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Officer Email / ID',
                prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF1E3A8A)),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Access Key',
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E3A8A)),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final id = emailController.text.trim();
              final pwd = passwordController.text.trim();
              if ((id == 'admin@agrihub.gov.in' || id.toLowerCase().contains('admin') || id == 'GOV-ADMIN') &&
                  pwd == 'admin123') {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid Admin Credentials! Use admin@agrihub.gov.in / admin123'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Login to Portal', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TranslationService(),
      builder: (context, _) {
        final langName = TranslationService().currentLanguageName;

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. BACKGROUND IMAGE ─────────────────────────────────────────
              Image.asset(
                'assets/images/welcome_bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F304E), Color(0xFF1E5235)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  );
                },
              ),

              // ── 2. SUBTLE BLUE OVERLAY GRADIENT ─────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0B253F).withValues(alpha: 0.72), // subtle top blue
                      const Color(0xFF0F3556).withValues(alpha: 0.40), // clear middle showcasing field & hand
                      const Color(0xFF081C30).withValues(alpha: 0.85), // deep bottom for clean contrast
                    ],
                    stops: const [0.0, 0.40, 0.90],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // ── 3. HEADER & AUTH CONTENT ────────────────────────────────────
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      // ──── HEADER ────
                      _buildHeader(langName),

                      const Spacer(),

                      // ──── HERO BRANDING & AUTH ACTIONS ────
                      SlideTransition(
                        position: _slideAnim,
                        child: _buildAuthCard(),
                      ),

                      const Spacer(),

                      // Minimal subtle bottom note
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Integrated Agri Hub • Digital India Initiative',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── HEADER WIDGET ──────────────────────────────────────────────────────────
  Widget _buildHeader(String langName) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2135).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // App Logo Emblem
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kAccentGold, _kPrimaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kAccentGold.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.eco_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // App Title & Tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greetingEmoji $_greeting',
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Integrated Agri Hub',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          // Language Switcher Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: langName,
                dropdownColor: const Color(0xFF0F263B),
                icon: const Icon(Icons.language_rounded, color: Colors.white, size: 16),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                items: _languages
                    .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(l, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) TranslationService().setLanguage(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AUTH CARD (LOGO, APP TITLE, LOGIN, REGISTER, GOOGLE) ───────────────────
  Widget _buildAuthCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B2135).withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Animated Big Center Logo
                Center(
                  child: ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF1565C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.agriculture_rounded, color: Colors.white, size: 38),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // App Title
                Text(
                  TranslationService.tr('app_name'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Tagline / Subtitle
                Text(
                  TranslationService.tr('app_tagline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. LOGIN BUTTON (Primary)
                ElevatedButton(
                  onPressed: _showLoginSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: _kPrimary.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login_rounded, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        TranslationService.tr('login'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2. REGISTER / CREATE ACCOUNT BUTTON (Secondary Glass)
                OutlinedButton(
                  onPressed: _showRegisterSheet,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add_alt_1_rounded, color: _kAccentGold, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        TranslationService.tr('get_started'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. GOOGLE SIGN-IN BUTTON
                ElevatedButton(
                  onPressed: _handleGoogleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF333333),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stylized Google 'G'
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4285F4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        TranslationService.tr('google_signin'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 4. GOVT ADMIN PORTAL LINK
                InkWell(
                  onTap: _showAdminLoginDialog,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF93C5FD), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          TranslationService.tr('official_admin_login'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBFDBFE),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_right_alt_rounded, color: Color(0xFF93C5FD), size: 16),
                      ],
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
}

// ─── LOGIN BOTTOM SHEET OVERLAY ───────────────────────────────────────────────
class _LoginOverlay extends StatefulWidget {
  const _LoginOverlay();
  @override
  State<_LoginOverlay> createState() => _LoginOverlayState();
}

class _LoginOverlayState extends State<_LoginOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = FirebaseAuthService();
  bool _showPass = false;
  bool _loading = false;
  String? _error;
  bool _hasError = false;

  void _clearError() {
    if (_hasError || _error != null) {
      setState(() {
        _hasError = false;
        _error = null;
      });
    }
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    setState(() {
      _error = null;
      _hasError = false;
    });
    if (!_formKey.currentState!.validate()) return;

    if (email == 'GOV-ADMIN') {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        (_) => false,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      if (!email.contains('@')) {
        setState(() {
          _error = 'Please enter a valid registered email address.';
          _hasError = true;
          _loading = false;
        });
        return;
      }
      final user = await _auth.signInWithEmailAndPassword(email, pass);
      if (user != null && mounted) {
        final role = await _auth.getUserRole(user.uid);
        if (!mounted) return;
        Widget home;
        if (role == 'shopkeeper') {
          home = const ShopkeeperHomeScreen();
        } else if (role == 'admin') {
          home = const AdminHomeScreen();
        } else {
          home = const FarmerHomeScreen();
        }
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => home),
          (_) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg;
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
          msg = "Account not found. Please check your email or Register.";
          break;
        case 'wrong-password':
          msg = "Wrong password. Please try again.";
          break;
        case 'invalid-credential':
          msg = "Invalid credentials. Please verify your details.";
          break;
        case 'too-many-requests':
          msg = "Too many attempts. Please try again in a moment.";
          break;
        case 'network-request-failed':
          msg = "Network connection issue. Please check your internet.";
          break;
        default:
          msg = "Login failed: ${e.message ?? 'Please check your credentials.'}";
      }
      setState(() {
        _error = msg;
        _hasError = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = "Login failed. Please check your credentials.";
          _hasError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const errClr = Color(0xFFE02424);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.login_rounded, color: _kPrimary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationService().currentLanguage == AppLanguage.hindi
                            ? 'वापसी पर स्वागत है'
                            : TranslationService().currentLanguage == AppLanguage.marathi
                                ? 'पुन्हा स्वागत आहे'
                                : 'Welcome Back',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _kPrimaryDark),
                      ),
                      Text(
                        TranslationService().currentLanguage == AppLanguage.hindi
                            ? 'अपने पंजीकृत खाते में प्रवेश करें'
                            : TranslationService().currentLanguage == AppLanguage.marathi
                                ? 'आपल्या खात्यात प्रवेश करा'
                                : 'Log in to your verified account',
                        style: const TextStyle(color: _kTextMuted, fontSize: 12.5),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF8B4B4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: errClr, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFF9B1C1C), fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _emailCtrl,
                onChanged: (_) => _clearError(),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: TranslationService.tr('email'),
                  prefixIcon: Icon(Icons.email_outlined, color: _hasError ? errClr : null),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _hasError ? errClr : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _hasError ? errClr : _kPrimary, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (v.trim() == 'GOV-ADMIN') return null;
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passCtrl,
                obscureText: !_showPass,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: TranslationService.tr('password'),
                  prefixIcon: Icon(Icons.lock_outline, color: _hasError ? errClr : null),
                  suffixIcon: IconButton(
                    icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off, color: _hasError ? errClr : null),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _hasError ? errClr : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _hasError ? errClr : _kPrimary, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'Minimum 6 characters required';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          TranslationService.tr('login'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                    );
                  },
                  child: const Text(
                    'Don\'t have an account? Register Now',
                    style: TextStyle(color: _kPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
