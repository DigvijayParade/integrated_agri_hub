import 'package:flutter/material.dart';
import '../models/crop_education_data.dart';
import '../services/ai_service.dart';
import '../services/translation_service.dart';
import '../screens/crop_detail_screen.dart';

class EducationFeedScreen extends StatefulWidget {
  final List<String> selectedCrops;

  const EducationFeedScreen({Key? key, required this.selectedCrops}) : super(key: key);

  @override
  State<EducationFeedScreen> createState() => _EducationFeedScreenState();
}

class _EducationFeedScreenState extends State<EducationFeedScreen> {
  final AiService _aiService = AiService();
  final Map<String, CropEducationData> _cropDataCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCropsEducation();
  }

  @override
  void didUpdateWidget(covariant EducationFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCrops != oldWidget.selectedCrops) {
      _loadCropsEducation();
    }
  }

  void _loadCropsEducation() async {
    setState(() => _isLoading = true);
    final crops = widget.selectedCrops.isNotEmpty
        ? widget.selectedCrops
        : ['Cotton', 'Soybean', 'Sugarcane', 'Wheat', 'Rice'];

    for (final crop in crops) {
      if (!_cropDataCache.containsKey(crop)) {
        _cropDataCache[crop] = _aiService.getFallbackCropEducation(crop);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2A5934);
    const lightGreen = Color(0xFFE8F5E9);

    final displayCrops = widget.selectedCrops.isNotEmpty
        ? widget.selectedCrops
        : _cropDataCache.keys.toList();

    final todayTopic = AiService.getTodayTopic();
    final todayIdx = AiService.getTodayTopicIndex() + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 22),
            const SizedBox(width: 8),
            Text(
              TranslationService.tr('education'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            )
          : displayCrops.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: lightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.psychology_outlined, size: 52, color: primaryGreen),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No crops registered yet.\nPlease add crops in your Farmer Profile to see AI farming guides & video tutorials.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Daily Rotating Topic Master Banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.today, color: Color(0xFFFBBF24), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TODAY\'S SYLLABUS • DAY $todayIdx',
                                    style: const TextStyle(
                                      color: Color(0xFFFBBF24),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Rotates Tomorrow',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            todayTopic['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            todayTopic['focus']!,
                            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Registered Crops',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        Text(
                          '${displayCrops.length} ${displayCrops.length == 1 ? "Crop" : "Crops"} Active',
                          style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ...displayCrops.map((crop) {
                      final cropData = _cropDataCache[crop] ?? _aiService.getFallbackCropEducation(crop);
                      return _buildCropEduCard(context, cropData, todayTopic['title']!, todayIdx);
                    }),
                  ],
                ),
    );
  }

  Widget _buildCropEduCard(BuildContext context, CropEducationData cropData, String todayTopicTitle, int todayIdx) {
    const primaryGreen = Color(0xFF2A5934);
    const lightGreen = Color(0xFFF0F5E8);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CropDetailScreen(cropData: cropData),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.eco, color: primaryGreen, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              cropData.cropName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF93C5FD)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, size: 10, color: Color(0xFF1E3A8A)),
                                  SizedBox(width: 4),
                                  Text(
                                    'AI Verified',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Day $todayIdx: $todayTopicTitle',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _badge(Icons.article_outlined, 'Today\'s Guide', const Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  _badge(Icons.video_library_outlined, 'YouTube Video', const Color(0xFFC62828)),
                  const SizedBox(width: 8),
                  _badge(Icons.emoji_events_outlined, 'Daily Quiz +100', const Color(0xFFD97706)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
