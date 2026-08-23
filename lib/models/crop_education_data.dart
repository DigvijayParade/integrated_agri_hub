class CropEducationData {
  final String cropName;
  final String todayTopic;
  final int topicIndex;
  final String writtenGuideText;
  final String audioUrl;
  final List<String> relatedVideoUrls;
  final List<String> videoTitles;

  const CropEducationData({
    required this.cropName,
    this.todayTopic = 'Soil Preparation & Seed Treatment',
    this.topicIndex = 1,
    required this.writtenGuideText,
    required this.audioUrl,
    required this.relatedVideoUrls,
    this.videoTitles = const [],
  });
}
