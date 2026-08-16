import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrated_agri_hub/services/firebase_auth_service.dart';
import 'package:integrated_agri_hub/screens/farmer_home_screen.dart';

class FarmerSignupScreen extends StatefulWidget {
  const FarmerSignupScreen({super.key});

  @override
  State<FarmerSignupScreen> createState() => _FarmerSignupScreenState();
}

class _FarmerSignupScreenState extends State<FarmerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  String? _selectedState;
  final List<String> _states = ['Maharashtra', 'Punjab', 'Kerala'];

  final Map<String, List<String>> _cropsMap = {
    'Maharashtra': ["Soybean", "Cotton", "Sugarcane", "Rice", "Wheat", "Tur (Pigeon Pea)", "Jowar", "Bajra", "Onions", "Grapes", "Mangoes"],
    'Punjab': ['Wheat', 'Rice', 'Maize', 'Mustard', 'Cotton', 'Sugarcane', 'Barley', 'Sunflower'],
    'Kerala': ['Coconut', 'Spices', 'Rubber', 'Coffee', 'Rice', 'Tapioca', 'Arecanut', 'Banana'],
  };

  final Set<String> _selectedCrops = {};

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrops.isEmpty) {
      _showSnack('Please select at least one crop', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final pwd = _passwordController.text;
    final name = _nameController.text.trim();

    try {
      final User? user = await _authService.signUpWithEmailAndPassword(email, pwd);

      if (user != null) {
        await _authService.saveUserProfile(user.uid, {
          'role': 'farmer',
          'fullName': name,
          'email': email,
          'state': _selectedState,
          'selectedCrops': _selectedCrops.toList(),
          'greenCoins': 0,
          'streak': 0,
          'quizzesCompleted': 0,
          'createdAt': DateTime.now().toIso8601String(),
        });

        _showSnack('Account created successfully!', const Color(0xFF4A7C59));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FarmerHomeScreen()),
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
        title: const Text('Farmer Registration', style: TextStyle(color: Color(0xFF4A7C59), fontWeight: FontWeight.bold)),
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
                      decoration: _buildInputDecoration('Full Name', Icons.person_outline),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your full name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration('Email Address', Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Agricultural Details
                _buildSectionCard(
                  title: 'Agricultural Details',
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: _buildInputDecoration('Select State', Icons.map_outlined),
                      items: _states.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                          _selectedCrops.clear();
                        });
                      },
                      validator: (v) => v == null ? 'Please select your state' : null,
                    ),
                    if (_selectedState != null) ...[
                      const SizedBox(height: 16),
                      const Text('Select Your Crops', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2A5934))),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _cropsMap[_selectedState]!.map((crop) {
                          final isSelected = _selectedCrops.contains(crop);
                          return FilterChip(
                            label: Text(crop),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) { _selectedCrops.add(crop); } else { _selectedCrops.remove(crop); }
                              });
                            },
                            selectedColor: const Color(0xFFE2E8D5),
                            checkmarkColor: const Color(0xFF4A7C59),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFF2A5934) : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: isSelected ? const Color(0xFF4A7C59) : Colors.grey.shade300),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (v.length < 6) return 'Password must be at least 6 characters';
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
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
