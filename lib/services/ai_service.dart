import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:integrated_agri_hub/models/quiz.dart';
import 'package:integrated_agri_hub/models/crop_education_data.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  GenerativeModel? _visionModel;
  GenerativeModel? _textModel;

  /// Daily Rotating Syllabus Topics in Hindi & English (7-Day Cycle)
  static const List<Map<String, String>> dailyTopics = [
    {
      'title': 'मिट्टी की तैयारी और प्रमाणित बीज बुवाई (Soil Prep & Sowing)',
      'focus': 'खेत की गहरी जुताई, गोबर की खाद, ट्राइकोडर्मा से बीज उपचार और उचित दूरी पर बुवाई।',
    },
    {
      'title': 'संतुलित उर्वरक और पोषण प्रबंधन (NPK & Organic Fertilizer)',
      'focus': 'बेसल डोज, यूरिया टॉप-ड्रेसिंग, वर्मीकम्पोस्ट और जिंक/बोरॉन सूक्ष्म पोषक तत्व स्प्रे।',
    },
    {
      'title': 'स्मार्ट सिंचाई और ड्रिप प्रबंधन (Irrigation & Water Management)',
      'focus': 'फसल की मुख्य अवस्थाओं में सिंचाई, टपक सिंचाई (ड्रिप) और जलभराव से बचाव।',
    },
    {
      'title': 'एकीकृत कीट प्रबंधन - IPM (Pest & Insect Control)',
      'focus': 'गुलाबी सुंडी/माहू की पहचान, फेरोमोन ट्रैप, 10,000 ppm नीम का तेल और जैविक कीटनाशक।',
    },
    {
      'title': 'फफूंद और जीवाणु रोग रोकथाम (Disease Management)',
      'focus': 'जड़ गलन, उकठा रोग, झुलसा रोग से बचाव, कॉपर ऑक्सीक्लोराइड और जैविक उपचार।',
    },
    {
      'title': 'खरपतवार नियंत्रण और निराई-गुड़ाई (Weed Management)',
      'focus': 'बुवाई के तुरंत बाद एवं खड़ी फसल में खरपतवारनाशी, मल्चिंग और हाथ से निराई।',
    },
    {
      'title': 'कटाई, भंडारण और मंडी में सही दाम (Harvest & APMC Sales)',
      'focus': 'फसल पकने की सही पहचान, 10-12% नमी पर सुरक्षित भंडारण और APMC मंडी में सही मूल्य।',
    },
  ];

  static int getTodayTopicIndex([DateTime? date]) {
    final now = date ?? DateTime.now();
    final days = now.difference(DateTime(2026, 1, 1)).inDays;
    return (days % dailyTopics.length).abs();
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

  /// Verifies if the provided image matches the task description.
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

  /// Generates a comprehensive AI farming guide in Hindi for today's rotating topic
  Future<CropEducationData> generateCropEducation(String cropName, {int? topicIndex}) async {
    final idx = topicIndex ?? getTodayTopicIndex();
    final topic = dailyTopics[idx];
    final curatedVideos = getCuratedCropVideos(cropName);

    try {
      _initModels();
      final prompt = '''
आप भारत के एक वरिष्ठ कृषि वैज्ञानिक हैं।
भारतीय किसानों के लिए "$cropName" की फसल हेतु आज का दैनिक कृषि मार्गदर्शन (Hindi में) तैयार करें।

आज का विषय (Day ${idx + 1}): "${topic['title']}".
मुख्य बिंदु: "${topic['focus']}".

कृपया स्पष्ट और सरल हिंदी (Devanagari script) में निम्नलिखित शीर्षकों के साथ पूरा व्यावहारिक मार्गदर्शन लिखें:
### 1. आज का मुख्य उद्देश्य एवं वैज्ञानिक लाभ
### 2. खेत में चरणबद्ध कार्य योजना ($cropName के लिए)
### 3. खाद, दवा की सही मात्रा एवं छिड़काव का समय
### 4. किसानों के लिए विशेष सावधानियां एवं लागत बचाने के उपाय
### 5. आज की क्विज़ (Quiz) के लिए महत्वपूर्ण सारांश

किसानों के समझने लायक बहुत ही सरल और स्पष्ट भाषा का प्रयोग करें।
केवल टेक्स्ट गाइड ही रिटर्न करें।
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

  /// Generates a quiz in Hindi specifically testing the farmer on today's education topic for that crop
  Future<Quiz?> generateQuizForCrop(String cropName, {String? topic, int? topicIndex}) async {
    final idx = topicIndex ?? getTodayTopicIndex();
    final currentTopic = topic ?? dailyTopics[idx]['title']!;

    try {
      _initModels();
      
      final prompt = '''
आप एक विशेषज्ञ कृषि परीक्षक हैं।
किसान को "$cropName" के आज के पाठ "$currentTopic" पर आधारित 5 बहुविकल्पीय प्रश्न (MCQ Quiz in Hindi) बनाएं।
पाठ का मुख्य फोकस: "${dailyTopics[idx]['focus']}".

प्रश्न आज सीखे गए पाठ (दवा की मात्रा, रोग के लक्षण, सही समय और वैज्ञानिक विधि) से संबंधित होने चाहिए।
केवल वैध JSON रिटर्न करें:
{
  "title": "$cropName दैनिक क्विज़: $currentTopic",
  "topic": "$currentTopic",
  "targetCrop": "$cropName",
  "difficulty": "Medium",
  "reward": 100,
  "estimatedTime": "3 Mins",
  "questions": [
    {
      "text": "हिंदी में प्रश्न जो $currentTopic से संबंधित हो?",
      "options": ["सही उत्तर A", "गलत उत्तर B", "गलत उत्तर C", "गलत उत्तर D"],
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
      return Quiz.fromJson(jsonMap);
    } catch (e) {
      if (kDebugMode) print('Gemini AI Quiz Gen Error: $e');
      return _getFallbackQuiz(cropName, currentTopic);
    }
  }

  Quiz _getFallbackQuiz(String cropName, String topic) {
    return Quiz(
      title: '$cropName दैनिक क्विज़: $topic',
      topic: topic,
      targetCrop: cropName,
      difficulty: 'Medium',
      reward: 100,
      estimatedTime: '3 Mins',
      questions: [
        Question(
          text: '$cropName की फसल में $topic के लिए सबसे उत्तम वैज्ञानिक विधि क्या है?',
          options: [
            'कृषि विश्वविद्यालय द्वारा अनुशंसित सही मात्रा एवं समय पर प्रयोग करना',
            'बिना नापे अत्यधिक मात्रा में रासायनिक दवाओं का छिड़काव करना',
            'मौसम और खेत की नमी का बिल्कुल ध्यान न देना',
            'फसल खराब होने तक किसी भी उपाय को न करना',
          ],
          correctIndex: 0,
        ),
        Question(
          text: '$cropName में फफूंद एवं कीट नियंत्रण हेतु कौन सा जैविक उपाय सबसे प्रभावी है?',
          options: [
            'ट्राइकोडर्मा से बीज उपचार और 10,000 ppm नीम का तेल स्प्रे',
            'दिन में दो बार भारी मात्रा में रासायनिक कीटनाशक छिड़कना',
            'खेत के अंदर फसल अवशेषों को जलाना',
            'गंदे नाले के पानी से फसल की सिंचाई करना',
          ],
          correctIndex: 0,
        ),
        Question(
          text: '$cropName में समय पर पोषण एवं खाद प्रबंधन से क्या लाभ होता है?',
          options: [
            'पौधों की जड़ें मजबूत होती हैं और बंपर पैदावार मिलती है',
            'फसल की कटाई की बिल्कुल जरूरत नहीं पड़ती',
            'फसल की बाजार कीमत घट जाती है',
            'पौधों का विकास पूरी तरह रुक जाता है',
          ],
          correctIndex: 0,
        ),
        Question(
          text: '$cropName की उपज को कटाई के बाद सुरक्षित रखने के लिए कितने प्रतिशत नमी होनी चाहिए?',
          options: [
            '10% से 12% से कम नमी पर सुखाकर बोरियों में रखना',
            '50% से अधिक गीले स्थान पर खुला छोड़ना',
            'धूप और हवा के बिना कीचड़ में दबाकर रखना',
            '80 डिग्री से अधिक तापमान पर सीधे उबालना',
          ],
          correctIndex: 0,
        ),
        Question(
          text: '$cropName में रासायनिक उर्वरक देने से पहले किसान को क्या करना चाहिए?',
          options: [
            'मृदा स्वास्थ्य कार्ड (Soil Health Card) से मिट्टी की जांच कराना',
            'बिना जांच केवल अंधाधुंध यूरिया डालना',
            'सभी प्रकार की कीटनाशकों को मिट्टी में सीधे मिलाना',
            'उर्वरक का उपयोग पूरी तरह बंद करके खेत खाली छोड़ना',
          ],
          correctIndex: 0,
        ),
      ],
    );
  }

  /// Curated High-Quality Hindi Agricultural YouTube Video Tutorials
  Map<String, List<String>> getCuratedCropVideos(String cropName) {
    final lower = cropName.toLowerCase();
    if (lower.contains('cotton') || lower.contains('कपास')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=0hW2P7f7nCo',
          'https://www.youtube.com/watch?v=kYJqD9P_iYg',
        ],
        'titles': [
          'कपास की वैज्ञानिक खेती एवं अधिक उत्पादन की तकनीक (Hindi Video)',
          'कपास में गुलाबी सुंडी और रस चूसक कीटों का पक्का इलाज (Hindi Video)',
        ],
      };
    } else if (lower.contains('soybean') || lower.contains('सोयाबीन')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=Fj7P52aN8u4',
          'https://www.youtube.com/watch?v=tgbNymZ7vqY',
        ],
        'titles': [
          'सोयाबीन की उन्नत खेती, बीज उपचार एवं खाद प्रबंधन (Hindi Video)',
          'सोयाबीन में खरपतवार नियंत्रण और इल्ली की रोकथाम (Hindi Video)',
        ],
      };
    } else if (lower.contains('sugarcane') || lower.contains('गन्ना')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=9_H8NfE3D5w',
          'https://www.youtube.com/watch?v=2nL5K8m9R3w',
        ],
        'titles': [
          'गन्ने की ट्रेंच विधि से बुवाई और बंपर पैदावार तकनीक (Hindi Video)',
          'गन्ने में पेड़ी प्रबंधन एवं पहली सिंचाई व खाद का समय (Hindi Video)',
        ],
      };
    } else if (lower.contains('wheat') || lower.contains('गेहूं')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=1D3a9g3F2rA',
          'https://www.youtube.com/watch?v=3S1eJj3_3rE',
        ],
        'titles': [
          'गेहूं की वैज्ञानिक बुवाई, टॉप किस्में एवं अधिक कल्ले (Hindi Video)',
          'गेहूं में पहली सिंचाई और पीला रतुआ रोग से बचाव (Hindi Video)',
        ],
      };
    } else if (lower.contains('rice') || lower.contains('paddy') || lower.contains('धान')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=3S1eJj3_3rE',
          'https://www.youtube.com/watch?v=4dK5J9y8NqQ',
        ],
        'titles': [
          'धान की श्री विधि और कम पानी में बंपर धान उत्पादन (Hindi Video)',
          'धान में तना छेदक और शीथ ब्लाइट रोग का अचूक उपचार (Hindi Video)',
        ],
      };
    } else if (lower.contains('turmeric') || lower.contains('हल्दी')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=5rT8E9j1K7w',
          'https://www.youtube.com/watch?v=7uJ3K8m5R2e',
        ],
        'titles': [
          'हल्दी की वैज्ञानिक खेती और कंद सड़न रोग से बचाव (Hindi Video)',
          'हल्दी में कंद का आकार बढ़ाने के लिए खाद और पोषण (Hindi Video)',
        ],
      };
    } else if (lower.contains('onion') || lower.contains('प्याज')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=7uJ3K8m5R2e',
          'https://www.youtube.com/watch?v=8mK2L9j7W4q',
        ],
        'titles': [
          'प्याज की उन्नत नर्सरी, रोपाई विधि एवं खरपतवार नियंत्रण (Hindi Video)',
          'प्याज में थ्रिप्स कीट, जलेबी रोग और भंडारण के उपाय (Hindi Video)',
        ],
      };
    } else if (lower.contains('mustard') || lower.contains('सरसों')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=8mK2L9j7W4q',
          'https://www.youtube.com/watch?v=9nL3K8m2R5w',
        ],
        'titles': [
          'सरसों की वैज्ञानिक बुवाई और तेल की मात्रा बढ़ाने के उपाय (Hindi Video)',
          'सरसों में मोयला (माहू) कीट का जैविक और रासायनिक उपचार (Hindi Video)',
        ],
      };
    } else if (lower.contains('coconut') || lower.contains('नारियल')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=9nL3K8m2R5w',
          'https://www.youtube.com/watch?v=6mK9L3j2R7w',
        ],
        'titles': [
          'नारियल के पेड़ की देखभाल, थाला प्रबंधन एवं खाद (Hindi Video)',
          'नारियल में गेंडा भृंग और सफेद मक्खी का जैविक नियंत्रण (Hindi Video)',
        ],
      };
    } else if (lower.contains('banana') || lower.contains('केला')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=2nL5K8m9R3w',
          'https://www.youtube.com/watch?v=1mK4L8j9R2w',
        ],
        'titles': [
          'टिशू कल्चर केले की घनी रोपाई एवं अधिक उत्पादन विधि (Hindi Video)',
          'केले में घार की सुरक्षा और सिगाटोका पत्ती धब्बा रोग नियंत्रण (Hindi Video)',
        ],
      };
    } else if (lower.contains('maize') || lower.contains('corn') || lower.contains('मक्का')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=4dK5J9y8NqQ',
        ],
        'titles': [
          'मक्का की उन्नत खेती और फॉल आर्मीवर्म सुंडी का खात्मा (Hindi Video)',
        ],
      };
    } else if (lower.contains('spice') || lower.contains('pepper') || lower.contains('मिर्च') || lower.contains('मसाले')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=6mK9L3j2R7w',
        ],
        'titles': [
          'जैविक मसालों और काली मिर्च की खेती एवं रोग प्रबंधन (Hindi Video)',
        ],
      };
    } else if (lower.contains('coffee') || lower.contains('कॉफी')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=1mK4L8j9R2w',
        ],
        'titles': [
          'छायादार कॉफी बागान की देखभाल और बेरी बोरर नियंत्रण (Hindi Video)',
        ],
      };
    } else if (lower.contains('rubber') || lower.contains('रबर')) {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=3mK8L2j7R5w',
        ],
        'titles': [
          'रबर टैपिंग की सही तकनीक और बारिश में रेन गार्डिंग (Hindi Video)',
        ],
      };
    } else {
      return {
        'urls': [
          'https://www.youtube.com/watch?v=0hW2P7f7nCo',
          'https://www.youtube.com/watch?v=Fj7P52aN8u4',
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

    return CropEducationData(
      cropName: cropName,
      todayTopic: topic['title']!,
      topicIndex: idx + 1,
      writtenGuideText: '''
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
- **सुरक्षा**: कीटनाशक का छिड़काव करते समय दस्ताने और मास्क का प्रयोग करें।

### 5. आज की क्विज़ (Quiz) के लिए महत्वपूर्ण सारांश
- ऊपर बताई गई मात्रा और समय को ध्यान में रखें।
- रोगों के शुरुआती लक्षणों को पहचानें।
- नीचे दिए गए **"Start Today's AI Quiz"** बटन पर क्लिक करके 100 ग्रीन कॉइन्स जीतें!
''',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      relatedVideoUrls: curated['urls'] ?? [],
      videoTitles: curated['titles'] ?? [],
    );
  }
}
