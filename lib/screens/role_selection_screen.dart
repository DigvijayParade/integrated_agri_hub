import 'package:flutter/material.dart';
import 'package:integrated_agri_hub/screens/farmer_signup_screen.dart';
import 'package:integrated_agri_hub/screens/shopkeeper_signup_screen.dart';
import 'package:integrated_agri_hub/screens/admin_home_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _showAdminLoginDialog(BuildContext context) {
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
                  'Govt Admin Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  'Official Access Portal',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
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
              'Enter your pre-assigned Government Officer login credentials:',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Admin Officer ID / Email',
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
                labelText: 'Password',
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), // Warm cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A7C59)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Choose Your Role',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7C59),
                ),
              ),
              const SizedBox(height: 32),
              _buildRoleCard(
                title: 'Farmer',
                subtitle: 'Manage crops, view market prices & earn Green Coins',
                icon: Icons.eco_outlined,
                baseColor: const Color(0xFF4A7C59), // Sage green
                backgroundColor: const Color(0xFFF2F7F2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FarmerSignupScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                title: 'Shopkeeper',
                subtitle: 'Scan vouchers & manage shop ledger',
                icon: Icons.storefront_outlined,
                baseColor: const Color(0xFFC7822B), // Warm amber/brown
                backgroundColor: const Color(0xFFFDF7F0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShopkeeperSignupScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                title: 'Government Officer / Admin',
                subtitle: 'Update mandi prices & post education videos/guides',
                icon: Icons.account_balance_outlined,
                baseColor: const Color(0xFF1E3A8A), // Navy blue
                backgroundColor: const Color(0xFFEFF6FF),
                onTap: () => _showAdminLoginDialog(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color baseColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: baseColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: baseColor.withOpacity(0.15),
          highlightColor: baseColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: baseColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: baseColor.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: baseColor.withOpacity(0.6),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
