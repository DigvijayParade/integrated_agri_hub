import 'package:flutter/material.dart';
import 'auth_screen.dart';

// ---------------------------------------------------------------------------
// Localisation dictionary
// ---------------------------------------------------------------------------
const Map<String, Map<String, String>> _l10n = {
  'English': {
    'welcome': 'Welcome to\nIntegrated Agri Hub',
    'selectPortal': 'Please select your access portal',
    'farmerPortal': 'Farmer Portal',
    'merchantPortal': 'Merchant Portal',
    'govPortal': 'DAA Secure Sign-In',
    'ecosystemTitle': 'Ecosystem Overview',
    'ecosystemBody':
        'Empowering Farmers  •  Streamlining Merchants  •  Centralizing State Oversight',
    'learnMore': 'Learn more about the hub →',
  },
  'हिंदी': {
    'welcome': 'एकीकृत कृषि हब में\nआपका स्वागत है',
    'selectPortal': 'कृपया अपना एक्सेस पोर्टल चुनें',
    'farmerPortal': 'किसान पोर्टल',
    'merchantPortal': 'व्यापारी पोर्टल',
    'govPortal': 'DAA सुरक्षित साइन-इन',
    'ecosystemTitle': 'पारिस्थितिकी तंत्र अवलोकन',
    'ecosystemBody':
        'किसानों को सशक्त बनाना  •  व्यापारियों को सुव्यवस्थित करना  •  राज्य पर्यवेक्षण',
    'learnMore': 'हब के बारे में अधिक जानें →',
  },
  'मराठी': {
    'welcome': 'एकात्मिक कृषी हब मध्ये\nआपले स्वागत आहे',
    'selectPortal': 'कृपया आपला प्रवेश पोर्टल निवडा',
    'farmerPortal': 'शेतकरी पोर्टल',
    'merchantPortal': 'व्यापारी पोर्टल',
    'govPortal': 'DAA सुरक्षित साइन-इन',
    'ecosystemTitle': 'परिसंस्था आढावा',
    'ecosystemBody':
        'शेतकऱ्यांना सक्षम करणे  •  व्यापाऱ्यांना सुव्यवस्थित करणे  •  राज्य देखरेख',
    'learnMore': 'हबबद्दल अधिक जाणून घ्या →',
  },
};

// ---------------------------------------------------------------------------
// RoleSelectorScreen
// ---------------------------------------------------------------------------
class RoleSelectorScreen extends StatefulWidget {
  const RoleSelectorScreen({super.key});

  @override
  State<RoleSelectorScreen> createState() => _RoleSelectorScreenState();
}

class _RoleSelectorScreenState extends State<RoleSelectorScreen> {
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'हिंदी', 'मराठी'];

  String _t(String key) => _l10n[_selectedLanguage]![key] ?? '';

  void _showAboutHub(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'About Integrated Agri Hub',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A unified three-tier platform connecting every stakeholder in India\'s agricultural supply chain.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 28),
            _AboutTile(
              icon: Icons.grass,
              color: Colors.green.shade700,
              title: 'Empowering Farmers',
              body: 'Give farmers direct access to crop advisory, weather alerts, '
                  'digital vouchers, and green coin rewards — right from their mobile.',
            ),
            const SizedBox(height: 20),
            _AboutTile(
              icon: Icons.storefront,
              color: Colors.orange.shade700,
              title: 'Streamlining Merchants',
              body: 'Equip agri-dealers with a digital ledger, QR-based voucher '
                  'redemption, and a real-time inventory dashboard to manage stock.',
            ),
            const SizedBox(height: 20),
            _AboutTile(
              icon: Icons.account_balance,
              color: const Color(0xFF2C3E50),
              title: 'Centralizing State Oversight',
              body: 'Provide government officials with powerful moderation tools, '
                  'disaster broadcast capabilities, and a content publishing terminal '
                  'for policy-aligned agri education.',
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── Language Switcher ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      icon: const Icon(Icons.language,
                          size: 20, color: Color(0xFF2E7D32)),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedLanguage = v);
                      },
                      items: _languages
                          .map((l) => DropdownMenuItem(
                              value: l,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(l),
                              )))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),

            // ── Main scrollable content ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    // Hero icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.agriculture,
                          size: 80, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(height: 24),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _t('welcome'),
                        key: ValueKey('${_selectedLanguage}w'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _t('selectPortal'),
                        key: ValueKey('${_selectedLanguage}s'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Role Buttons ──────────────────────────────────────
                    _RoleButton(
                      title: _t('farmerPortal'),
                      icon: Icons.grass,
                      color: Colors.green.shade700,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AuthScreen(role: UserRole.farmer),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _RoleButton(
                      title: _t('merchantPortal'),
                      icon: Icons.storefront,
                      color: Colors.orange.shade700,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AuthScreen(role: UserRole.shopkeeper),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _RoleButton(
                      title: _t('govPortal'),
                      icon: Icons.account_balance,
                      color: const Color(0xFF2C3E50),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AuthScreen(role: UserRole.government),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Interactive Ecosystem Panel ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: InkWell(
                onTap: () => _showAboutHub(context),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey('${_selectedLanguage}eco'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline,
                                size: 15,
                                color: Colors.blueGrey.shade400),
                            const SizedBox(width: 6),
                            Text(
                              _t('ecosystemTitle'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _t('ecosystemBody'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey.shade800,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _t('learnMore'),
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RoleButton
// ---------------------------------------------------------------------------
class _RoleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_ios,
                    color: Colors.grey.shade400, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AboutTile — used inside the bottom sheet
// ---------------------------------------------------------------------------
class _AboutTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _AboutTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  )),
              const SizedBox(height: 4),
              Text(body,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
