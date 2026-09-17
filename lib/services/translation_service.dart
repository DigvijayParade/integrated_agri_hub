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
    'google_signin': {
      'en': 'Continue with Google',
      'hi': 'गूगल से जारी रखें (Google Sign-In)',
      'mr': 'गुगलसह पुढे जा (Google Sign-In)',
    },
    'official_admin_login': {
      'en': 'Govt Officer / Admin Portal',
      'hi': 'शासकीय अधिकारी पोर्टल',
      'mr': 'शासकीय अधिकारी पोर्टल',
    },
    'project_info_title': {
      'en': 'About Integrated Agri Hub Initiative',
      'hi': 'एकीकृत कृषि केंद्र परियोजना की जानकारी',
      'mr': 'एकात्मिक कृषी केंद्र प्रकल्पाची माहिती',
    },
    'project_vision': {
      'en': 'A Unified Digital Public Infrastructure (DPI) empowering Farmers, Agri-Dealers, and Agricultural Officers with AI agronomy, transparent price discovery, and sustainable green rewards.',
      'hi': 'एक एकीकृत डिजिटल पब्लिक इन्फ्रास्ट्रक्चर जो किसानों, कृषि व्यापारियों और अधिकारियों को AI कृषि परामर्श, पारदर्शी मंडी भाव और ग्रीन कॉइन्स से सशक्त बनाता है।',
      'mr': 'एक एकात्मिक डिजिटल पब्लिक इन्फ्रास्ट्रक्चर जे शेतकरी, कृषी व्यावसायिक आणि अधिकाऱ्यांना AI कृषी सल्ला, थेट बाजार भाव आणि ग्रीन कॉइन्सने सक्षम करते.',
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
    'welcome_hero_title': {
      'en': 'Your Complete Smart Farming Ecosystem',
      'hi': 'किसान और दुकानदार की हर ज़रूरत, एक ही मंच पर',
      'mr': 'शेतकरी आणि दुकानदारांसाठी संपूर्ण स्मार्ट शेती व्यासपीठ',
    },
    'welcome_hero_subtitle': {
      'en': 'AI Crop Doctor • Live Mandi Prices • Weather Advisories • Agri Supplies & Green Rewards',
      'hi': 'AI फसल डॉक्टर • लाइव मंडी भाव • मौसम सलाह • कृषि सामग्री और ग्रीन कॉइन्स',
      'mr': 'AI पीक डॉक्टर • थेट बाजार भाव • हवामान सल्ला • कृषी साहित्य आणि ग्रीन कॉइन्स',
    },
    'explore_features': {
      'en': 'Explore What You Can Do',
      'hi': 'ऐप की मुख्य सुविधाएं देखें',
      'mr': 'ॲपची प्रमुख वैशिष्ट्ये पहा',
    },
    'feature_ai_doctor': {
      'en': 'AI Crop Doctor',
      'hi': 'AI फसल डॉक्टर',
      'mr': 'AI पीक डॉक्टर',
    },
    'feature_ai_doctor_desc': {
      'en': 'Scan plant leaves to instantly detect diseases, pests and get organic remedy solutions.',
      'hi': 'पौधों की पत्तियों को स्कैन कर तुरंत रोग व कीट पहचानें और जैविक उपचार पाएं।',
      'mr': 'पाने स्कॅन करून त्वरित रोग व किडींचे निदान करा आणि सेंद्रिय उपाय मिळवा.',
    },
    'feature_mandi': {
      'en': 'Live APMC Mandi Rates',
      'hi': 'ताज़ा मंडी भाव (APMC)',
      'mr': 'थेट कृषी बाजार भाव (APMC)',
    },
    'feature_mandi_desc': {
      'en': 'Real-time daily market rates across districts to sell your harvest at the best price.',
      'hi': 'ज़िलावार दैनिक मंडी भाव देखें और अपनी उपज का सही व उच्चतम मूल्य प्राप्त करें।',
      'mr': 'जिल्ह्यानुसार रोजचे बाजार भाव तपासा आणि आपल्या शेतमालाला सर्वोत्तम भाव मिळवा.',
    },
    'feature_weather': {
      'en': 'Weather & Farm Advisories',
      'hi': 'मौसम एवं कृषि परामर्श',
      'mr': 'हवामान आणि शेती सल्ला',
    },
    'feature_weather_desc': {
      'en': 'Hyperlocal forecasts, rain alerts and tailored spraying & irrigation advice.',
      'hi': 'सटीक बारिश का पूर्वानुमान, छिड़काव और सिंचाई के लिए जरूरी मौसम सलाह।',
      'mr': 'अचूक पावसाचा अंदाज, फवारणी आणि सिंचनासाठी आवश्यक हवामान मार्गदर्शन.',
    },
    'feature_network': {
      'en': 'Verified Shopkeepers Network',
      'hi': 'प्रमाणित कृषि दुकानदार',
      'mr': 'नोंदणीकृत कृषी दुकानदार',
    },
    'feature_network_desc': {
      'en': 'Connect directly with trusted local agri-dealers for genuine seeds, fertilizers and tools.',
      'hi': 'खाद, बीज और कृषि उपकरणों के लिए अपने नज़दीकी सत्यापित डीलरों से सीधे जुड़ें।',
      'mr': 'खते, बियाणे आणि अवजारांसाठी जवळच्या विश्वासू विक्रेत्यांशी थेट संपर्क साधा.',
    },
    'feature_coins': {
      'en': 'Green Coins & Rewards',
      'hi': 'ग्रीन कॉइन्स एवं पुरस्कार',
      'mr': 'ग्रीन कॉइन्स आणि बक्षिसे',
    },
    'feature_coins_desc': {
      'en': 'Complete sustainable tasks & daily quizzes to earn Green Coins and redeem discounts.',
      'hi': 'दैनिक क्विज़ और कृषि कार्यों से कॉइन्स कमाएं और विशेष छूट प्राप्त करें।',
      'mr': 'दैनिक प्रश्नमंजुषा व शेती कामांतून कॉइन्स कमवा आणि आकर्षक सवलती मिळवा.',
    },
    'how_it_works': {
      'en': 'How It Works',
      'hi': 'यह कैसे काम करता है?',
      'mr': 'हे कसे कार्य करते?',
    },
    'step1_title': {
      'en': '1. Quick Registration',
      'hi': '1. आसान पंजीकरण',
      'mr': '1. सोपी नोंदणी',
    },
    'step1_desc': {
      'en': 'Sign up as a Farmer or Shopkeeper in under a minute with your details.',
      'hi': 'किसान या दुकानदार के रूप में 1 मिनट में अपना खाता बनाएं।',
      'mr': 'शेतकरी किंवा दुकानदार म्हणून एका मिनिटात आपले खाते तयार करा.',
    },
    'step2_title': {
      'en': '2. Access Smart Tools',
      'hi': '2. स्मार्ट टूल्स का उपयोग',
      'mr': '2. स्मार्ट टूल्सचा वापर',
    },
    'step2_desc': {
      'en': 'Get AI recommendations, track live mandi prices, and check local weather.',
      'hi': 'AI सलाह पाएं, लाइव मंडी भाव ट्रैक करें और मौसम की जानकारी लें।',
      'mr': 'AI सल्ला मिळवा, थेट बाजार भाव तपासा आणि हवामानाची माहिती घ्या.',
    },
    'step3_title': {
      'en': '3. Earn & Grow',
      'hi': '3. कमाएं और समृद्धि पाएं',
      'mr': '3. कमवा आणि समृद्ध व्हा',
    },
    'step3_desc': {
      'en': 'Earn Green Coins, build your farm streak, and maximize your farm revenue.',
      'hi': 'ग्रीन कॉइन्स कमाएं, अपनी स्ट्रीक बनाएं और खेती का मुनाफा बढ़ाएं।',
      'mr': 'ग्रीन कॉइन्स मिळवा, स्ट्रीक कायम ठेवा आणि शेतीतील नफा वाढवा.',
    },
    'get_started': {
      'en': 'Get Started / Register',
      'hi': 'शुरू करें / नया खाता बनाएं',
      'mr': 'सुरु करा / नोंदणी करा',
    },
    'about_app_desc': {
      'en': 'Integrated Agri Hub connects farmers, shopkeepers, and agricultural experts into a unified digital platform. From AI-powered crop disease detection to live market prices and Green Coin rewards, we empower every stakeholder in agriculture.',
      'hi': 'एकीकृत कृषि केंद्र किसानों, दुकानदारों और कृषि विशेषज्ञों को एक मंच पर जोड़ता है। AI फसल रोग पहचान से लेकर लाइव मंडी भाव और ग्रीन कॉइन्स पुरस्कारों तक, हम कृषि के हर पहलू को समृद्ध बनाते हैं।',
      'mr': 'एकात्मिक कृषी केंद्र शेतकरी, दुकानदार आणि कृषी तज्ञांना एकाच मंचावर एकत्र आणते. AI पीक रोग निदानापासून थेट बाजार भाव आणि ग्रीन कॉइन्स बक्षिसांपर्यंत, आम्ही शेतीच्या प्रत्येक टप्प्यावर मदत करतो.',
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
