class CropEducationData {
  final String cropName;
  final String writtenGuideText;
  final String audioUrl;
  final List<String> relatedVideoUrls;
  final List<String> videoTitles;

  const CropEducationData({
    required this.cropName,
    required this.writtenGuideText,
    required this.audioUrl,
    required this.relatedVideoUrls,
    this.videoTitles = const [],
  });
}
