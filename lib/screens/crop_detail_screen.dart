import 'package:flutter/material.dart';
import '../models/crop_education_data.dart';
import '../widgets/text_audio_panel.dart';
import '../widgets/media_panel.dart';

class CropDetailScreen extends StatelessWidget {
  final CropEducationData cropData;

  const CropDetailScreen({Key? key, required this.cropData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${cropData.cropName} Education'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.article), text: 'Text & Audio'),
              Tab(icon: Icon(Icons.video_library), text: 'Media'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TextAudioPanel(cropData: cropData),
            MediaPanel(cropData: cropData),
          ],
        ),
      ),
    );
  }
}
