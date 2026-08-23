import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrated_agri_hub/screens/role_selection_screen.dart';
import 'package:integrated_agri_hub/screens/farmer_home_screen.dart';
import 'package:integrated_agri_hub/screens/admin_home_screen.dart';
import 'package:integrated_agri_hub/screens/shopkeeper_home_screen.dart';
import 'package:integrated_agri_hub/services/firebase_auth_service.dart';
import 'package:integrated_agri_hub/services/translation_service.dart';
import 'package:integrated_agri_hub/theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final List<String> _languages = ['English', 'Hindi (हिंदी)', 'Marathi (मराठी)'];

  void _showLoginOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const LoginOverlay();
      },
    );
  }

  void _showInfoOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TranslationService.tr('app_name'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A5934), // Forest green
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  TranslationService.tr('app_tagline'),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TranslationService(),
      builder: (context, _) {
        final currentLangName = TranslationService().currentLanguageName;
        return Scaffold(
          backgroundColor: AppTheme.backgroundCream, // Warm cream background
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentLangName,
                    icon: const Icon(Icons.language, color: AppTheme.primaryGreen),
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                    dropdownColor: AppTheme.backgroundCream,
                    items: _languages.map((String lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(lang),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        TranslationService().setLanguage(newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Elegant App Logo Emblem
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(6), // Space for the inner ring
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.lightGreen,
                                AppTheme.primaryGreen,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 56,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        TranslationService.tr('app_name'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        TranslationService.tr('app_tagline'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Log In Button
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.lightGreen, AppTheme.primaryGreen],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _showLoginOverlay(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            TranslationService.tr('login'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RoleSelectionScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            side: const BorderSide(
                              color: AppTheme.primaryGreen,
                              width: 2.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            TranslationService.tr('signup'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Login with G Button
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Google Sign-In coming soon! Please use Email & Password for now.'),
                                backgroundColor: Color(0xFF4A7C59),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 22)),
                              ],
                            ),
                          ),
                          label: Text(
                            TranslationService().currentLanguage == AppLanguage.hindi
                                ? 'गूगल से लॉगिन करें'
                                : TranslationService().currentLanguage == AppLanguage.marathi
                                    ? 'गुगलसह लॉगिन करा'
                                    : 'Login with Google',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
            // Info Button at Bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: IconButton(
                onPressed: () => _showInfoOverlay(context),
                icon: const Icon(Icons.info_outline),
                color: AppTheme.primaryGreen,
                iconSize: 28,
                splashColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                highlightColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}

class LoginOverlay extends StatefulWidget {
  const LoginOverlay({super.key});

  @override
  State<LoginOverlay> createState() => _LoginOverlayState();
}

class _LoginOverlayState extends State<LoginOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoginError = false;

  void _clearErrorIfPresent() {
    if (_hasLoginError || _errorMessage != null) {
      setState(() {
        _hasLoginError = false;
        _errorMessage = null;
      });
    }
  }

  void _handleLogin() async {
    final emailPhone = _emailPhoneController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _errorMessage = null;
      _hasLoginError = false;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (emailPhone.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
        _hasLoginError = true;
      });
      return;
    }

    // Admin backdoor
    if (emailPhone == 'GOV-ADMIN') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!emailPhone.contains('@')) {
        setState(() {
          _errorMessage = "For Phone Number login, OTP verification is required. Please use your registered Email to log in.";
          _hasLoginError = true;
          _isLoading = false;
        });
        return;
      }

      final user = await _authService.signInWithEmailAndPassword(emailPhone, password);
      
      if (user != null) {
        final role = await _authService.getUserRole(user.uid);
        
        if (mounted) {
          if (role == 'shopkeeper') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ShopkeeperHomeScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FarmerHomeScreen()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String friendlyMsg;
        switch (e.code) {
          case 'user-not-found':
          case 'invalid-email':
            friendlyMsg = "Couldn't find your account with this email. Please check your email or Sign Up.";
            break;
          case 'wrong-password':
            friendlyMsg = "Wrong password. Please enter the correct password.";
            break;
          case 'invalid-credential':
            friendlyMsg = "Entered email or password is wrong. Please enter the correct details.";
            break;
          case 'user-disabled':
            friendlyMsg = "This user account has been disabled.";
            break;
          case 'too-many-requests':
            friendlyMsg = "Too many failed attempts. Please try again in a few minutes.";
            break;
          case 'network-request-failed':
            friendlyMsg = "Network error. Please check your internet connection.";
            break;
          default:
            friendlyMsg = "Entered email or password is wrong. Please enter the correct details.";
        }
        setState(() {
          _errorMessage = friendlyMsg;
          _hasLoginError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Entered email or password is wrong. Please enter the correct details.";
          _hasLoginError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const errorBorderColor = Color(0xFFE02424);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                TranslationService().currentLanguage == AppLanguage.hindi
                    ? 'वापसी पर स्वागत है'
                    : TranslationService().currentLanguage == AppLanguage.marathi
                        ? 'पुन्हा स्वागत आहे'
                        : 'Welcome Back',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                TranslationService().currentLanguage == AppLanguage.hindi
                    ? 'अपने खाते में जारी रखने के लिए लॉगिन करें'
                    : TranslationService().currentLanguage == AppLanguage.marathi
                        ? 'आपल्या खात्यात पुढे जाण्यासाठी लॉगिन करा'
                        : 'Log in to continue to your account',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Google-style Inline Error Banner
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF8B4B4), width: 1.2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: errorBorderColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF9B1C1C),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _emailPhoneController,
                onChanged: (_) => _clearErrorIfPresent(),
                decoration: InputDecoration(
                  labelText: TranslationService.tr('email'),
                  labelStyle: TextStyle(
                    color: _hasLoginError ? errorBorderColor : null,
                    fontWeight: _hasLoginError ? FontWeight.w500 : FontWeight.normal,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: _hasLoginError ? errorBorderColor : AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: _hasLoginError ? errorBorderColor : null,
                  ),
                  filled: _hasLoginError,
                  fillColor: _hasLoginError ? const Color(0xFFFFF8F8) : Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasLoginError ? errorBorderColor : Colors.grey.shade300,
                      width: _hasLoginError ? 1.5 : 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasLoginError ? errorBorderColor : AppTheme.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email or phone number';
                  }
                  final trimmed = value.trim();
                  if (trimmed == 'GOV-ADMIN') return null;
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  final phoneRegex = RegExp(r'^\d{10}$');
                  if (!emailRegex.hasMatch(trimmed) && !phoneRegex.hasMatch(trimmed)) {
                    return 'Enter a valid email address or 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                onChanged: (_) => _clearErrorIfPresent(),
                decoration: InputDecoration(
                  labelText: TranslationService.tr('password'),
                  labelStyle: TextStyle(
                    color: _hasLoginError ? errorBorderColor : null,
                    fontWeight: _hasLoginError ? FontWeight.w500 : FontWeight.normal,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: _hasLoginError ? errorBorderColor : AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: _hasLoginError ? errorBorderColor : null,
                  ),
                  filled: _hasLoginError,
                  fillColor: _hasLoginError ? const Color(0xFFFFF8F8) : Colors.transparent,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: _hasLoginError ? errorBorderColor : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasLoginError ? errorBorderColor : Colors.grey.shade300,
                      width: _hasLoginError ? 1.5 : 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasLoginError ? errorBorderColor : AppTheme.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          TranslationService.tr('login'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
