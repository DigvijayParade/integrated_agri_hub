import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/ai_service.dart';
import '../services/user_service.dart';

class QuizScreen extends StatefulWidget {
  final String cropName;
  final int reward;

  const QuizScreen({super.key, required this.cropName, this.reward = 100});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

enum QuizState { generating, active, summary }

class _QuizScreenState extends State<QuizScreen> {
  QuizState _state = QuizState.generating;
  Quiz? _activeQuiz;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  void _generateQuiz() async {
    try {
      final todayTopic = AiService.getTodayTopic();
      final quiz = await AiService().generateQuizForCrop(
        widget.cropName,
        topic: todayTopic['title'],
        topicIndex: AiService.getTodayTopicIndex(),
      );
      if (quiz != null && mounted) {
        setState(() {
          _activeQuiz = quiz;
          _state = QuizState.active;
        });
      } else if (mounted) {
        setState(() {
          _error = 'Failed to generate quiz. Check your connection.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'AI Generation Error: ${e.toString()}';
        });
      }
    }
  }

  void _submitAnswer() {
    if (_selectedAnswerIndex == null) return;
    
    final isCorrect = _selectedAnswerIndex == _activeQuiz!.questions[_currentQuestionIndex].correctIndex;
    if (isCorrect) _score++;

    if (_currentQuestionIndex < _activeQuiz!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
      });
    } else {
      setState(() {
        _state = QuizState.summary;
      });
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    final scorePercentage = _score / _activeQuiz!.questions.length;
    // Require at least 50% score to earn the reward
    if (scorePercentage >= 0.5) {
      final canEarn = await UserService().canEarnQuizRewardToday();
      if (canEarn && mounted) {
        await UserService().recordQuizCompletion();
        await UserService().addCoins(_activeQuiz!.reward);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Quiz Passed! +${_activeQuiz!.reward} Coins added.'),
              backgroundColor: const Color(0xFF4A7C59),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz Passed! (Daily quiz reward already claimed)'),
            backgroundColor: Color(0xFF4A7C59),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz Failed. Score at least 50% to earn rewards!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A5934),
        foregroundColor: Colors.white,
        title: Text('${widget.cropName} Quiz'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            )
          ],
        ),
      );
    }

    switch (_state) {
      case QuizState.generating: return _buildGenerating();
      case QuizState.active: return _buildActiveQuiz();
      case QuizState.summary: return _buildSummary();
    }
  }

  Widget _buildGenerating() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF4A7C59)),
          const SizedBox(height: 24),
          Text(
            'Generating AI Quiz for ${widget.cropName}...',
            style: const TextStyle(fontSize: 16, color: Color(0xFF2A5934), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Analyzing today\'s lesson...', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildActiveQuiz() {
    final q = _activeQuiz!.questions[_currentQuestionIndex];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${_currentQuestionIndex + 1} of ${_activeQuiz!.questions.length}', style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _activeQuiz!.title, 
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF4A7C59), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _activeQuiz!.questions.length,
              backgroundColor: const Color(0xFFF0F5E8),
              color: const Color(0xFF4A7C59),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),
            Text(q.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2A5934))),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                itemBuilder: (context, i) {
                  final isSelected = _selectedAnswerIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAnswerIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0F5E8) : Colors.white,
                        border: Border.all(color: isSelected ? const Color(0xFF4A7C59) : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? const Color(0xFF4A7C59) : Colors.grey.shade400, width: 2),
                              color: isSelected ? const Color(0xFF4A7C59) : Colors.transparent,
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Text(q.options[i], style: TextStyle(fontSize: 16, color: isSelected ? const Color(0xFF2A5934) : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _selectedAnswerIndex == null ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7C59), disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final maxScore = _activeQuiz!.questions.length;
    final reward = (_score / maxScore) * _activeQuiz!.reward;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(color: Color(0xFFF0F5E8), shape: BoxShape.circle),
                child: const Icon(Icons.emoji_events, size: 80, color: Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 32),
              const Text('Quiz Completed!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2A5934))),
              const SizedBox(height: 16),
              Text('You scored $_score out of $maxScore', style: const TextStyle(fontSize: 18, color: Colors.black87)),
              const SizedBox(height: 24),
              if (reward > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFFD4AF37).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD4AF37))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('\u{1FAA9}', style: TextStyle(fontSize: 24)), const SizedBox(width: 8),
                      Text('+${reward.toInt()} Green Coins Earned!', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB8860B))),
                    ],
                  ),
                ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7C59), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Back to Education', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
