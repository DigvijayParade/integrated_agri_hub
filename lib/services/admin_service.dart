import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crop_education_data.dart';

class MarketPriceItem {
  final String id;
  final String cropName;
  final String mandiName;
  final String district;
  double currentPrice; // per Quintal (in ₹)
  double previousPrice;
  final String unit;
  DateTime lastUpdated;

  MarketPriceItem({
    required this.id,
    required this.cropName,
    required this.mandiName,
    required this.district,
    required this.currentPrice,
    required this.previousPrice,
    this.unit = 'Quintal',
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory MarketPriceItem.fromJson(Map<String, dynamic> json, String docId) {
    return MarketPriceItem(
      id: docId,
      cropName: json['cropName'] ?? '',
      mandiName: json['mandiName'] ?? '',
      district: json['district'] ?? '',
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      previousPrice: (json['previousPrice'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'Quintal',
      lastUpdated: (json['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'mandiName': mandiName,
      'district': district,
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'unit': unit,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  double get changePercentage {
    if (previousPrice == 0) return 0.0;
    return ((currentPrice - previousPrice) / previousPrice) * 100;
  }

  bool get isUp => currentPrice >= previousPrice;
}

class AdminService extends ChangeNotifier {
  // Singleton pattern for global access across app
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal() {
    _initDefaultData();
  }

  final List<MarketPriceItem> _marketPrices = [];
  final Map<String, CropEducationData> _educationDataMap = {};

  List<MarketPriceItem> get marketPrices => List.unmodifiable(_marketPrices);

  CropEducationData? getEducationDataForCrop(String cropName) {
    return _educationDataMap[cropName.toLowerCase()];
  }

  List<CropEducationData> get allEducationData =>
      List.unmodifiable(_educationDataMap.values);

  void _initDefaultData() {
    // Initial Market Prices (Maharashtrian Mandis & major crops)
    _marketPrices.addAll([
      MarketPriceItem(
        id: '1',
        cropName: 'Cotton (Kapas)',
        mandiName: 'Nagpur APMC',
        district: 'Nagpur',
        currentPrice: 7450.0,
        previousPrice: 7200.0,
      ),
      MarketPriceItem(
        id: '2',
        cropName: 'Soybean',
        mandiName: 'Latur APMC',
        district: 'Latur',
        currentPrice: 4820.0,
        previousPrice: 4900.0,
      ),
      MarketPriceItem(
        id: '3',
        cropName: 'Sugarcane',
        mandiName: 'Kolhapur Mandi',
        district: 'Kolhapur',
        currentPrice: 3150.0,
        previousPrice: 3100.0,
      ),
      MarketPriceItem(
        id: '4',
        cropName: 'Wheat',
        mandiName: 'Nashik APMC',
        district: 'Nashik',
        currentPrice: 2680.0,
        previousPrice: 2600.0,
      ),
      MarketPriceItem(
        id: '5',
        cropName: 'Rice (Paddy)',
        mandiName: 'Bhandara Mandi',
        district: 'Bhandara',
        currentPrice: 2340.0,
        previousPrice: 2300.0,
      ),
      MarketPriceItem(
        id: '6',
        cropName: 'Turmeric',
        mandiName: 'Sangli APMC',
        district: 'Sangli',
        currentPrice: 13800.0,
        previousPrice: 13200.0,
      ),
      MarketPriceItem(
        id: '7',
        cropName: 'Onion',
        mandiName: 'Lasalgaon Mandi',
        district: 'Nashik',
        currentPrice: 2150.0,
        previousPrice: 2400.0,
      ),
    ]);

    // Initial Education Data with YouTube links
    final initialEducation = [
      CropEducationData(
        cropName: 'Cotton',
        writtenGuideText:
            'Cotton is a high-value cash crop in Maharashtra.\n\nBest Practices:\n1. Maintain 90x60 cm spacing for Bt-Cotton.\n2. Apply balanced N-P-K (120:60:60 kg/ha).\n3. Monitor for Pink Bollworm using pheromone traps (5 traps/acre).',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        relatedVideoUrls: [
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          'https://www.youtube.com/watch?v=3JZ_D3ELwOQ',
        ],
        videoTitles: [
          'Scientific Cotton Cultivation & Pest Control',
          'Cotton Drip Irrigation & Yield Boosting Tips',
        ],
      ),
      CropEducationData(
        cropName: 'Soybean',
        writtenGuideText:
            'Soybean requires well-drained black cotton soil.\n\nBest Practices:\n1. Seed treatment with Rhizobium and PSB bio-fertilizers.\n2. Maintain seed rate of 30-35 kg/acre.\n3. Weed management within first 30 days is critical.',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        relatedVideoUrls: [
          'https://www.youtube.com/watch?v=L_LUpnjgPso',
        ],
        videoTitles: [
          'Modern Soybean Farming Techniques in Maharashtra',
        ],
      ),
      CropEducationData(
        cropName: 'Sugarcane',
        writtenGuideText:
            'Sugarcane is a long-duration perennial crop.\n\nBest Practices:\n1. Trench planting method increases yield by 25%.\n2. Trash mulching helps conserve soil moisture.\n3. Timely earthing-up prevents lodging during heavy rains.',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        relatedVideoUrls: [
          'https://www.youtube.com/watch?v=V-_O7nl0Ii0',
        ],
        videoTitles: [
          'High Density Sugarcane Farming Masterclass',
        ],
      ),
      CropEducationData(
        cropName: 'Wheat',
        writtenGuideText:
            'Rabi Wheat requires cool climate during growth.\n\nBest Practices:\n1. Sow between Nov 15 - Dec 10.\n2. Critical irrigation stages: Crown Root Initiation & Flowering.\n3. Spray Propiconazole if yellow rust symptoms appear.',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        relatedVideoUrls: [
          'https://www.youtube.com/watch?v=e-ORhEE9VVg',
        ],
        videoTitles: [
          'Wheat Irrigation Scheduling & Disease Defense',
        ],
      ),
    ];

    for (var edu in initialEducation) {
      _educationDataMap[edu.cropName.toLowerCase()] = edu;
    }
  }

  // --- MARKET PRICE ACTIONS ---
  Future<void> updateMarketPrice(String id, double newPrice) async {
    final docRef = FirebaseFirestore.instance.collection('market_prices').doc(id);
    final docSnap = await docRef.get();
    
    if (docSnap.exists) {
      final oldPrice = (docSnap.data()?['currentPrice'] ?? 0).toDouble();
      await docRef.update({
        'currentPrice': newPrice,
        'previousPrice': oldPrice,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<int> importMarketPricesFromCsv(String csvText) async {
    int importedCount = 0;
    final lines = csvText.split('\n');
    
    final collection = FirebaseFirestore.instance.collection('market_prices');
    final batch = FirebaseFirestore.instance.batch();
    
    // Fetch existing docs to handle previousPrice updates
    final existingSnap = await collection.get();
    final existingItems = existingSnap.docs.map((d) => MarketPriceItem.fromJson(d.data(), d.id)).toList();

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#') || trimmed.toLowerCase().contains('crop')) continue;

      final parts = trimmed.split(',');
      if (parts.length >= 4) {
        final crop = parts[0].trim();
        final mandi = parts[1].trim();
        final district = parts[2].trim();
        final price = double.tryParse(parts[3].trim()) ?? 0.0;

        if (crop.isNotEmpty && price > 0) {
          final existing = existingItems.where((p) => 
              p.cropName.toLowerCase() == crop.toLowerCase() &&
              p.mandiName.toLowerCase() == mandi.toLowerCase()).firstOrNull;

          if (existing != null) {
            final docRef = collection.doc(existing.id);
            batch.update(docRef, {
              'currentPrice': price,
              'previousPrice': existing.currentPrice,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          } else {
            final docRef = collection.doc();
            final newItem = MarketPriceItem(
              id: docRef.id,
              cropName: crop,
              mandiName: mandi.isEmpty ? 'Central APMC' : mandi,
              district: district.isEmpty ? 'Maharashtra' : district,
              currentPrice: price,
              previousPrice: price * 0.95,
            );
            batch.set(docRef, newItem.toJson());
          }
          importedCount++;
        }
      }
    }
    
    if (importedCount > 0) {
      await batch.commit();
    }
    return importedCount;
  }

  // --- EDUCATION MEDIA ACTIONS ---
  void saveCropEducationData({
    required String cropName,
    required String writtenGuideText,
    required String audioUrl,
    required List<String> youtubeUrls,
    List<String>? videoTitles,
  }) {
    final key = cropName.trim().toLowerCase();
    _educationDataMap[key] = CropEducationData(
      cropName: cropName.trim(),
      writtenGuideText: writtenGuideText,
      audioUrl: audioUrl.isNotEmpty ? audioUrl : 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      relatedVideoUrls: youtubeUrls,
      videoTitles: videoTitles ?? youtubeUrls.map((url) => '$cropName Educational Video Guide').toList(),
    );
    notifyListeners();
  }
}
