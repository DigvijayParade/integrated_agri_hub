import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrated_agri_hub/services/firebase_auth_service.dart';
import 'package:integrated_agri_hub/screens/shopkeeper_home_screen.dart';

class ShopkeeperSignupScreen extends StatefulWidget {
  const ShopkeeperSignupScreen({super.key});

  @override
  State<ShopkeeperSignupScreen> createState() => _ShopkeeperSignupScreenState();
}

class _ShopkeeperSignupScreenState extends State<ShopkeeperSignupScreen> {
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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final pwd = _passwordController.text;
    final name = _nameController.text.trim();

    try {
      final User? user = await _authService.signUpWithEmailAndPassword(email, pwd);

      if (user != null) {
        // Save to dedicated 'shopkeepers' collection
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

        _showSnack('Account created successfully!', const Color(0xFF4A7C59));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ShopkeeperHomeScreen()),
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _shopIdController.dispose();
    _shopLicenseController.dispose();
    _shopAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF4A7C59)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A7C59), width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Shopkeeper Registration', style: TextStyle(color: Color(0xFF4A7C59), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A7C59)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personal Details
                _buildSectionCard(
                  title: 'Personal Details',
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Full Name / Shop Name', Icons.person_outline),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your full name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration('Email Address', Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your email';
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Shop Details
                _buildSectionCard(
                  title: 'Shop Details',
                  children: [
                    TextFormField(
                      controller: _shopIdController,
                      decoration: _buildInputDecoration('Shop ID / GST Number', Icons.storefront_outlined),
                      validator: (v) => v == null || v.isEmpty ? 'Enter Shop ID or GST' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shopLicenseController,
                      decoration: _buildInputDecoration('Shop License Number', Icons.assignment_outlined),
                      validator: (v) => v == null || v.isEmpty ? 'Enter License Number' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: _buildInputDecoration('State', Icons.map_outlined),
                      items: _states.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
                      onChanged: (value) => setState(() => _selectedState = value),
                      validator: (v) => v == null ? 'Please select your state' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shopAddressController,
                      maxLines: 3,
                      decoration: _buildInputDecoration('Shop Address', Icons.location_on_outlined),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your shop address' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Security
                _buildSectionCard(
                  title: 'Security',
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: _buildInputDecoration('Password', Icons.lock_outline).copyWith(
                        helperText: 'Must be 8+ chars with 1 upper, 1 digit, 1 special',
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (v.length < 8) return 'Password must be at least 8 characters';
                        final hasUpper = v.contains(RegExp(r'[A-Z]'));
                        final hasLower = v.contains(RegExp(r'[a-z]'));
                        final hasDigit = v.contains(RegExp(r'[0-9]'));
                        final hasSpecial = v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                        if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
                          return 'Required: 1 upper, 1 lower, 1 digit, 1 special';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: _buildInputDecoration('Confirm Password', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirm your password';
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7C59),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A5934))),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
