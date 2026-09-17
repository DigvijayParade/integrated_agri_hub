import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:integrated_agri_hub/screens/farmer_signup_screen.dart';
import 'package:integrated_agri_hub/screens/shopkeeper_signup_screen.dart';
import 'package:integrated_agri_hub/screens/admin_home_screen.dart';
import 'package:integrated_agri_hub/services/translation_service.dart';
import 'package:integrated_agri_hub/l10n/app_localizations.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
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

  void _showAdminLoginDialog(BuildContext context) {
    final emailController = TextEditingController(text: 'admin@agrihub.gov.in');
    final passwordController = TextEditingController(text: 'admin123');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F263E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.account_balance, color: Color(0xFF93C5FD), size: 24),
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Official Access Portal',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
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
              style: TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Admin Officer ID / Email',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF60A5FA)),
                filled: true,
                fillColor: const Color(0xFF16324F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF60A5FA)),
                filled: true,
                fillColor: const Color(0xFF16324F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final id = emailController.text.trim();
              final pwd = passwordController.text.trim();
              if ((id == 'admin@agrihub.gov.in' || id.toLowerCase().contains('admin') || id == 'GOV-ADMIN') &&
                  pwd == 'admin123') {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
                  (route) => false,
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

          // ── 2. SUBTLE BLUE ATMOSPHERIC OVERLAY ──────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0B253F).withValues(alpha: 0.80),
                  const Color(0xFF0F3556).withValues(alpha: 0.48),
                  const Color(0xFF081C30).withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.45, 0.90],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── 3. MAIN CONTENT ─────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // App Bar / Top Navigation
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Integrated Agri Hub',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: Color(0xFFF9A825), size: 14),
                              SizedBox(width: 4),
                              Text('Register', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            // Animated Title Header
                            Center(
                              child: ScaleTransition(
                                scale: _pulseAnim,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF2E7D32), Color(0xFF1E3A8A)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 30),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              AppLocalizations.of(context)?.selectRole ?? 'Select Your Role',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                                shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Choose your account type to access personalized tools',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 1. FARMER ROLE CARD
                            _buildRoleCard(
                              title: AppLocalizations.of(context)?.farmer ?? 'Farmer',
                              subtitle: TranslationService().currentLanguage == AppLanguage.hindi
                                  ? 'फसल प्रबंधन, लाइव मंडी भाव, AI डॉक्टर और ग्रीन कॉइन्स'
                                  : TranslationService().currentLanguage == AppLanguage.marathi
                                      ? 'पीक व्यवस्थापन, थेट बाजार भाव, AI डॉक्टर आणि ग्रीन कॉइन्स'
                                      : 'AI Crop Doctor, Live Mandi Prices, Weather & Green Rewards',
                              badgeText: 'Most Popular',
                              emoji: '🌾',
                              icon: Icons.eco_rounded,
                              gradientColors: [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
                              accentColor: const Color(0xFF4ADE80),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const FarmerSignupScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // 2. SHOPKEEPER ROLE CARD
                            _buildRoleCard(
                              title: AppLocalizations.of(context)?.shopkeeper ?? 'Shopkeeper',
                              subtitle: TranslationService().currentLanguage == AppLanguage.hindi
                                  ? 'कृषि दुकान प्रबंधन, डिजिटल QR कोड और त्वरित भुगतान'
                                  : TranslationService().currentLanguage == AppLanguage.marathi
                                      ? 'कृषी दुकान व्यवस्थापन, डिजिटल QR कोड आणि त्वरित व्यवहार'
                                      : 'Generate Sales QR, Verify Farmer Proofs & Inventory',
                              badgeText: 'Agri Business',
                              emoji: '🏪',
                              icon: Icons.storefront_rounded,
                              gradientColors: [const Color(0xFF0F766E), const Color(0xFF115E59)],
                              accentColor: const Color(0xFF2DD4BF),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ShopkeeperSignupScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // 3. ADMIN PORTAL CARD
                            _buildRoleCard(
                              title: AppLocalizations.of(context)?.admin ?? 'Admin',
                              subtitle: TranslationService().currentLanguage == AppLanguage.hindi
                                  ? 'शासकीय कृषि अधिकारी एवं बाज़ार प्रबंधन'
                                  : TranslationService().currentLanguage == AppLanguage.marathi
                                      ? 'शासकीय कृषी अधिकारी आणि बाजार व्यवस्थापन'
                                      : 'Govt Agricultural Officer Portal & Policy Controls',
                              badgeText: 'Official',
                              emoji: '🏛️',
                              icon: Icons.account_balance_rounded,
                              gradientColors: [const Color(0xFF1E3A8A), const Color(0xFF1E293B)],
                              accentColor: const Color(0xFF60A5FA),
                              onTap: () => _showAdminLoginDialog(context),
                            ),
                            const SizedBox(height: 24),
                          ],
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

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required String emoji,
    required IconData icon,
    required List<Color> gradientColors,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              splashColor: accentColor.withValues(alpha: 0.2),
              highlightColor: accentColor.withValues(alpha: 0.1),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2035).withValues(alpha: 0.76),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    // Icon Emblem with Gradient
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withValues(alpha: 0.75),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
