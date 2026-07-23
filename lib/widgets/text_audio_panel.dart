import 'package:flutter/material.dart';
import '../models/crop_education_data.dart';

class TextAudioPanel extends StatefulWidget {
  final CropEducationData cropData;

  const TextAudioPanel({Key? key, required this.cropData}) : super(key: key);

  @override
  State<TextAudioPanel> createState() => _TextAudioPanelState();
}

class _TextAudioPanelState extends State<TextAudioPanel> {
  bool _isPlaying = false;

  void _toggleAudio() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // Placeholder for flutter_tts logic
    // if (_isPlaying) {
    //   flutterTts.speak(widget.cropData.writtenGuideText);
    // } else {
    //   flutterTts.stop();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Audio Toggle Button
          ElevatedButton.icon(
            onPressed: _toggleAudio,
            icon: Icon(_isPlaying ? Icons.stop_circle : Icons.play_circle),
            label: Text(_isPlaying ? 'Stop Listening' : 'Listen to Guide'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _isPlaying 
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: _isPlaying
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Written Guide Content
          Text(
            'Written Guide',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.cropData.writtenGuideText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
