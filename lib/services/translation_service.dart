import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

enum AppLanguage { english, hindi, marathi }

class TranslationService extends ChangeNotifier {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  AppLanguage _currentLanguage = AppLanguage.english;
  AppLanguage get currentLanguage => _currentLanguage;

  String get currentLanguageCode {
    switch (_currentLanguage) {
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.marathi:
        return 'mr';
      case AppLanguage.english:
        return 'en';
    }
  }

  String get currentLanguageName {
    switch (_currentLanguage) {
      case AppLanguage.hindi:
        return 'Hindi (हिंदी)';
      case AppLanguage.marathi:
        return 'Marathi (मराठी)';
      case AppLanguage.english:
        return 'English';
    }
  }

  void setLanguage(String lang) {
    final lower = lang.toLowerCase();
    if (lower.contains('hindi') || lower.contains('हिंदी') || lower == 'hi') {
      _currentLanguage = AppLanguage.hindi;
    } else if (lower.contains('marathi') || lower.contains('मराठी') || lower == 'mr') {
      _currentLanguage = AppLanguage.marathi;
    } else {
      _currentLanguage = AppLanguage.english;
    }
    notifyListeners();
  }

  /// Instant Translation Dictionary for All Screens
  static final Map<String, Map<String, String>> _localizedValues = {
    // --- Welcome & Auth ---
    'app_name': {
      'en': 'Integrated Agri Hub',
      'hi': 'एकीकृत कृषि केंद्र (Integrated Agri Hub)',
      'mr': 'एकात्मिक कृषी केंद्र (Integrated Agri Hub)',
    },
    'app_tagline': {
      'en': 'Smart Agriculture, Green Rewards & Empowered Farmers',
      'hi': 'स्मार्ट कृषि, हरित पुरस्कार एवं समृद्ध किसान',
      'mr': 'स्मार्ट शेती, ग्रीन कॉइन्स आणि समृद्ध शेतकरी',
    },
    'login': {
      'en': 'Log In',
      'hi': 'लॉग इन करें',
      'mr': 'लॉग इन करा',
    },
    'signup': {
      'en': 'Sign Up',
      'hi': 'साइन अप करें',
      'mr': 'साइन अप करा',
    },
    'create_account': {
      'en': 'Create an Account',
      'hi': 'नया खाता बनाएं',
      'mr': 'नवीन खाते तयार करा',
    },
    'email': {
      'en': 'Email Address',
      'hi': 'ईमेल पता',
      'mr': 'ईमेल पत्ता',
    },
    'password': {
      'en': 'Password',
      'hi': 'पासवर्ड',
      'mr': 'पासवर्ड',
    },
    'enter_email': {
      'en': 'Enter your email',
      'hi': 'अपना ईमेल दर्ज करें',
      'mr': 'आपला ईमेल टाका',
    },
    'enter_password': {
      'en': 'Enter your password',
      'hi': 'अपना पासवर्ड दर्ज करें',
      'mr': 'आपला पासवर्ड टाका',
    },
    'select_role': {
      'en': 'Select Your Role',
      'hi': 'अपनी भूमिका चुनें',
      'mr': 'आपली भूमिका निवडा',
    },
    'farmer': {
      'en': 'Farmer',
      'hi': 'किसान (Farmer)',
      'mr': 'शेतकरी (Farmer)',
    },
    'shopkeeper': {
      'en': 'Shopkeeper',
      'hi': 'दुकानदार (Shopkeeper)',
      'mr': 'दुकानदार (Shopkeeper)',
    },
    'admin': {
      'en': 'Government Admin',
      'hi': 'शासकीय अधिकारी (Govt Admin)',
      'mr': 'शासकीय अधिकारी (Govt Admin)',
    },
    'logout': {
      'en': 'Sign Out',
      'hi': 'लॉग आउट',
      'mr': 'लॉग आउट',
    },

    // --- Dashboard Tabs & Common Navigation ---
    'dashboard': {
      'en': 'Dashboard',
      'hi': 'डैशबोर्ड',
      'mr': 'डॅशबोर्ड',
    },
    'market_prices': {
      'en': 'APMC Market Prices',
      'hi': 'मंडी भाव (APMC)',
      'mr': 'बाजार भाव (APMC)',
    },
    'tasks': {
      'en': 'Tasks & Rewards',
      'hi': 'कार्य एवं पुरस्कार',
      'mr': 'कार्ये आणि बक्षिसे',
    },
    'education': {
      'en': 'AI Crop Education',
      'hi': 'कृषि शिक्षा एवं वीडियो',
      'mr': 'कृषी शिक्षण आणि व्हिडिओ',
    },
    'quizzes': {
      'en': 'Knowledge Quizzes',
      'hi': 'दैनिक क्विज़',
      'mr': 'दैनिक प्रश्नमंजुषा',
    },

    // --- Farmer Wallet & Stats ---
    'green_coins': {
      'en': 'Green Coins',
      'hi': 'ग्रीन कॉइन्स',
      'mr': 'ग्रीन कॉइन्स',
    },
    'streak': {
      'en': 'Day Streak',
      'hi': 'दैनिक स्ट्रीक',
      'mr': 'दैनिक स्ट्रीक',
    },
    'verified_tasks': {
      'en': 'Verified Tasks',
      'hi': 'सत्यापित कार्य',
      'mr': 'तपासलेली कार्ये',
    },
    'earn_coins': {
      'en': 'Earn 100 Coins',
      'hi': '+100 कॉइन्स जीतें',
      'mr': '+100 कॉइन्स मिळवा',
    },
    'scan_qr_pay': {
      'en': 'Scan QR & Redeem Coins',
      'hi': 'QR स्कैन करें व कॉइन रिडीम करें',
      'mr': 'QR स्कॅन करा आणि नाणी वापरा',
    },

    // --- Profile Modal & Fields ---
    'farmer_profile': {
      'en': 'Farmer Profile',
      'hi': 'किसान प्रोफाइल',
      'mr': 'शेतकरी प्रोफाइल',
    },
    'shopkeeper_profile': {
      'en': 'Shopkeeper Profile',
      'hi': 'दुकानदार प्रोफाइल',
      'mr': 'दुकानदार प्रोफाइल',
    },
    'edit_profile': {
      'en': 'Edit Profile',
      'hi': 'प्रोफाइल संपादित करें',
      'mr': 'माहिती बदला',
    },
    'save_profile': {
      'en': 'Save Changes',
      'hi': 'सुरक्षित करें',
      'mr': 'जतन करा',
    },
    'state': {
      'en': 'State',
      'hi': 'राज्य',
      'mr': 'राज्य',
    },
    'district': {
      'en': 'District',
      'hi': 'ज़िला',
      'mr': 'जिल्हा',
    },
    'farm_size': {
      'en': 'Farm Size (Acres)',
      'hi': 'खेत का आकार (एकड़)',
      'mr': 'शेताचा आकार (एकर)',
    },
    'registered_crops': {
      'en': 'Registered Crops',
      'hi': 'पंजीकृत फसलें',
      'mr': 'नोंदणीकृत पिके',
    },
    'today_lesson': {
      'en': 'Today\'s Lesson',
      'hi': 'आज का पाठ',
      'mr': 'आजचा धडा',
    },
    'listen_audio': {
      'en': 'Listen to Audio Guide',
      'hi': 'ऑडियो मार्गदर्शन सुनें',
      'mr': 'ऑडिओ मार्गदर्शन ऐका',
    },
    'start_quiz': {
      'en': 'Start Today\'s AI Quiz',
      'hi': 'आज की AI क्विज़ शुरू करें',
      'mr': 'आजची AI प्रश्नमंजुषा सुरू करा',
    },
    'hindi_videos': {
      'en': 'Hindi Video Tutorials',
      'hi': 'हिंदी में वीडियो ट्यूटोरियल',
      'mr': 'व्हिडिओ ट्यूटोरियल',
    },

    // --- Shopkeeper ---
    'home': {
      'en': 'Home',
      'hi': 'होम',
      'mr': 'होम',
    },
    'inventory': {
      'en': 'Inventory',
      'hi': 'इन्वेंटरी',
      'mr': 'साठा',
    },
    'ledger': {
      'en': 'Ledger',
      'hi': 'खाता-बही',
      'mr': 'खातेवही',
    },
    'scan': {
      'en': 'Scan',
      'hi': 'स्कैन',
      'mr': 'स्कॅन',
    },
    'today_sales': {
      'en': 'Today\'s Sales',
      'hi': 'आज की बिक्री',
      'mr': 'आजची विक्री',
    },
    'store_name': {
      'en': 'Store Name',
      'hi': 'दुकान का नाम',
      'mr': 'दुकानाचे नाव',
    },
    'shop_address': {
      'en': 'Shop Address',
      'hi': 'दुकान का पता',
      'mr': 'दुकानाचा पत्ता',
    },
    'license_no': {
      'en': 'License No.',
      'hi': 'लाइसेंस नंबर',
      'mr': 'परवाना क्रमांक',
    },
    'coins_received': {
      'en': 'Green Coins Received',
      'hi': 'प्राप्त ग्रीन कॉइन्स',
      'mr': 'प्राप्त ग्रीन कॉइन्स',
    },

    // --- Admin ---
    'admin_dashboard': {
      'en': 'Admin Dashboard',
      'hi': 'प्रशासन डैशबोर्ड',
      'mr': 'प्रशासन डॅशबोर्ड',
    },

    // --- Common Actions ---
    'welcome_back': {
      'en': 'Welcome Back',
      'hi': 'वापसी पर स्वागत है',
      'mr': 'पुन्हा स्वागत आहे',
    },
    'search': {
      'en': 'Search',
      'hi': 'खोजें',
      'mr': 'शोधा',
    },
    'notifications': {
      'en': 'Notifications',
      'hi': 'सूचनाएं',
      'mr': 'सूचना',
    },
    'settings': {
      'en': 'Settings',
      'hi': 'सेटिंग्स',
      'mr': 'सेटिंग्ज',
    },
    'profile': {
      'en': 'Profile',
      'hi': 'प्रोफाइल',
      'mr': 'प्रोफाइल',
    },
    'name': {
      'en': 'Full Name',
      'hi': 'पूरा नाम',
      'mr': 'पूर्ण नाव',
    },
    'phone': {
      'en': 'Phone',
      'hi': 'फोन',
      'mr': 'फोन',
    },
    'language': {
      'en': 'Language',
      'hi': 'भाषा',
      'mr': 'भाषा',
    },
    'total_earnings': {
      'en': 'Total Earnings',
      'hi': 'कुल कमाई',
      'mr': 'एकूण कमाई',
    },
    'add_product': {
      'en': 'Add Product',
      'hi': 'उत्पाद जोड़ें',
      'mr': 'उत्पादन जोडा',
    },
    'quantity': {
      'en': 'Quantity',
      'hi': 'मात्रा',
      'mr': 'प्रमाण',
    },
    'price': {
      'en': 'Price',
      'hi': 'कीमत',
      'mr': 'किंमत',
    },
    'generate_qr': {
      'en': 'Generate QR Code',
      'hi': 'QR कोड बनाएं',
      'mr': 'QR कोड तयार करा',
    },
  };

  /// Translate a predefined key into the currently selected language
  static String tr(String key) {
    final langCode = _instance.currentLanguageCode;
    final map = _localizedValues[key];
    if (map != null && map.containsKey(langCode)) {
      return map[langCode]!;
    }
    return map?['en'] ?? key;
  }

  /// Dynamic Translator: Translates any dynamic text using Google Translate free endpoint
  Future<String> translateDynamicText(String text, {String? targetLang}) async {
    final target = targetLang ?? currentLanguageCode;
    if (target == 'en' || text.trim().isEmpty) return text;

    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$target&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final client = HttpClient();
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 4));
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List jsonResponse = jsonDecode(responseBody);
        if (jsonResponse.isNotEmpty && jsonResponse[0] is List) {
          final buffer = StringBuffer();
          for (var item in jsonResponse[0]) {
            if (item is List && item.isNotEmpty) {
              buffer.write(item[0]);
            }
          }
          final result = buffer.toString().trim();
          if (result.isNotEmpty) return result;
        }
      }
    } catch (_) {
      // Fallback to original text if offline
    }

    return text;
  }
}

extension StringTranslateExtension on String {
  String get tr => TranslationService.tr(this);
}
