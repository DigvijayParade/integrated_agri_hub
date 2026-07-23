import 'package:flutter/material.dart';
import '../models/crop_education_data.dart';

class MediaPanel extends StatelessWidget {
  final CropEducationData cropData;

  const MediaPanel({Key? key, required this.cropData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cropData.relatedVideoUrls.isEmpty) {
      return Center(
        child: Text(
          'No videos available for ${cropData.cropName}.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: cropData.relatedVideoUrls.length,
      itemBuilder: (context, index) {
        // final videoUrl = cropData.relatedVideoUrls[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Video Thumbnail Placeholder
              Container(
                height: 180,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '${cropData.cropName} Video Guide ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
