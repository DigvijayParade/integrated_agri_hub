import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'government_admin_dashboard.dart';

// ---------------------------------------------------------------------------
// Role enum
// ---------------------------------------------------------------------------
enum UserRole { farmer, shopkeeper, government }

// ---------------------------------------------------------------------------
// Crop data for Farmer onboarding
// ---------------------------------------------------------------------------
const Map<String, List<String>> _stateCrops = {
  'Punjab': ['Wheat', 'Paddy', 'Cotton', 'Sugarcane'],
  'Maharashtra': ['Sugarcane', 'Cotton', 'Soyabean', 'Onion'],
  'Uttar Pradesh': ['Sugarcane', 'Wheat', 'Potatoes', 'Mustard'],
};

// ---------------------------------------------------------------------------
// Hardcoded test credentials
// ---------------------------------------------------------------------------
const _govEmail    = 'admin@agri.gov';
const _govId       = 'GOV-12345';
const _govPass     = 'admin123';

const _shopEmail   = 'merchant@agri.com';
const _shopLicense = 'DL-98765';
const _shopPass    = 'shop123';

const _farmerPhone = '9999999999';
const _farmerEmail = 'farmer@agri.com';
const _mockOtp     = '123456';

// ---------------------------------------------------------------------------
// AuthScreen
// ---------------------------------------------------------------------------
class AuthScreen extends StatefulWidget {
  final UserRole role;
  const AuthScreen({super.key, required this.role});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Role-specific helpers ─────────────────────────────────────────────────
  String get _portalTitle {
    switch (widget.role) {
      case UserRole.government:  return 'DAA Secure Sign-In';
      case UserRole.shopkeeper:  return 'Merchant Authentication Portal';
      case UserRole.farmer:      return 'Farmer Portal';
    }
  }

  IconData get _portalIcon {
    switch (widget.role) {
      case UserRole.government:  return Icons.account_balance;
      case UserRole.shopkeeper:  return Icons.storefront;
      case UserRole.farmer:      return Icons.grass;
    }
  }

  Color get _accent {
    switch (widget.role) {
      case UserRole.government:  return const Color(0xFF2C3E50);
      case UserRole.shopkeeper:  return const Color(0xFFE65100);
      case UserRole.farmer:      return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Portal Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  Icon(_portalIcon, size: 56, color: _accent),
                  const SizedBox(height: 12),
                  Text(
                    _portalTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Log In / Sign Up Tab Bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: 'Log In'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tab Views ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Log In tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: widget.role == UserRole.farmer
                        ? _FarmerLoginForm(accent: _accent)
                        : _IdPasswordLoginForm(
                            role: widget.role,
                            accent: _accent,
                          ),
                  ),

                  // Sign Up tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: widget.role == UserRole.farmer
                        ? _FarmerSignUpForm(accent: _accent)
                        : _StandardSignUpForm(
                            role: widget.role,
                            accent: _accent,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// LOG IN forms
// ===========================================================================

// ── Government & Shopkeeper Log In ──────────────────────────────────────────
class _IdPasswordLoginForm extends StatefulWidget {
  final UserRole role;
  final Color accent;
  const _IdPasswordLoginForm({required this.role, required this.accent});

  @override
  State<_IdPasswordLoginForm> createState() => _IdPasswordLoginFormState();
}

class _IdPasswordLoginFormState extends State<_IdPasswordLoginForm> {
  final _emailCtrl   = TextEditingController();
  final _idCtrl      = TextEditingController();
  final _passCtrl    = TextEditingController();
  bool _obscure      = true;

  bool get _isGov => widget.role == UserRole.government;
  Color get _accent => widget.accent;

  void _signIn() {
    final email = _emailCtrl.text.trim();
    final id    = _idCtrl.text.trim();
    final pass  = _passCtrl.text.trim();

    bool valid = _isGov
        ? (email == _govEmail && id == _govId && pass == _govPass)
        : (email == _shopEmail && id == _shopLicense && pass == _shopPass);

    if (valid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _isGov
              ? const GovernmentAdminDashboard()
              : const ShopkeeperDashboard(),
        ),
      );
    } else {
      _showError('Invalid Credentials. Please check your ID and Password.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HintCard(
          _isGov
              ? 'Test: admin@agri.gov  |  GOV-12345  |  admin123'
              : 'Test: merchant@agri.com  |  DL-98765  |  shop123',
          _accent,
        ),
        const SizedBox(height: 16),
        _FormCard(children: [
          _Field(
            ctrl: _emailCtrl,
            label: _isGov ? 'Official Email' : 'Business Email',
            icon: Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
            accent: _accent,
          ),
          const SizedBox(height: 16),
          _Field(
            ctrl: _idCtrl,
            label: _isGov ? 'Gov Employee ID' : 'Agri Dealer License No. / GSTIN',
            icon: Icons.badge_outlined,
            accent: _accent,
          ),
          const SizedBox(height: 16),
          _PasswordField(ctrl: _passCtrl, obscure: _obscure, accent: _accent,
              onToggle: () => setState(() => _obscure = !_obscure)),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text('Forgot Password?',
                  style: TextStyle(color: _accent)),
            ),
          ),
          const SizedBox(height: 12),
          _PrimaryBtn(label: 'Sign In', color: _accent, onPressed: _signIn),
        ]),
        const SizedBox(height: 16),
        _GoogleBtn(),
        const SizedBox(height: 12),
        _SignUpSwitch(accent: _accent),
      ],
    );
  }
}

