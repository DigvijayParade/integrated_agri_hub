import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  GenerativeModel? _visionModel;

  void _initVisionModel() {
    if (_visionModel != null) return;
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
      throw Exception('Gemini API Key is missing or invalid in .env file.');
    }
    _visionModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// Verifies if the provided image matches the task description.
  /// Returns a boolean indicating if it's verified.
  Future<bool> verifyTaskPhoto(String imagePath, String taskDescription) async {
    try {
      _initVisionModel();
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      
      final prompt = TextPart(
          'Does this image show "$taskDescription"? Answer ONLY with "Yes" or "No".');
      final imagePart = DataPart('image/jpeg', bytes);

      final response = await _visionModel!.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text?.trim().toLowerCase() ?? '';
      if (kDebugMode) print('Gemini Response: $text');
      
      return text.contains('yes');
    } catch (e) {
      if (kDebugMode) print('Gemini AI Verification Error: $e');
      return false;
    }
  }
}
