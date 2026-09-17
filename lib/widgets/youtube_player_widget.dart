import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? videoTitle;

  const YoutubePlayerWidget({
    super.key,
    required this.videoUrl,
    this.videoTitle,
  });

  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;
    return RegExp(
            r'^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=|shorts\/))([\w-]{11})')
        .firstMatch(url)
        ?.group(1);
  }

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayerWidget.extractVideoId(widget.videoUrl);

    if (_videoId != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _videoId!,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          enableCaption: true,
          captionLanguage: 'hi',
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_videoId != null) {
      _controller.close();
    }
    super.dispose();
  }

  void _openExternalYoutube() async {
    final uri = Uri.parse(widget.videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null) {
      return _buildFallbackCard('Invalid Video URL');
    }

    final title = widget.videoTitle ?? 'कृषि वैज्ञानिक वीडियो मार्गदर्शन';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top Title Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_fill, color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'YouTube In-App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF94A3B8), size: 18),
                  tooltip: 'Open in YouTube App',
                  onPressed: _openExternalYoutube,
                ),
              ],
            ),
          ),

          // ── Embedded YouTube IFrame Player ──
          YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),

          // ── Interactive Bottom Controls Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFF0F172A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.hd_outlined, color: Color(0xFFFBBF24), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'HD In-App Video Player',
                      style: TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _openExternalYoutube,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.launch, color: Color(0xFF60A5FA), size: 14),
                  label: const Text(
                    'Full App Mode',
                    style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackCard(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.video_library_rounded, size: 40, color: Colors.white54),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