// ── Farmer Log In ────────────────────────────────────────────────────────────
class _FarmerLoginForm extends StatefulWidget {
  final Color accent;
  const _FarmerLoginForm({required this.accent});

  @override
  State<_FarmerLoginForm> createState() => _FarmerLoginFormState();
}

class _FarmerLoginFormState extends State<_FarmerLoginForm> {
  bool _usePhone  = true;
  bool _otpSent   = false;
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();

  void _sendOtp() {
    if (_usePhone) {
      final ph = _phoneCtrl.text.trim();
      if (ph.length != 10) {
        _snack('Please enter a valid 10-digit number.', Colors.orange);
        return;
      }
      if (ph != _farmerPhone) {
        _snack('Unregistered Phone Number.');
        return;
      }
    } else {
      if (_emailCtrl.text.trim() != _farmerEmail) {
        _snack('Unregistered Email ID.');
        return;
      }
    }
    setState(() => _otpSent = true);
  }

  void _verifyOtp() {
    if (_otpCtrl.text.trim() == _mockOtp) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const _FarmerDashboardPlaceholder()),
      );
    } else {
      _snack('Invalid OTP. Use 123456 to proceed.');
    }
  }

  void _snack(String msg, [Color color = const Color(0xFFB71C1C)]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HintCard(
          'Test Phone: 9999999999  |  Email: farmer@agri.com  |  OTP: 123456',
          accent,
        ),
        const SizedBox(height: 16),

        // Phone / Email toggle
        _ToggleTabBar(
          leftLabel: '📱 Phone',
          rightLabel: '📧 Email',
          useLeft: _usePhone,
          accent: accent,
          onLeft: () => setState(() { _usePhone = true; _otpSent = false; }),
          onRight: () => setState(() { _usePhone = false; _otpSent = false; }),
        ),
        const SizedBox(height: 16),

        _FormCard(children: [
          if (_usePhone)
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              enabled: !_otpSent,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                counterText: '',
                prefixIcon: const Icon(Icons.phone_android),
                prefix: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text('+91',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ).applyDefaults(Theme.of(context).inputDecorationTheme),
            )
          else
            _Field(
              ctrl: _emailCtrl,
              label: 'Email ID',
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
              enabled: !_otpSent,
              accent: accent,
            ),

          if (!_otpSent) ...[
            const SizedBox(height: 20),
            _PrimaryBtn(label: 'Send OTP', color: accent, onPressed: _sendOtp),
          ],

          if (_otpSent) ...[
            const SizedBox(height: 20),
            _Field(
              ctrl: _otpCtrl,
              label: 'Enter OTP (mock: 123456)',
              icon: Icons.lock_clock,
              keyboard: TextInputType.number,
              accent: accent,
              maxLength: 6,
              formatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),
            _PrimaryBtn(
                label: 'Verify OTP & Sign In',
                color: accent,
                onPressed: _verifyOtp),
          ],
        ]),
        const SizedBox(height: 16),
        _GoogleBtn(),
      ],
    );
  }
}

