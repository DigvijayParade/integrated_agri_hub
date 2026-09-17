class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  
  Question({required this.text, required this.options, required this.correctIndex});

  factory Question.fromJson(Map<String, dynamic> json) {
    final rawOptions = List<String>.from(json['options'] ?? []);
    final rawCorrectIndex = json['correctIndex'] ?? 0;
    
    // Shuffle options while keeping track of the correct answer
    String correctText = '';
    if (rawOptions.isNotEmpty && rawCorrectIndex >= 0 && rawCorrectIndex < rawOptions.length) {
      correctText = rawOptions[rawCorrectIndex];
    }
    
    final shuffledOptions = List<String>.from(rawOptions)..shuffle();
    final newCorrectIndex = shuffledOptions.indexOf(correctText);
    
    return Question(
      text: json['text'] ?? '',
      options: shuffledOptions,
      correctIndex: newCorrectIndex != -1 ? newCorrectIndex : 0,
    );
  }
}

class Quiz {
  final String title;
  final String topic;
  final String targetCrop;
  final String difficulty;
  final int reward;
  final List<Question> questions;
  final String estimatedTime;
  
  Quiz({
    required this.title,
    required this.topic,
    required this.targetCrop,
    required this.difficulty,
    required this.reward,
    required this.questions,
    required this.estimatedTime,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      title: json['title'] ?? 'Daily Quiz',
      topic: json['topic'] ?? 'Agriculture',
      targetCrop: json['targetCrop'] ?? 'Any',
      difficulty: json['difficulty'] ?? 'Medium',
      reward: json['reward'] ?? 100,
      estimatedTime: json['estimatedTime'] ?? '2 Mins',
      questions: (json['questions'] as List? ?? [])
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
