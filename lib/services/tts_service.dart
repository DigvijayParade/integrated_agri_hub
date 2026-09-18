import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService extends ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  String _currentLanguage = "en-US";

  TtsService._internal() {
    _initTts();
  }

  void _initTts() {
    _flutterTts.setLanguage(_currentLanguage);
    _flutterTts.setSpeechRate(0.38); // Standard rate from original project
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      notifyListeners();
    });

    _flutterTts.setCancelHandler(() {
      _isPlaying = false;
      notifyListeners();
    });
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _flutterTts.setLanguage(languageCode);
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      if (_isPlaying) {
        await stop();
      }
      await _flutterTts.speak(text);
      _isPlaying = true;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      _isPlaying = false;
      notifyListeners();
    }
  }

  bool get isPlaying => _isPlaying;
}
