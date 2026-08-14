import 'package:flutter/material.dart';
import 'package:integrated_agri_hub/screens/shopkeeper_home_screen.dart';

class ShopkeeperSignupScreen extends StatefulWidget {
  const ShopkeeperSignupScreen({super.key});

  @override
  State<ShopkeeperSignupScreen> createState() => _ShopkeeperSignupScreenState();
}

class _ShopkeeperSignupScreenState extends State<ShopkeeperSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailPhoneController = TextEditingController();
  final _shopIdController = TextEditingController();
  final _shopLicenseController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedState;
  final List<String> _states = ['Maharashtra', 'Punjab', 'Kerala', 'Other'];

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _sendOtp() {
    if (_emailPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid Phone Number or Email address first"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Demo OTP sent! Use '1234' to verify."),
        backgroundColor: Color(0xFF4A7C59),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_otpController.text != '1234') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid OTP! Please use '1234'."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShopkeeperHomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailPhoneController.dispose();
    _shopIdController.dispose();
    _shopLicenseController.dispose();
    _shopAddressController.dispose();
    _otpController.dispose();
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A7C59), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Shopkeeper Signup', style: TextStyle(color: Color(0xFF4A7C59), fontWeight: FontWeight.bold)),
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
                // Personal Details Card
                _buildSectionCard(
                  title: 'Personal Details',
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Full Name', Icons.person_outline),
                      validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _emailPhoneController,
                            decoration: _buildInputDecoration('Email or Phone', Icons.contact_phone_outlined),
                            validator: (value) => value == null || value.isEmpty ? 'Enter email/phone' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 56, // Match text field height
                            child: ElevatedButton(
                              onPressed: _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A7C59),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Send OTP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _otpController,
                      decoration: _buildInputDecoration('Enter OTP', Icons.message_outlined),
                      validator: (value) => value == null || value.isEmpty ? 'Enter OTP' : null,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Shop Details Card
                _buildSectionCard(
                  title: 'Shop Details',
                  children: [
                    TextFormField(
                      controller: _shopIdController,
                      decoration: _buildInputDecoration('Shop ID', Icons.storefront_outlined),
                      validator: (value) => value == null || value.isEmpty ? 'Enter Shop ID' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shopLicenseController,
                      decoration: _buildInputDecoration('Shop License Number', Icons.assignment_outlined),
                      validator: (value) => value == null || value.isEmpty ? 'Enter License Number' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedState,
                      decoration: _buildInputDecoration('State', Icons.map_outlined),
                      items: _states.map((state) {
                        return DropdownMenuItem(value: state, child: Text(state));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a state' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shopAddressController,
                      maxLines: 3,
                      decoration: _buildInputDecoration('Shop Address', Icons.location_on_outlined),
                      validator: (value) => value == null || value.isEmpty ? 'Enter Shop Address' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Security Card
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
                      validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirm your password';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7C59),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text('Complete Signup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A5934),
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
