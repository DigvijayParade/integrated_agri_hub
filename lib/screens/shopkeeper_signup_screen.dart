import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrated_agri_hub/services/firebase_auth_service.dart';
import 'package:integrated_agri_hub/screens/shopkeeper_home_screen.dart';

class ShopkeeperSignupScreen extends StatefulWidget {
  const ShopkeeperSignupScreen({super.key});

  @override
  State<ShopkeeperSignupScreen> createState() => _ShopkeeperSignupScreenState();
}

class _ShopkeeperSignupScreenState extends State<ShopkeeperSignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _shopIdController = TextEditingController();
  final _shopLicenseController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  String? _selectedState;
  final List<String> _states = ['Maharashtra', 'Punjab', 'Kerala', 'Other'];

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _shopIdController.dispose();
    _shopLicenseController.dispose();
    _shopAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final pwd = _passwordController.text;
    final name = _nameController.text.trim();

    try {
      final User? user = await _authService.signUpWithEmailAndPassword(email, pwd);

      if (user != null) {
        await _authService.saveUserProfile(user.uid, {
          'role': 'shopkeeper',
          'fullName': name,
          'email': email,
          'shopId': _shopIdController.text.trim(),
          'shopLicense': _shopLicenseController.text.trim(),
          'state': _selectedState,
          'shopAddress': _shopAddressController.text.trim(),
          'todaySales': 0,
          'greenCoinsReceived': 0,
          'createdAt': DateTime.now().toIso8601String(),
        }, collection: 'shopkeepers');

        _showSnack('Account created successfully!', const Color(0xFF0D9488));

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ShopkeeperHomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      _showSnack('Signup failed: ${e.toString().split(']').last.trim()}', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF2DD4BF)),
      filled: true,
      fillColor: const Color(0xFF0C243B).withValues(alpha: 0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. BACKGROUND IMAGE ─────────────────────────────────────────
          Image.asset(
            'assets/images/welcome_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0B253F)),
          ),

          // ── 2. SUBTLE BLUE ATMOSPHERIC OVERLAY ──────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0B253F).withValues(alpha: 0.85),
                  const Color(0xFF0E304F).withValues(alpha: 0.65),
                  const Color(0xFF061524).withValues(alpha: 0.92),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── 3. FORM CONTENT ─────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B2135).withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Shopkeeper Registration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Personal & Business Details
                              _buildGlassCard(
                                title: 'Personal & Business Details',
                                icon: Icons.storefront_rounded,
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _buildInputDecoration('Full Name / Owner Name', Icons.person_outline),
                                    validator: (v) => v == null || v.isEmpty ? 'Enter your full name' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _buildInputDecoration('Email Address', Icons.email_outlined),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Enter email';
                                      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(v.trim())) return 'Enter a valid email address';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _shopIdController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _buildInputDecoration('Agri-Shop / Store Name', Icons.store_mall_directory_outlined),
                                    validator: (v) => v == null || v.isEmpty ? 'Enter shop name' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _shopLicenseController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _buildInputDecoration('Fertilizer/Seed License No.', Icons.verified_outlined),
                                    validator: (v) => v == null || v.isEmpty ? 'Enter license number' : null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _buildGlassCard(
                                title: 'Store Location Details',
                                icon: Icons.pin_drop_rounded,
                                children: [
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedState,
                                    dropdownColor: const Color(0xFF0F263E),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _buildInputDecoration('State', Icons.map_outlined),
                                    items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                    onChanged: (val) => setState(() => _selectedState = val),
                                    validator: (v) => v == null ? 'Select state' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _shopAddressController,
                                    maxLines: 2,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _buildInputDecoration('Complete Shop Address', Icons.location_on_outlined),
                                    validator: (v) => v == null || v.isEmpty ? 'Enter complete shop address' : null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Security & Password
                              _buildGlassCard(
                                title: 'Security & Password',
                                icon: Icons.security_rounded,
                                children: [
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _buildInputDecoration('Password', Icons.lock_outline).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF94A3B8)),
                                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                      ),
                                    ),
                                    validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: !_isConfirmPasswordVisible,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _buildInputDecoration('Confirm Password', Icons.lock_clock_outlined).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF94A3B8)),
                                        onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Confirm password';
                                      if (v != _passwordController.text) return 'Passwords do not match';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Submit Button
                              Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0D9488).withValues(alpha: 0.5),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.storefront_rounded, size: 20),
                                            SizedBox(width: 10),
                                            Text('Complete Shopkeeper Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0A2035).withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFF2DD4BF), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