// ===========================================================================
// SIGN UP forms
// ===========================================================================

// ── Government & Shopkeeper Sign Up ─────────────────────────────────────────
class _StandardSignUpForm extends StatefulWidget {
  final UserRole role;
  final Color accent;
  const _StandardSignUpForm({required this.role, required this.accent});

  @override
  State<_StandardSignUpForm> createState() => _StandardSignUpFormState();
}

class _StandardSignUpFormState extends State<_StandardSignUpForm> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _idCtrl      = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure      = true;
  bool _obscureC     = true;

  bool get _isGov => widget.role == UserRole.government;

  void _register() {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _idCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty) {
      _snack('Please fill all required fields.');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      _snack('Passwords do not match.');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Account created! Use the Log In tab to sign in.'),
      backgroundColor: widget.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormCard(children: [
          _Field(
            ctrl: _nameCtrl,
            label: 'Full Name',
            icon: Icons.person_outline,
            accent: widget.accent,
          ),
          const SizedBox(height: 16),
          _Field(
            ctrl: _emailCtrl,
            label: _isGov ? 'Official Email' : 'Business Email',
            icon: Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
            accent: widget.accent,
          ),
          const SizedBox(height: 16),
          _Field(
            ctrl: _idCtrl,
            label: _isGov
                ? 'Gov Employee ID'
                : 'Agri Dealer License No. / GSTIN',
            icon: Icons.badge_outlined,
            accent: widget.accent,
          ),
          const SizedBox(height: 16),
          _PasswordField(
            ctrl: _passCtrl,
            label: 'Password',
            obscure: _obscure,
            accent: widget.accent,
            onToggle: () => setState(() => _obscure = !_obscure),
          ),
          const SizedBox(height: 16),
          _PasswordField(
            ctrl: _confirmCtrl,
            label: 'Confirm Password',
            obscure: _obscureC,
            accent: widget.accent,
            onToggle: () => setState(() => _obscureC = !_obscureC),
          ),
          const SizedBox(height: 24),
          _PrimaryBtn(
              label: 'Create Account',
              color: widget.accent,
              onPressed: _register),
        ]),
        const SizedBox(height: 16),
        _GoogleBtn(),
      ],
    );
  }
}

// ── Farmer Sign Up ───────────────────────────────────────────────────────────
class _FarmerSignUpForm extends StatefulWidget {
  final Color accent;
  const _FarmerSignUpForm({required this.accent});

  @override
  State<_FarmerSignUpForm> createState() => _FarmerSignUpFormState();
}

