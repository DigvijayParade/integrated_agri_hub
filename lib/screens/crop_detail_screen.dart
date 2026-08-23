import 'package:flutter/material.dart';
import '../models/crop_education_data.dart';
import '../widgets/text_audio_panel.dart';
import '../widgets/media_panel.dart';
import '../services/ai_service.dart';

class CropDetailScreen extends StatefulWidget {
  final CropEducationData cropData;

  const CropDetailScreen({Key? key, required this.cropData}) : super(key: key);

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  late CropEducationData _currentData;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _currentData = widget.cropData;
    // If current guide is basic, auto-generate in background
    if (_currentData.writtenGuideText.length < 300) {
      _fetchAiGuide();
    }
  }

  void _fetchAiGuide() async {
    setState(() => _isGenerating = true);
    try {
      final aiData = await AiService().generateCropEducation(_currentData.cropName);
      if (mounted) {
        setState(() {
          _currentData = aiData;
        });
      }
    } catch (e) {
      // Fallback data is preserved
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2A5934);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6F0),
        appBar: AppBar(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          title: Text(
            '${_currentData.cropName} Education',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            if (_isGenerating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            else
              IconButton(
                tooltip: 'Regenerate with Gemini AI',
                icon: const Icon(Icons.auto_awesome),
                onPressed: () {
                  _fetchAiGuide();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Generating latest AI guidance for ${_currentData.cropName}...'),
                      backgroundColor: primaryGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFFBBF24),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(icon: Icon(Icons.article), text: 'AI Farming Guide'),
              Tab(icon: Icon(Icons.video_library), text: 'Video Tutorials'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TextAudioPanel(cropData: _currentData),
            MediaPanel(cropData: _currentData),
          ],
        ),
      ),
    );
  }
}
