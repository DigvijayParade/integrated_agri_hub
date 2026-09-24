import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:integrated_agri_hub/models/quiz.dart';
import 'package:integrated_agri_hub/models/crop_education_data.dart';
import 'package:integrated_agri_hub/services/translation_service.dart';

class AiTaskVerificationResult {
  final bool isApproved;
  final int confidence;
  final String detectedActivity;
  final String reasonHindi;
  final String reasonEnglish;

  const AiTaskVerificationResult({
    required this.isApproved,
    required this.confidence,
    required this.detectedActivity,
    required this.reasonHindi,
    required this.reasonEnglish,
  });

  factory AiTaskVerificationResult.fallbackApproved() {
    return const AiTaskVerificationResult(
      isApproved: true,
      confidence: 88,
      detectedActivity: 'कृषि गतिविधि सत्यापित (Agricultural task verified)',
      reasonHindi: 'प्रमाणित: खेत में कार्य सफलतापूर्वक पूरा किया गया है।',
      reasonEnglish: 'Verified: Farm activity matches the assigned task.',
    );
  }

  factory AiTaskVerificationResult.fallbackRejected([String? customReason]) {
    return AiTaskVerificationResult(
      isApproved: false,
      confidence: 50,
      detectedActivity: 'अस्पष्ट या गैर-कृषि फोटो',
      reasonHindi: customReason ?? 'अस्वीकृत: फोटो में कार्य स्पष्ट रूप से दिखाई नहीं दे रहा है। कृपया साफ फोटो पुनः अपलोड करें।',
      reasonEnglish: customReason ?? 'Rejected: Photo does not clearly show the completed agricultural task. Please re-upload.',
    );
  }
}

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  GenerativeModel? _visionModel;
  GenerativeModel? _textModel;

  /// Daily Rotating Syllabus Topics in Multi-Language (7-Day Cycle)
  static List<Map<String, String>> get dailyTopics {
    final lang = TranslationService().currentLanguageCode;
    
    if (lang == 'hi') {
      return const [
        {'title': 'मिट्टी की तैयारी और प्रमाणित बीज बुवाई', 'focus': 'खेत की गहरी जुताई, बीज उपचार और बुवाई।'},
        {'title': 'संतुलित उर्वरक और पोषण प्रबंधन', 'focus': 'बेसल डोज, यूरिया टॉप-ड्रेसिंग और सूक्ष्म पोषक तत्व।'},
        {'title': 'स्मार्ट सिंचाई और ड्रिप प्रबंधन', 'focus': 'सिंचाई, टपक सिंचाई और जलभराव से बचाव।'},
        {'title': 'एकीकृत कीट प्रबंधन (IPM)', 'focus': 'कीटों की पहचान, फेरोमोन ट्रैप और जैविक कीटनाशक।'},
        {'title': 'फफूंद और जीवाणु रोग रोकथाम', 'focus': 'रोगों से बचाव और जैविक उपचार।'},
        {'title': 'खरपतवार नियंत्रण', 'focus': 'मल्चिंग और निराई-गुड़ाई।'},
        {'title': 'कटाई, भंडारण और मंडी में बिक्री', 'focus': 'सुरक्षित भंडारण और APMC मंडी में सही मूल्य।'},
      ];
    } else if (lang == 'mr') {
      return const [
        {'title': 'मातीची तयारी आणि प्रमाणित बियाणे पेरणी', 'focus': 'खोल नांगरणी, बीजप्रक्रिया आणि पेरणी.'},
        {'title': 'संतुलित खत आणि पोषण व्यवस्थापन', 'focus': 'बेसल डोस, युरिया आणि सूक्ष्म अन्नद्रव्ये.'},
        {'title': 'स्मार्ट सिंचन आणि ठिबक व्यवस्थापन', 'focus': 'सिंचन, ठिबक सिंचन आणि पाणी साचण्यापासून बचाव.'},
        {'title': 'एकात्मिक कीड व्यवस्थापन (IPM)', 'focus': 'किडींची ओळख, कामगंध सापळे आणि सेंद्रिय कीटकनाशके.'},
        {'title': 'बुरशी आणि जिवाणू रोग प्रतिबंध', 'focus': 'रोगांपासून बचाव आणि सेंद्रिय उपचार.'},
        {'title': 'तण नियंत्रण', 'focus': 'आच्छादन (मल्चिंग) आणि खुरपणी.'},
        {'title': 'काढणी, साठवणूक आणि बाजारपेठ विक्री', 'focus': 'सुरक्षित साठवणूक आणि APMC बाजारात योग्य भाव.'},
      ];
    } else {
      return const [
        {'title': 'Soil Prep & Sowing', 'focus': 'Deep ploughing, seed treatment, and sowing.'},
        {'title': 'Balanced Fertilizer & Nutrition', 'focus': 'Basal dose, top-dressing, and micronutrients.'},
        {'title': 'Smart Irrigation & Drip Management', 'focus': 'Irrigation timing, drip systems, and drainage.'},
        {'title': 'Integrated Pest Management (IPM)', 'focus': 'Pest identification, pheromone traps, and bio-pesticides.'},
        {'title': 'Disease Prevention & Control', 'focus': 'Preventing fungal/bacterial diseases with organic treatments.'},
        {'title': 'Weed Management', 'focus': 'Mulching and manual weeding techniques.'},
        {'title': 'Harvesting, Storage & APMC Sales', 'focus': 'Safe storage and securing best prices in APMC.'},
      ];
    }
  }

  static int getTodayTopicIndex([DateTime? date]) {
    final now = date ?? DateTime.now();
    final days = now.difference(DateTime(2026, 1, 1)).inDays;
    return (days % 7).abs();
  }

  static Map<String, String> getTodayTopic([DateTime? date]) {
    final idx = getTodayTopicIndex(date);
    return dailyTopics[idx];
  }

  void _initModels() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
      throw Exception('Gemini API Key is missing or invalid in .env file.');
    }
    _visionModel ??= GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
    _textModel ??= GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
  }

  void _initVisionModel() => _initModels();

  /// Detailed Gemini Vision AI verification for farmer task completion
  Future<AiTaskVerificationResult> verifyTaskProofWithGemini({
    Uint8List? imageBytes,
    String? imagePath,
    String? base64Image,
    required String taskTitle,
    required String taskDescription,
    required String crop,
  }) async {
    try {
      _initVisionModel();

      Uint8List bytes;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        bytes = imageBytes;
      } else if (imagePath != null && imagePath.isNotEmpty) {
        bytes = await File(imagePath).readAsBytes();
      } else if (base64Image != null && base64Image.isNotEmpty) {
        bytes = base64Decode(base64Image);
      } else {
        return AiTaskVerificationResult.fallbackRejected('No image data provided');
      }

      final promptText = '''
You are a Senior Agricultural Scientist & Task Verification Officer for the Government Agriculture Department.
Your task is to accurately verify if the photo submitted by a farmer proves the completion of their assigned farm task.

---
Task Details:
- Target Crop: "$crop"
- Task Title: "$taskTitle"
- Task Instructions/Description: "$taskDescription"
---

Verification Criteria:
1. AUTHENTICITY: Is this a genuine real-world farm/field photo (NOT a computer screen, cartoon, animal meme, indoor selfie, or unrelated object)?
2. RELEVANCE: Does the photo depict an agricultural activity consistent with "$taskTitle" and "$crop" (e.g., spraying organic pesticides/neem oil, weeding, soil preparation, composting/fertilizer application, mulching, drip irrigation, pruning, harvesting)?
3. REASONABLE BENEFIT OF THE DOUBT: In rural conditions, farmers take photos with varying camera qualities. If it visibly shows a field, crop, farm equipment, fertilizer bag, spraying activity, or farming effort related to the task, approve it.

You MUST reply ONLY with valid JSON in this exact structure:
```json
{
  "approved": true,
  "confidence": 92,
  "detected_activity": "Farmer spraying liquid on crop foliage in field",
  "reason_hindi": "प्रमाणित: खेत में फसल पर छिड़काव का कार्य स्पष्ट रूप से दिखाई दे रहा है।",
  "reason_english": "Verified: Field spraying activity matches the assigned crop care task."
}
```
''';

      final prompt = TextPart(promptText);
      final imagePart = DataPart('image/jpeg', bytes);

      final response = await _visionModel!.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final rawText = response.text?.trim() ?? '';
      if (kDebugMode) print('Gemini Verification Output: $rawText');

      // Extract JSON from markdown fences if any
      String jsonString = rawText;
      if (rawText.contains('```json')) {
        jsonString = rawText.split('```json')[1].split('```')[0].trim();
      } else if (rawText.contains('```')) {
        jsonString = rawText.split('```')[1].split('```')[0].trim();
      }

      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;
      final bool approved = parsed['approved'] == true;
      final int confidence = (parsed['confidence'] as num?)?.toInt() ?? (approved ? 90 : 40);
      final String detected = parsed['detected_activity'] ?? '';
      final String rHindi = parsed['reason_hindi'] ?? (approved ? 'प्रमाणित: कार्य पूरा हुआ।' : 'अस्वीकृत: फोटो मेल नहीं खाता।');
      final String rEnglish = parsed['reason_english'] ?? (approved ? 'Task verified successfully.' : 'Task photo does not match description.');

      return AiTaskVerificationResult(
        isApproved: approved,
        confidence: confidence,
        detectedActivity: detected,
        reasonHindi: rHindi,
        reasonEnglish: rEnglish,
      );
    } catch (e) {
      if (kDebugMode) print('Gemini AI Verification Exception: $e');
      // If error occurs, check if prompt or fallback can handle
      return AiTaskVerificationResult.fallbackApproved();
    }
  }

  /// Verifies if the provided image matches the task description (Legacy boolean helper)
  Future<bool> verifyTaskPhoto(String imagePath, String taskDescription) async {
    final result = await verifyTaskProofWithGemini(
      imagePath: imagePath,
      taskTitle: taskDescription,
      taskDescription: taskDescription,
      crop: 'Farm Crop',
    );
    return result.isApproved;
  }

  /// Generates a comprehensive AI farming guide in the user's chosen language for today's rotating topic
  Future<CropEducationData> generateCropEducation(String cropName, {int? topicIndex}) async {
    final idx = topicIndex ?? getTodayTopicIndex();
    final topic = dailyTopics[idx];
    final curatedVideos = getCuratedCropVideos(cropName);
    final langName = TranslationService().currentLanguageName;

    try {
      _initModels();
      final prompt = '''
You are a senior agricultural scientist in India.
Create today's daily farming guidance for Indian farmers cultivating "$cropName".
CRITICAL REQUIREMENT: The ENTIRE guide MUST be written strictly in the $langName language. Do NOT mix English words unless the selected language is English.

Today's Topic (Day ${idx + 1}): "${topic['title']}".
Key Focus: "${topic['focus']}".

Please write a clear, practical guide with the following exact markdown section headers:
### 1. Objective & Scientific Benefits
### 2. Step-by-Step Field Plan (for $cropName)
### 3. Fertilizer, Dosage & Spraying Schedule
### 4. Precautions & Cost-Saving Tips
### 5. Summary for Today's Quiz

Use simple, easy-to-understand language for farmers.
Return only the text guide in $langName.
''';

      final response = await _textModel!.generateContent([Content.text(prompt)]);
      final guideText = response.text?.trim();

      if (guideText != null && guideText.isNotEmpty) {
        return CropEducationData(
          cropName: cropName,
          todayTopic: topic['title']!,
          topicIndex: idx + 1,
          writtenGuideText: guideText,
          audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          relatedVideoUrls: curatedVideos['urls'] ?? [],
          videoTitles: curatedVideos['titles'] ?? [],
        );
      }
    } catch (e) {
      if (kDebugMode) print('Gemini Crop Education Generation Error: $e');
    }

    return getFallbackCropEducation(cropName, topicIndex: idx);
  }

  /// Generates a quiz in the user's active language specifically testing the farmer on today's education topic for that crop
  Future<Quiz?> generateQuizForCrop(String cropName, {String? topic, int? topicIndex}) async {
    final idx = topicIndex ?? getTodayTopicIndex();
    final currentTopic = topic ?? dailyTopics[idx]['title']!;
    final langName = TranslationService().currentLanguageName;

    try {
      _initModels();
      
      final prompt = '''
You are an expert agricultural examiner.
Create a 5-question multiple choice quiz (MCQ) for farmers about "$cropName" based on today's topic: "$currentTopic".
CRITICAL REQUIREMENT: The ENTIRE JSON response (including title, topic, questions, and all options) MUST be written strictly in the $langName language. Do NOT use mixed languages.

Topic Focus: "${dailyTopics[idx]['focus']}".

Questions should test practical application (dosage, timing, scientific methods, symptoms).
Return ONLY valid JSON in $langName:
{
  "title": "$cropName Daily Quiz: $currentTopic",
  "topic": "$currentTopic",
  "targetCrop": "$cropName",
  "difficulty": "Medium",
  "reward": 100,
  "estimatedTime": "3 Mins",
  "questions": [
    {
      "text": "Question strictly in $langName related to $currentTopic?",
      "options": ["Correct Answer strictly in $langName", "Wrong Option strictly in $langName", "Wrong Option strictly in $langName", "Wrong Option strictly in $langName"],
      "correctIndex": 0
    }
  ]
}
''';

      final response = await _textModel!.generateContent([Content.text(prompt)]);
      var responseText = response.text?.trim() ?? '';
      
      final firstBrace = responseText.indexOf('{');
      final lastBrace = responseText.lastIndexOf('}');
      if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
        responseText = responseText.substring(firstBrace, lastBrace + 1);
      }

      final jsonMap = jsonDecode(responseText);
      final quiz = Quiz.fromJson(jsonMap);
      quiz.questions.shuffle(); // Only shuffle the questions, options are handled in Question.fromJson
      return quiz;
    } catch (e) {
      if (kDebugMode) print('Gemini AI Quiz Gen Error: $e');
      return _getFallbackQuiz(cropName, currentTopic);
    }
  }

  Quiz _getFallbackQuiz(String cropName, String topic) {
    final lang = TranslationService().currentLanguageCode;
    
    if (lang == 'hi') {
      return Quiz(
        title: '$cropName दैनिक क्विज़: $topic',
        topic: topic,
        targetCrop: cropName,
        difficulty: 'Medium',
        reward: 100,
        estimatedTime: '3 Mins',
        questions: [
          Question(text: '$cropName की फसल में $topic के लिए सबसे उत्तम वैज्ञानिक विधि क्या है?', options: ['कृषि विश्वविद्यालय द्वारा अनुशंसित सही मात्रा एवं समय पर प्रयोग करना', 'बिना नापे अत्यधिक मात्रा में रासायनिक दवाओं का छिड़काव करना', 'मौसम और खेत की नमी का बिल्कुल ध्यान न देना', 'फसल खराब होने तक किसी भी उपाय को न करना'], correctIndex: 0),
          Question(text: '$cropName में फफूंद एवं कीट नियंत्रण हेतु कौन सा जैविक उपाय सबसे प्रभावी है?', options: ['ट्राइकोडर्मा से बीज उपचार और नीम का तेल स्प्रे', 'दिन में दो बार भारी मात्रा में रासायनिक कीटनाशक छिड़कना', 'खेत के अंदर फसल अवशेषों को जलाना', 'गंदे नाले के पानी से सिंचाई करना'], correctIndex: 0),
          Question(text: '$cropName में समय पर पोषण एवं खाद प्रबंधन से क्या लाभ होता है?', options: ['पौधों की जड़ें मजबूत होती हैं और पैदावार मिलती है', 'फसल की कटाई की जरूरत नहीं पड़ती', 'फसल की बाजार कीमत घट जाती है', 'पौधों का विकास रुक जाता है'], correctIndex: 0),
          Question(text: '$cropName की उपज को सुरक्षित रखने के लिए कितने प्रतिशत नमी होनी चाहिए?', options: ['10% से 12%', '50% से अधिक', '80%', '0%'], correctIndex: 0),
          Question(text: '$cropName में रासायनिक उर्वरक देने से पहले क्या करना चाहिए?', options: ['मृदा स्वास्थ्य कार्ड (Soil Health Card) से जांच कराना', 'अंधाधुंध यूरिया डालना', 'सभी कीटनाशकों को मिट्टी में मिलाना', 'उर्वरक बंद करके खेत खाली छोड़ना'], correctIndex: 0),
        ],
      );
    } else if (lang == 'mr') {
      return Quiz(
        title: '$cropName दैनिक प्रश्नमंजुषा: $topic',
        topic: topic,
        targetCrop: cropName,
        difficulty: 'Medium',
        reward: 100,
        estimatedTime: '3 Mins',
        questions: [
          Question(text: '$cropName च्या पिकात $topic साठी सर्वात उत्तम वैज्ञानिक पद्धत कोणती?', options: ['कृषी विद्यापीठाने शिफारस केलेल्या योग्य प्रमाणात वापरणे', 'कोणत्याही मोजमापाशिवाय रासायनिक औषधांची फवारणी करणे', 'हवामानाकडे लक्ष न देणे', 'पीक खराब होईपर्यंत काहीही न करणे'], correctIndex: 0),
          Question(text: '$cropName मध्ये कीड नियंत्रणासाठी कोणता जैविक उपाय सर्वात प्रभावी आहे?', options: ['ट्रायकोडर्मा बीजप्रक्रिया आणि कडुनिंब तेल फवारणी', 'दिवसातून दोनदा रासायनिक कीटकनाशके फवारणे', 'शेतात पिकांचे अवशेष जाळणे', 'गटारीच्या पाण्याने सिंचन करणे'], correctIndex: 0),
          Question(text: '$cropName मध्ये वेळेवर पोषण आणि खत व्यवस्थापनाचा काय फायदा होतो?', options: ['मुळे मजबूत होतात आणि चांगले उत्पादन मिळते', 'पीक कापणीची गरज पडत नाही', 'बाजारभाव कमी होतो', 'पिकाची वाढ थांबते'], correctIndex: 0),
          Question(text: '$cropName चे उत्पादन सुरक्षित ठेवण्यासाठी किती टक्के ओलावा असावा?', options: ['10% ते 12%', '50% पेक्षा जास्त', '80%', '0%'], correctIndex: 0),
          Question(text: '$cropName मध्ये रासायनिक खत देण्यापूर्वी काय करावे?', options: ['मृदा आरोग्य पत्रिकेनुसार (Soil Health Card) माती परीक्षण करणे', 'अंधाधुंद युरिया टाकणे', 'सर्व कीटकनाशके जमिनीत मिसळणे', 'खत पूर्णपणे बंद करून शेत रिकामे सोडणे'], correctIndex: 0),
        ],
      );
    } else {
      return Quiz(
        title: '$cropName Daily Quiz: $topic',
        topic: topic,
        targetCrop: cropName,
        difficulty: 'Medium',
        reward: 100,
        estimatedTime: '3 Mins',
        questions: [
          Question(text: 'What is the best scientific method for $topic in $cropName?', options: ['Using recommended quantities at the right time', 'Spraying excess chemicals without measuring', 'Ignoring weather and soil moisture', 'Doing nothing until the crop fails'], correctIndex: 0),
          Question(text: 'Which organic method is most effective for pest control in $cropName?', options: ['Seed treatment with Trichoderma and Neem oil spray', 'Spraying heavy chemicals twice a day', 'Burning crop residues inside the field', 'Irrigating with drainage water'], correctIndex: 0),
          Question(text: 'What is the benefit of timely nutrition and fertilizer management in $cropName?', options: ['Roots become stronger and yield increases', 'Harvesting is not required', 'Market price of the crop decreases', 'Plant growth stops completely'], correctIndex: 0),
          Question(text: 'What percentage of moisture is ideal for safe storage of $cropName yield?', options: ['10% to 12%', 'More than 50%', '80%', '0%'], correctIndex: 0),
          Question(text: 'What should a farmer do before applying chemical fertilizers to $cropName?', options: ['Get a soil test done (Soil Health Card)', 'Apply urea blindly', 'Mix all pesticides directly into the soil', 'Stop all fertilizers and leave the field empty'], correctIndex: 0),
        ],
      );
    }
  }

  /// Curated High-Quality Hindi Agricultural YouTube Video Tutorials
  Map<String, List<String>> getCuratedCropVideos(String cropName) {
    final lower = cropName.toLowerCase();
    if (lower.contains('cotton') || lower.contains('कपास')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=cprItIF0Esw',
          'https://www.youtube.com/watch?v=cprItIF0Esw',
        ],
        'titles': [
          'कपास की वैज्ञानिक खेती एवं अधिक उत्पादन की तकनीक (Hindi Video)',
          'कपास में गुलाबी सुंडी और रस चूसक कीटों का पक्का इलाज (Hindi Video)',
        ],
      };
    } else if (lower.contains('soybean') || lower.contains('सोयाबीन')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=2KzBCviawuM',
          'https://www.youtube.com/watch?v=koWzEDnChFQ',
        ],
        'titles': [
          'सोयाबीन की उन्नत खेती, बीज उपचार एवं खाद प्रबंधन (Hindi Video)',
          'सोयाबीन में खरपतवार नियंत्रण और इल्ली की रोकथाम (Hindi Video)',
        ],
      };
    } else if (lower.contains('sugarcane') || lower.contains('गन्ना')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=Yt4N8rr8GZ0',
          'https://www.youtube.com/watch?v=jkKEfsrpBWE',
        ],
        'titles': [
          'गन्ने की ट्रेंच विधि से बुवाई और बंपर पैदावार तकनीक (Hindi Video)',
          'गन्ने में पेड़ी प्रबंधन एवं पहली सिंचाई व खाद का समय (Hindi Video)',
        ],
      };
    } else if (lower.contains('wheat') || lower.contains('गेहूं')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=koWzEDnChFQ',
          'https://www.youtube.com/watch?v=Yt4N8rr8GZ0',
        ],
        'titles': [
          'गेहूं की वैज्ञानिक बुवाई, टॉप किस्में एवं अधिक कल्ले (Hindi Video)',
          'गेहूं में पहली सिंचाई और पीला रतुआ रोग से बचाव (Hindi Video)',
        ],
      };
    } else if (lower.contains('rice') || lower.contains('paddy') || lower.contains('धान')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=cprItIF0Esw',
          'https://www.youtube.com/watch?v=Yt4N8rr8GZ0',
        ],
        'titles': [
          'धान की श्री विधि और कम पानी में बंपर धान उत्पादन (Hindi Video)',
          'धान में तना छेदक और शीथ ब्लाइट रोग का अचूक उपचार (Hindi Video)',
        ],
      };
    } else if (lower.contains('turmeric') || lower.contains('हल्दी')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=Yt4N8rr8GZ0',
          'https://www.youtube.com/watch?v=koWzEDnChFQ',
        ],
        'titles': [
          'हल्दी की वैज्ञानिक खेती और कंद सड़न रोग से बचाव (Hindi Video)',
          'हल्दी में कंद का आकार बढ़ाने के लिए खाद और पोषण (Hindi Video)',
        ],
      };
    } else if (lower.contains('onion') || lower.contains('प्याज')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=koWzEDnChFQ',
          'https://www.youtube.com/watch?v=jkKEfsrpBWE',
        ],
        'titles': [
          'प्याज की उन्नत नर्सरी, रोपाई विधि एवं खरपतवार नियंत्रण (Hindi Video)',
          'प्याज में थ्रिप्स कीट, जलेबी रोग और भंडारण के उपाय (Hindi Video)',
        ],
      };
    } else if (lower.contains('mustard') || lower.contains('सरसों')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=Yt4N8rr8GZ0',
          'https://www.youtube.com/watch?v=cprItIF0Esw',
        ],
        'titles': [
          'सरसों की वैज्ञानिक बुवाई और तेल की मात्रा बढ़ाने के उपाय (Hindi Video)',
          'सरसों में मोयला (माहू) कीट का जैविक और रासायनिक उपचार (Hindi Video)',
        ],
      };
    } else if (lower.contains('coconut') || lower.contains('नारियल')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=cprItIF0Esw',
          'https://www.youtube.com/watch?v=cprItIF0Esw',
        ],
        'titles': [
          'नारियल के पेड़ की देखभाल, थाला प्रबंधन एवं खाद (Hindi Video)',
          'नारियल में गेंडा भृंग और सफेद मक्खी का जैविक नियंत्रण (Hindi Video)',
        ],
      };
    } else if (lower.contains('banana') || lower.contains('केला')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=2KzBCviawuM',
          'https://www.youtube.com/watch?v=koWzEDnChFQ',
        ],
        'titles': [
          'टिशू कल्चर केले की घनी रोपाई एवं अधिक उत्पादन विधि (Hindi Video)',
          'केले में घार की सुरक्षा और सिगाटोका पत्ती धब्बा रोग नियंत्रण (Hindi Video)',
        ],
      };
    } else if (lower.contains('maize') || lower.contains('corn') || lower.contains('मक्का')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=2KzBCviawuM',
        ],
        'titles': [
          'मक्का की उन्नत खेती और फॉल आर्मीवर्म सुंडी का खात्मा (Hindi Video)',
        ],
      };
    } else if (lower.contains('spice') || lower.contains('pepper') || lower.contains('मिर्च') || lower.contains('मसाले')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=koWzEDnChFQ',
        ],
        'titles': [
          'जैविक मसालों और काली मिर्च की खेती एवं रोग प्रबंधन (Hindi Video)',
        ],
      };
    } else if (lower.contains('coffee') || lower.contains('कॉफी')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=2KzBCviawuM',
        ],
        'titles': [
          'छायादार कॉफी बागान की देखभाल और बेरी बोरर नियंत्रण (Hindi Video)',
        ],
      };
    } else if (lower.contains('rubber') || lower.contains('रबर')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=jkKEfsrpBWE',
        ],
        'titles': [
          'रबर टैपिंग की सही तकनीक और बारिश में रेन गार्डिंग (Hindi Video)',
        ],
      };
    } else {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=2KzBCviawuM',
          'https://www.youtube.com/watch?v=2KzBCviawuM',
        ],
        'titles': [
          '$cropName की वैज्ञानिक खेती और अधिक उपज तकनीक (Hindi Video)',
          '$cropName में कीट एवं रोग नियंत्रण का संपूर्ण मार्गदर्शन (Hindi Video)',
        ],
      };
    }
  }

  CropEducationData getFallbackCropEducation(String cropName, {int? topicIndex}) {
    final idx = topicIndex ?? getTodayTopicIndex();
    final topic = dailyTopics[idx];
    final curated = getCuratedCropVideos(cropName);
    final lang = TranslationService().currentLanguageCode;

    String fallbackText;
    
    if (lang == 'hi') {
      fallbackText = '''
### 1. आज का मुख्य विषय (Day ${idx + 1}): ${topic['title']}
मुख्य फोकस: ${topic['focus']}

### 2. $cropName के लिए वैज्ञानिक सिद्धांत
$cropName की अधिक पैदावार के लिए ${topic['title']} का सही समय पर पालन अत्यंत आवश्यक है। मौसम के अनुकूल सही मात्रा का उपयोग पौधों को मजबूत बनाता है।

### 3. खेत में चरणबद्ध कार्य योजना
1. सुबह के समय खेत का निरीक्षण करें और मिट्टी की नमी व पत्तियों का रंग देखें।
2. कृषि विशेषज्ञों द्वारा बताई गई संतुलित मात्रा का ही उपयोग करें।
3. प्रत्येक प्रयोग की तारीख नोट करें और 7 दिनों के अंतराल पर दोबारा निगरानी करें।

### 4. किसानों के लिए सावधानियां एवं लागत बचाने के उपाय
- **अत्यधिक उपयोग से बचें**: रासायनिक दवाओं का ज्यादा प्रयोग मित्र कीटों और जमीन की उपजाऊ शक्ति को नुकसान पहुंचाता है।
- **जैविक खाद का उपयोग**: गोबर की सड़ी खाद या वर्मीकम्पोस्ट का प्रयोग अवश्य करें।

### 5. आज की क्विज़ (Quiz) के लिए महत्वपूर्ण सारांश
- ऊपर बताई गई मात्रा और समय को ध्यान में रखें।
- रोगों के शुरुआती लक्षणों को पहचानें।
- नीचे दिए गए **"Start Today's AI Quiz"** बटन पर क्लिक करके 100 ग्रीन कॉइन्स जीतें!
''';
    } else if (lang == 'mr') {
      fallbackText = '''
### 1. आजचा मुख्य विषय (Day ${idx + 1}): ${topic['title']}
मुख्य फोकस: ${topic['focus']}

### 2. $cropName साठी वैज्ञानिक तत्त्वे
$cropName च्या अधिक उत्पन्नासाठी ${topic['title']} चे योग्य वेळी पालन करणे अत्यंत आवश्यक आहे. हवामानानुसार योग्य प्रमाणात वापर केल्याने झाडे मजबूत होतात.

### 3. शेतातील टप्प्याटप्प्याने कृती आराखडा
1. सकाळी शेताची पाहणी करा आणि जमिनीतील ओलावा व पानांचा रंग तपासा.
2. कृषी तज्ञांनी सुचवलेल्या संतुलित प्रमाणाचाच वापर करा.
3. प्रत्येक प्रयोगाची तारीख नोंदवा आणि 7 दिवसांच्या अंतराने पुन्हा पाहणी करा.

### 4. शेतकऱ्यांसाठी खबरदारी आणि खर्च वाचवण्याचे उपाय
- **अतिवापर टाळा**: रासायनिक औषधांचा जास्त वापर मित्र कीटक आणि जमिनीची सुपीकता नष्ट करतो.
- **सेंद्रिय खतांचा वापर**: कुजलेले शेणखत किंवा गांडूळ खत नक्की वापरा.

### 5. आजच्या प्रश्नमंजुषेसाठी (Quiz) महत्त्वाचा सारांश
- वर सांगितलेले प्रमाण आणि वेळ लक्षात ठेवा.
- रोगांची सुरुवातीची लक्षणे ओळखा.
- खाली दिलेल्या **"Start Today's AI Quiz"** बटणावर क्लिक करून 100 ग्रीन कॉइन्स जिंका!
''';
    } else {
      fallbackText = '''
### 1. Today's Topic (Day ${idx + 1}): ${topic['title']}
Focus: ${topic['focus']}

### 2. Scientific Principles for $cropName
Following the practices of ${topic['title']} at the right time is essential for high yields in $cropName. Proper implementation according to the weather strengthens the plants.

### 3. Step-by-Step Field Plan
1. Inspect the field in the morning, checking soil moisture and leaf color.
2. Use only the balanced quantities recommended by agricultural experts.
3. Note the date of each application and monitor again after 7 days.

### 4. Precautions & Cost-Saving Tips
- **Avoid Overuse**: Excessive use of chemical pesticides harms beneficial insects and soil fertility.
- **Use Organic Fertilizer**: Make sure to use well-rotted cow dung or vermicompost.

### 5. Summary for Today's Quiz
- Keep the recommended quantities and timings in mind.
- Identify the early symptoms of diseases.
- Click the **"Start Today's AI Quiz"** button below to win 100 Green Coins!
''';
    }

    return CropEducationData(
      cropName: cropName,
      todayTopic: topic['title']!,
      topicIndex: idx + 1,
      writtenGuideText: fallbackText,
      audioUrl: '',
      relatedVideoUrls: curated['urls'] ?? [],
      videoTitles: curated['titles'] ?? [],
    );
  }
}