class _FarmerSignUpFormState extends State<_FarmerSignUpForm> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _obscureC   = true;

  String? _selectedState;
  List<String> _availableCrops = [];
  final List<String> _selectedCrops = [];

  void _onStateChanged(String? s) {
    setState(() {
      _selectedState   = s;
      _availableCrops  = s != null ? (_stateCrops[s] ?? []) : [];
      _selectedCrops.clear();
    });
  }

  void _toggleCrop(String c) {
    setState(() {
      _selectedCrops.contains(c)
          ? _selectedCrops.remove(c)
          : _selectedCrops.add(c);
    });
  }

  void _register() {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().length != 10 ||
        _passCtrl.text.trim().isEmpty ||
        _selectedState == null ||
        _selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'Please complete all fields and select at least one crop.'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    if (_passCtrl.text != _confCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Passwords do not match.'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Farmer registered! State: $_selectedState | Crops: ${_selectedCrops.join(', ')}'),
      backgroundColor: widget.accent,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return _FormCard(children: [
      // Personal Details
      _Field(
          ctrl: _nameCtrl,
          label: 'Full Name',
          icon: Icons.person_outline,
          accent: accent),
      const SizedBox(height: 16),
      TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Mobile Number',
          counterText: '',
          prefixIcon: const Icon(Icons.phone_android),
          prefix: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text('+91',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ).applyDefaults(Theme.of(context).inputDecorationTheme),
      ),
      const SizedBox(height: 16),
      _PasswordField(
          ctrl: _passCtrl,
          label: 'Password',
          obscure: _obscure,
          accent: accent,
          onToggle: () => setState(() => _obscure = !_obscure)),
      const SizedBox(height: 16),
      _PasswordField(
          ctrl: _confCtrl,
          label: 'Confirm Password',
          obscure: _obscureC,
          accent: accent,
          onToggle: () => setState(() => _obscureC = !_obscureC)),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // ── Onboarding: State ─────────────────────────────────────────────
      Text(
        'Farm Onboarding',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: accent,
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _selectedState,
        hint: const Text('Select your state'),
        decoration: InputDecoration(
          labelText: 'State',
          prefixIcon: const Icon(Icons.map_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accent, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: _stateCrops.keys
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: _onStateChanged,
      ),

      // ── Onboarding: Crops (multi-select FilterChip) ────────────────────
      if (_selectedState != null) ...[
        const SizedBox(height: 20),
        Row(children: [
          Icon(Icons.grass, size: 18, color: accent),
          const SizedBox(width: 8),
          Text(
            'Select your crops (multiple allowed)',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700),
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableCrops.map((crop) {
            final selected = _selectedCrops.contains(crop);
            return FilterChip(
              label: Text(
                crop,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black87),
              ),
              selected: selected,
              onSelected: (_) => _toggleCrop(crop),
              selectedColor: accent,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey.shade100,
              side: BorderSide(
                  color: selected ? accent : Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            );
          }).toList(),
        ),
        if (_selectedCrops.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Text(
              '✅ Selected: ${_selectedCrops.join(', ')}',
              style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
        ],
      ],

      const SizedBox(height: 24),
      _PrimaryBtn(
          label: 'Create Farmer Account',
          color: accent,
          onPressed: _register),
    ]);
  }
}

// ===========================================================================
// Farmer Dashboard Placeholder
// ===========================================================================
class _FarmerDashboardPlaceholder extends StatelessWidget {
  const _FarmerDashboardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.agriculture, size: 80, color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text(
              'Farmer Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Coming soon in Module A!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Shared reusable widgets
// ===========================================================================

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  final Color accent;
  final bool enabled;
  final int? maxLength;
  final List<TextInputFormatter>? formatters;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    required this.accent,
    this.keyboard = TextInputType.text,
    this.enabled = true,
    this.maxLength,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      enabled: enabled,
      maxLength: maxLength,
      inputFormatters: formatters,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool obscure;
  final Color accent;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.ctrl,
    this.label = 'Password',
    required this.obscure,
    required this.accent,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _PrimaryBtn(
      {required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class _GoogleBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.g_mobiledata, size: 28),
      label: const Text('Continue with Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _SignUpSwitch extends StatelessWidget {
  final Color accent;
  const _SignUpSwitch({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?",
            style: TextStyle(color: Colors.grey.shade700)),
        TextButton(
          onPressed: () {},
          child: Text('Sign Up',
              style: TextStyle(
                  color: accent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _HintCard extends StatelessWidget {
  final String text;
  final Color color;
  const _HintCard(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ToggleTabBar extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool useLeft;
  final Color accent;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const _ToggleTabBar({
    required this.leftLabel,
    required this.rightLabel,
    required this.useLeft,
    required this.accent,
    required this.onLeft,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(children: [
        Expanded(
          child: _Chip(
              label: leftLabel,
              selected: useLeft,
              accent: accent,
              onTap: onLeft),
        ),
        Expanded(
          child: _Chip(
              label: rightLabel,
              selected: !useLeft,
              accent: accent,
              onTap: onRight),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _Chip(
      {required this.label,
      required this.selected,
      required this.accent,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: accent.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
