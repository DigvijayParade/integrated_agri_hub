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
              'No educational videos uploaded yet for ${cropData.cropName}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Government Admin officers publish new video tutorials regularly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: cropData.relatedVideoUrls.length,
      itemBuilder: (context, index) {
        final videoUrl = cropData.relatedVideoUrls[index];
        final title = (index < cropData.videoTitles.length &&
                cropData.videoTitles[index].isNotEmpty)
            ? cropData.videoTitles[index]
            : '${cropData.cropName} Educational Video Guide ${index + 1}';

        return YoutubePlayerWidget(
          videoUrl: videoUrl,
          videoTitle: title,
        );
      },
    );
  }
}
