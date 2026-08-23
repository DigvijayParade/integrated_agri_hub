import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/crop_education_data.dart';
import '../models/quiz.dart';
import '../services/ai_service.dart';
import '../services/user_service.dart';

class TextAudioPanel extends StatefulWidget {
  final CropEducationData cropData;

  const TextAudioPanel({Key? key, required this.cropData}) : super(key: key);

  @override
  State<TextAudioPanel> createState() => _TextAudioPanelState();
}

class _TextAudioPanelState extends State<TextAudioPanel> {
  bool _isPlaying = false;
  bool _isGeneratingQuiz = false;

  void _toggleAudio() async {
    final url = widget.cropData.audioUrl;
    if (url.isNotEmpty && url.startsWith('http')) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _openLinkedQuiz(BuildContext context) async {
    setState(() => _isGeneratingQuiz = true);
    try {
      final quiz = await AiService().generateQuizForCrop(
        widget.cropData.cropName,
        topic: widget.cropData.todayTopic,
        topicIndex: widget.cropData.topicIndex - 1,
      );

      if (mounted && quiz != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _DailyTopicQuizModal(quiz: quiz),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingQuiz = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2A5934);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Daily Rotating Topic Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.today, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'DAY ${widget.cropData.topicIndex} LESSON',
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Changes Daily',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.cropData.todayTopic,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Audio Narration Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.audiotrack, color: primaryGreen, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audio Guide Narration',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryGreen),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Listen to spoken farming instructions',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleAudio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Listen'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Header
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 20),
              const SizedBox(width: 8),
              Text(
                'Today\'s Practical Guide (${widget.cropData.cropName})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Render formatted guide sections
          ..._buildFormattedGuideCards(widget.cropData.writtenGuideText),
          const SizedBox(height: 20),

          // Linked Quiz Action Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A5934), Color(0xFF387B44)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withValues(alpha: 0.2),
                  blurRadius: 12,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'AI Topic Quiz',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Text('🪙', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 4),
                          Text(
                            '+100 Coins',
                            style: TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Quiz on: ${widget.cropData.todayTopic}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Test what you learned in today\'s lesson. Pass the 5-question AI quiz to earn Green Coins!',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingQuiz ? null : () => _openLinkedQuiz(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBF24),
                      foregroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isGeneratingQuiz
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E3A8A)),
                          )
                        : const Icon(Icons.play_circle_filled, size: 20),
                    label: Text(
                      _isGeneratingQuiz ? 'Generating AI Quiz...' : 'Start Today\'s AI Quiz',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildFormattedGuideCards(String rawText) {
    const primaryGreen = Color(0xFF2A5934);

    if (rawText.contains('###')) {
      final sections = rawText.split('###').where((s) => s.trim().isNotEmpty).toList();
      return sections.map((section) {
        final lines = section.trim().split('\n');
        final title = lines.first.trim();
        final body = lines.sublist(1).join('\n').trim();
        final icon = _getSectionIcon(title);

        return Card(
          elevation: 1.5,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5E8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: primaryGreen, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList();
    }

    return [
      Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            rawText,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
        ),
      ),
    ];
  }

  IconData _getSectionIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('soil') || lower.contains('climate')) return Icons.terrain_outlined;
    if (lower.contains('sow') || lower.contains('seed') || lower.contains('prep')) return Icons.grass;
    if (lower.contains('irrig') || lower.contains('water')) return Icons.water_drop_outlined;
    if (lower.contains('fertil') || lower.contains('nutrient')) return Icons.science_outlined;
    if (lower.contains('pest') || lower.contains('disease')) return Icons.bug_report_outlined;
    if (lower.contains('harvest') || lower.contains('yield')) return Icons.agriculture;
    return Icons.eco;
  }
}

class _DailyTopicQuizModal extends StatefulWidget {
  final Quiz quiz;

  const _DailyTopicQuizModal({required this.quiz});

  @override
  State<_DailyTopicQuizModal> createState() => _DailyTopicQuizModalState();
}

class _DailyTopicQuizModalState extends State<_DailyTopicQuizModal> {
  int _currentIdx = 0;
  int _score = 0;
  int? _selectedOption;
  bool _submitted = false;

  void _onOptionSelect(int index) {
    if (_submitted) return;
    setState(() {
      _selectedOption = index;
    });
  }

  void _nextOrFinish() async {
    if (_selectedOption == null) return;

    if (_selectedOption == widget.quiz.questions[_currentIdx].correctIndex) {
      _score++;
    }

    if (_currentIdx < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIdx++;
        _selectedOption = null;
      });
    } else {
      // Finished
      final passed = (_score / widget.quiz.questions.length) >= 0.5;
      if (passed) {
        final canEarn = await UserService().canEarnQuizRewardToday();
        if (canEarn) {
          await UserService().recordQuizCompletion();
        }
      }
      setState(() {
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2A5934);

    if (_submitted) {
      final passed = (_score / widget.quiz.questions.length) >= 0.5;
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(passed ? Icons.check_circle : Icons.cancel, color: passed ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(passed ? 'Quiz Passed!' : 'Quiz Completed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Score: $_score / ${widget.quiz.questions.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              passed
                  ? 'Congratulations! You mastered today\'s lesson on ${widget.quiz.targetCrop} and earned +${widget.quiz.reward} Green Coins!'
                  : 'You scored below 50%. Review today\'s lesson notes and try again tomorrow!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Learning', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    final currentQ = widget.quiz.questions[_currentIdx];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIdx + 1}/${widget.quiz.questions.length}',
                  style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              currentQ.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(currentQ.options.length, (optIdx) {
              final isSelected = _selectedOption == optIdx;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryGreen : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    currentQ.options[optIdx],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? primaryGreen : Colors.black87,
                    ),
                  ),
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: isSelected ? primaryGreen : Colors.grey.shade300,
                    child: Text(
                      String.fromCharCode(65 + optIdx),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => _onOptionSelect(optIdx),
                ),
              );
            }),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _selectedOption != null ? _nextOrFinish : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentIdx == widget.quiz.questions.length - 1 ? 'Submit Answers' : 'Next Question',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
