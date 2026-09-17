import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  TtsService() {
    _initTts();
  }

  void _initTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.38); // Standard rate from original project
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
    });

    _flutterTts.setCancelHandler(() {
      _isPlaying = false;
    });
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
      _isPlaying = true;
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;
}
