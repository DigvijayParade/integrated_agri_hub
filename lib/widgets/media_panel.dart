import 'package:flutter/material.dart';
import '../models/crop_education_data.dart';
import 'youtube_player_widget.dart';

class MediaPanel extends StatelessWidget {
  final CropEducationData cropData;

  const MediaPanel({Key? key, required this.cropData}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (cropData.relatedVideoUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              '${cropData.cropName} के लिए कोई वीडियो उपलब्ध नहीं है।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Hindi Video Guides Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDE8E8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'हिंदी में वीडियो ट्यूटोरियल',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.translate, size: 14, color: Color(0xFF991B1B)),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      'देखकर आसानी से सीखें: कृषि वैज्ञानिकों द्वारा हिंदी में संपूर्ण व्याख्या',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ...List.generate(cropData.relatedVideoUrls.length, (index) {
          final videoUrl = cropData.relatedVideoUrls[index];
          final title = (index < cropData.videoTitles.length &&
                  cropData.videoTitles[index].isNotEmpty)
              ? cropData.videoTitles[index]
              : '${cropData.cropName} की वैज्ञानिक खेती (Hindi Video Guide ${index + 1})';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: YoutubePlayerWidget(
              videoUrl: videoUrl,
              videoTitle: title,
            ),
          );
        }),
      ],
    );
  }
}
