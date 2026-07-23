import 'package:flutter/material.dart';
import '../models/crop_education_data.dart';
import '../widgets/crop_card.dart';

class EducationFeedScreen extends StatefulWidget {
  final List<String> selectedCrops;

  const EducationFeedScreen({Key? key, required this.selectedCrops}) : super(key: key);

  @override
  State<EducationFeedScreen> createState() => _EducationFeedScreenState();
}

class _EducationFeedScreenState extends State<EducationFeedScreen> {
  // Mock Database of all available crop education data
  final List<CropEducationData> _allEducationData = [
    const CropEducationData(
      cropName: 'Cotton',
      writtenGuideText: 'Cotton is a soft, fluffy staple fiber that grows in a boll, or protective case, around the seeds of the cotton plants of the genus Gossypium.\n\nBest Practices:\n1. Ensure well-drained soil.\n2. Maintain proper row spacing.\n3. Monitor for bollworms regularly.',
      audioUrl: 'mock_audio_cotton.mp3',
      relatedVideoUrls: ['vid1_cotton.mp4', 'vid2_cotton.mp4'],
    ),
    const CropEducationData(
      cropName: 'Soybean',
      writtenGuideText: 'The soybean, or soya bean, is a species of legume native to East Asia, widely grown for its edible bean, which has numerous uses.\n\nBest Practices:\n1. Inoculate seeds before planting.\n2. Manage weed competition early.\n3. Harvest at the right moisture level.',
      audioUrl: 'mock_audio_soybean.mp3',
      relatedVideoUrls: ['vid1_soybean.mp4'],
    ),
    const CropEducationData(
      cropName: 'Sugarcane',
      writtenGuideText: 'Sugarcane is a tall, perennial grass native to warm temperate to tropical regions of South Asia and Melanesia, used for sugar and ethanol production.\n\nBest Practices:\n1. Prepare deep soil tillage.\n2. Maintain optimal soil moisture during growth stages.\n3. Apply balanced N-P-K fertilizer.',
      audioUrl: 'mock_audio_sugarcane.mp3',
      relatedVideoUrls: ['vid1_sugarcane.mp4', 'vid2_sugarcane.mp4'],
    ),
    const CropEducationData(
      cropName: 'Wheat',
      writtenGuideText: 'Wheat is a grass widely cultivated for its seed, a cereal grain which is a worldwide staple food.\n\nBest Practices:\n1. Prepare a firm seedbed.\n2. Apply nitrogen fertilizer optimally.\n3. Watch out for rust diseases.',
      audioUrl: 'mock_audio_wheat.mp3',
      relatedVideoUrls: ['vid1_wheat.mp4', 'vid2_wheat.mp4', 'vid3_wheat.mp4'],
    ),
    const CropEducationData(
      cropName: 'Rice',
      writtenGuideText: 'Rice is the seed of the grass species Oryza sativa. As a cereal grain, it is the most widely consumed staple food for a large part of the world\'s human population.\n\nBest Practices:\n1. Maintain standing water in fields initially.\n2. Control weeds early via flooding.\n3. Harvest when grains turn golden-yellow.',
      audioUrl: 'mock_audio_rice.mp3',
      relatedVideoUrls: ['vid1_rice.mp4'],
    ),
    const CropEducationData(
      cropName: 'Maize',
      writtenGuideText: 'Maize, also known as corn, is a cereal grain first domesticated by indigenous peoples in southern Mexico about 10,000 years ago.\n\nBest Practices:\n1. Plant in warm, well-aerated soil.\n2. Manage nitrogen levels during early stages.\n3. Ensure adequate water during pollination.',
      audioUrl: 'mock_audio_maize.mp3',
      relatedVideoUrls: ['vid1_maize.mp4'],
    ),
    const CropEducationData(
      cropName: 'Mustard',
      writtenGuideText: 'Mustard is a cool-season crop grown for its oilseeds. The seeds are also used as spices.\n\nBest Practices:\n1. Sow during early winter.\n2. Keep spacing of 30cm between rows.\n3. Irrigate at flowering and pod filling stages.',
      audioUrl: 'mock_audio_mustard.mp3',
      relatedVideoUrls: ['vid1_mustard.mp4'],
    ),
    const CropEducationData(
      cropName: 'Coconut',
      writtenGuideText: 'The coconut tree is a member of the palm tree family and the only living species of the genus Cocos. The term coconut can refer to the whole coconut palm, the seed, or the fruit.\n\nBest Practices:\n1. Plant in sandy loam soil.\n2. Ensure proper spacing of 7.5 meters.\n3. Apply organic manure regularly.',
      audioUrl: 'mock_audio_coconut.mp3',
      relatedVideoUrls: ['vid1_coconut.mp4'],
    ),
    const CropEducationData(
      cropName: 'Spices',
      writtenGuideText: 'Kerala is famous for spices like Black Pepper, Cardamom, and Ginger, which thrive in humid, tropical environments.\n\nBest Practices:\n1. Use organic mulch for moisture retention.\n2. Provide partial shade for young plants.\n3. Prune regularly for pepper vines.',
      audioUrl: 'mock_audio_spices.mp3',
      relatedVideoUrls: ['vid1_spices.mp4'],
    ),
    const CropEducationData(
      cropName: 'Rubber',
      writtenGuideText: 'Rubber trees require deep, well-drained acidic soil and a warm, humid climate for high latex yield.\n\nBest Practices:\n1. Start tapping only when trees reach 50cm girth.\n2. Apply rain-guarding during monsoons.\n3. Use recommended yield stimulants safely.',
      audioUrl: 'mock_audio_rubber.mp3',
      relatedVideoUrls: ['vid1_rubber.mp4'],
    ),
    const CropEducationData(
      cropName: 'Coffee',
      writtenGuideText: 'Coffee is cultivated in hilly regions with moderate temperatures and heavy rainfall. Robusta and Arabica are the main types.\n\nBest Practices:\n1. Plant shade trees to protect coffee plants.\n2. Pick only ripe red cherries.\n3. Manage leaf rust disease immediately.',
      audioUrl: 'mock_audio_coffee.mp3',
      relatedVideoUrls: ['vid1_coffee.mp4'],
    ),
    const CropEducationData(
      cropName: 'Tapioca',
      writtenGuideText: 'Tapioca is a root crop high in starch, widely grown in Kerala. It is drought-tolerant and easy to cultivate.\n\nBest Practices:\n1. Use healthy stem cuttings for planting.\n2. Harvest at 8 to 10 months.\n3. Ensure good soil drainage to prevent root rot.',
      audioUrl: 'mock_audio_tapioca.mp3',
      relatedVideoUrls: ['vid1_tapioca.mp4'],
    ),
    const CropEducationData(
      cropName: 'Arecanut',
      writtenGuideText: 'Arecanut is an important commercial palm crop, requiring abundant water and well-drained soil.\n\nBest Practices:\n1. Provide proper drainage channels.\n2. Apply micronutrient mixtures to prevent yellow leaf disease.\n3. Shading is necessary in the early years.',
      audioUrl: 'mock_audio_arecanut.mp3',
      relatedVideoUrls: ['vid1_arecanut.mp4'],
    ),
    const CropEducationData(
      cropName: 'Banana',
      writtenGuideText: 'Bananas require a rich soil, constant moisture, and protection from strong winds.\n\nBest Practices:\n1. Dig spacious planting pits.\n2. Provide windbreaks or staking support.\n3. Manage banana bunchy top virus.',
      audioUrl: 'mock_audio_banana.mp3',
      relatedVideoUrls: ['vid1_banana.mp4'],
    ),
    const CropEducationData(
      cropName: 'Barley',
      writtenGuideText: 'Barley is a major cereal grain, commonly used in bread, beverages, and animal feed. It is more salt-tolerant than wheat.\n\nBest Practices:\n1. Plant in well-drained loamy soils.\n2. Control weeds early via physical or chemical means.\n3. Harvest at low moisture content.',
      audioUrl: 'mock_audio_barley.mp3',
      relatedVideoUrls: ['vid1_barley.mp4'],
    ),
    const CropEducationData(
      cropName: 'Sunflower',
      writtenGuideText: 'Sunflowers are grown for their seeds which yield high-quality edible oil. They require bright sunlight.\n\nBest Practices:\n1. Ensure adequate spacing for large heads.\n2. Irrigate during the critical seed development phase.\n3. Protect seeds from bird damage.',
      audioUrl: 'mock_audio_sunflower.mp3',
      relatedVideoUrls: ['vid1_sunflower.mp4'],
    ),
  ];

  late List<CropEducationData> _filteredData;

  @override
  void initState() {
    super.initState();
    _filterData();
  }

  @override
  void didUpdateWidget(covariant EducationFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCrops != oldWidget.selectedCrops) {
      _filterData();
    }
  }

  void _filterData() {
    setState(() {
      _filteredData = _allEducationData
          .where((data) => widget.selectedCrops.contains(data.cropName))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Education Hub'),
      ),
      body: _filteredData.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No education modules available for your selected crops.\nPlease update your crop selection.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                return CropCard(cropData: _filteredData[index]);
              },
            ),
    );
  }
}
