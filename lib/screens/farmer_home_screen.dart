import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrated_agri_hub/screens/welcome_screen.dart';
import 'dart:async';
import 'package:integrated_agri_hub/models/app_notification.dart';
import 'package:integrated_agri_hub/screens/notifications_screen.dart';
import 'package:integrated_agri_hub/screens/qr_scanner_screen.dart';
import 'package:integrated_agri_hub/screens/education_feed_screen.dart';
import 'package:integrated_agri_hub/services/user_service.dart';
import 'package:integrated_agri_hub/services/admin_service.dart';
import 'package:integrated_agri_hub/services/ai_service.dart';
import 'package:image_picker/image_picker.dart';

const _kGreen = Color(0xFF4A7C59);
const _kDarkGreen = Color(0xFF2A5934);
const _kCream = Color(0xFFF9F6F0);
const _kLightGreen = Color(0xFFF0F5E8);

// === ROOT SHELL ===
class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});
  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _currentIndex = 0;
  
  final _userService = UserService();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userStreamSub;

  int _greenCoins = 0;
  int _streak = 0;
  int _quizzesCompleted = 0;
  List<String> _completedTasks = [];
  List<AppNotification> _notifications = [];
  final List<Map<String, dynamic>> _transactions = [];

  List<String> _registeredCrops = [];
  String _farmerName = 'Loading...';
  String _farmerEmail = '';
  String _farmerState = '';
  final List<Quiz> _archivedQuizzes = [];


  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _subscribeToUserStream();
    _grantDailyLoginBonus();
  }

  void _subscribeToUserStream() {
    final stream = _userService.userStream();
    if (stream == null) return;
    _userStreamSub = stream.listen((snapshot) {
      if (!mounted || !snapshot.exists) return;
      final data = snapshot.data()!;
      setState(() {
        _farmerName = data['fullName'] ?? 'Farmer';
        _farmerEmail = data['email'] ?? '';
        _farmerState = data['state'] ?? '';
        _greenCoins = data['greenCoins'] as int? ?? 0;
        _streak = data['streak'] as int? ?? 0;
        _quizzesCompleted = data['quizzesCompleted'] as int? ?? 0;
        if (data['selectedCrops'] != null) {
          _registeredCrops = List<String>.from(data['selectedCrops']);
        }
        if (data['completedTasks'] != null) {
          _completedTasks = List<String>.from(data['completedTasks']);
        }
      });
    });
  }

  void _grantDailyLoginBonus() async {
    final granted = await _userService.checkAndGrantDailyLoginBonus();
    if (granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🌿 Daily login bonus: +10 Green Coins!'),
          backgroundColor: Color(0xFF4A7C59),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _userStreamSub?.cancel();
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _addCoins(int amount, String reason) async {
    // Save to Firestore (stream will update UI automatically)
    await _userService.addCoins(amount);
    _logTransaction(amount, reason);
  }

  void _logTransaction(int amount, String reason) {
    if (mounted) {
      final now = DateTime.now();
      final dt = '${now.day} ${_monthName(now.month)} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      setState(() {
        _transactions.insert(0, {
          'name': reason,
          'dt': dt,
          'id': '#${90000 + _transactions.length}',
          'amount': '+$amount',
          'credit': true,
        });
      });
    }
  }

  String _monthName(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0: return _DashboardView(
          greenCoins: _greenCoins,
          streak: _streak,
          farmerName: _farmerName,
          registeredCrops: _registeredCrops,
          completedTasks: _completedTasks,
          onShowProfile: () => _showProfileModal(context, _greenCoins, _transactions, _registeredCrops, (c) => setState(() => _registeredCrops = c)),
          onAddCoins: _addCoins,
          onLogTransaction: _logTransaction,
          completedQuizzesCount: _quizzesCompleted,
          notifications: _notifications,
          onOpenNotifications: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsScreen(
                  notifications: _notifications,
                  onNotificationsRead: () {
                    setState(() {});
                  },
                ),
              ),
            );
          },
        );
      case 1: return const _MarketView();
      case 2: return _QuizView(
          onAddCoins: _addCoins,
          registeredCrops: _registeredCrops,
          archivedQuizzes: _archivedQuizzes,
          onArchive: (q) => setState(() => _archivedQuizzes.add(q)),
          onDeleteArchive: (q) => setState(() => _archivedQuizzes.remove(q)),
        );
      case 3: return EducationFeedScreen(
          selectedCrops: _registeredCrops,
        );
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: _buildCurrentScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerScreen()),
          );
          if (!context.mounted) return;
          if (result != null) _showScanResultDialog(context, result.toString());
        },
        backgroundColor: _kGreen,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        elevation: 12,
        shadowColor: Colors.black26,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavItem(Icons.storefront_outlined, Icons.storefront, 'Market', 1),
              const SizedBox(width: 56),
              _buildNavItem(Icons.quiz_outlined, Icons.quiz, 'Quiz', 2),
              _buildNavItem(Icons.school_outlined, Icons.school, 'Education', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final sel = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sel ? activeIcon : icon, color: sel ? _kGreen : Colors.grey.shade400, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: sel ? _kGreen : Colors.grey.shade400,
                    fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }

  void _showScanResultDialog(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('QR Code Scanned', style: TextStyle(color: _kDarkGreen)),
        content: Text('$value\n\nProceed with transaction?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Processed!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kGreen),
            child: const Text('Proceed', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// === QUIZ MODULE ===
class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  
  Question({required this.text, required this.options, required this.correctIndex});
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
}

class _QuizView extends StatefulWidget {
  final void Function(int, String) onAddCoins;
  final List<String> registeredCrops;
  final List<Quiz> archivedQuizzes;
  final void Function(Quiz) onArchive;
  final void Function(Quiz) onDeleteArchive;

  const _QuizView({
    required this.onAddCoins,
    required this.registeredCrops,
    required this.archivedQuizzes,
    required this.onArchive,
    required this.onDeleteArchive,
  });

  @override
  State<_QuizView> createState() => _QuizViewState();
}

enum QuizState { selection, active, summary }

class _QuizViewState extends State<_QuizView> {
  QuizState _state = QuizState.selection;
  Quiz? _activeQuiz;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;

  final List<Quiz> _allQuizzes = [
    Quiz(
      title: 'Kharif Crop Pest Management',
      topic: 'Pest Control',
      targetCrop: 'Cotton',
      difficulty: 'Medium',
      reward: 50,
      estimatedTime: '3 Mins',
      questions: [
        Question(
          text: 'What is the most effective biological control for Fall Armyworm?',
          options: ['Neem Oil Spray', 'Synthetic Pyrethroids', 'Urea Application', 'Flooding the field'],
          correctIndex: 0,
        ),
        Question(
          text: 'When is the best time to apply pesticide to minimize harm to beneficial insects?',
          options: ['Mid-day', 'Early morning or late evening', 'Right before rain', 'Midnight'],
          correctIndex: 1,
        ),
      ],
    ),
    Quiz(
      title: 'Soil Health & NPK Balance',
      topic: 'Soil Science',
      targetCrop: 'Soybean',
      difficulty: 'Hard',
      reward: 100,
      estimatedTime: '5 Mins',
      questions: [
        Question(
          text: 'Which nutrient is primarily responsible for leaf growth and green color?',
          options: ['Phosphorus', 'Potassium', 'Nitrogen', 'Calcium'],
          correctIndex: 2,
        ),
        Question(
          text: 'How often should a comprehensive soil test be conducted?',
          options: ['Every month', 'Every 6 months', 'Every 2-3 years', 'Once a decade'],
          correctIndex: 2,
        ),
      ],
    ),
    Quiz(
      title: 'Drip Irrigation Best Practices',
      topic: 'Water Management',
      targetCrop: 'Sugarcane',
      difficulty: 'Easy',
      reward: 30,
      estimatedTime: '2 Mins',
      questions: [
        Question(
          text: 'How much water can drip irrigation save compared to flood irrigation?',
          options: ['10-20%', '30-50%', '80-90%', 'None'],
          correctIndex: 1,
        ),
        Question(
          text: 'What is the primary maintenance task for drip lines?',
          options: ['Painting them', 'Acid wash / Flushing to prevent clogging', 'Burying them deep', 'Freezing them'],
          correctIndex: 1,
        ),
      ],
    ),
  ];

  void _startQuiz(Quiz q) {
    setState(() {
      _activeQuiz = q;
      _state = QuizState.active;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
    });
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
    }
  }

  void _finishQuiz() {
    final reward = (_score / _activeQuiz!.questions.length) * _activeQuiz!.reward;
    if (reward > 0) {
      widget.onAddCoins(reward.toInt(), 'Quiz Completed: ${_activeQuiz!.title}');
    }
    widget.onArchive(_activeQuiz!);
    setState(() {
      _state = QuizState.selection;
      _activeQuiz = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case QuizState.selection: return _buildSelectionDashboard();
      case QuizState.active: return _buildActiveQuiz();
      case QuizState.summary: return _buildSummary();
    }
  }

  Widget _buildSelectionDashboard() {
    final availableQuizzes = _allQuizzes.where((q) => 
        widget.registeredCrops.contains(q.targetCrop) && 
        !widget.archivedQuizzes.contains(q)
    ).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: const Row(
              children: [
                Icon(Icons.emoji_events, color: _kGreen, size: 28),
                SizedBox(width: 12),
                Text('Knowledge Quizzes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen)),
              ],
            ),
          ),
          Expanded(
            child: widget.registeredCrops.isEmpty 
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(color: _kLightGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.psychology_outlined, size: 52, color: _kGreen),
                      ),
                      const SizedBox(height: 20),
                      const Text('Please add crops to your profile to unlock custom daily quizzes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)),
                    ]),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (availableQuizzes.isNotEmpty) ...[
                      const Text("Today's Crop Challenges", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDarkGreen)),
                      const SizedBox(height: 16),
                      ...availableQuizzes.map((q) => _buildQuizCard(q, isArchive: false)),
                      const SizedBox(height: 24),
                    ],
                    if (widget.archivedQuizzes.isNotEmpty) ...[
                      const Text("Previous Quizzes Archive", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDarkGreen)),
                      const SizedBox(height: 16),
                      ...widget.archivedQuizzes.map((q) => _buildQuizCard(q, isArchive: true)),
                    ],
                    if (availableQuizzes.isEmpty && widget.archivedQuizzes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: Text("No quizzes available for your registered crops.", style: TextStyle(color: Colors.black54))),
                      ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Quiz q, {required bool isArchive}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _kLightGreen, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.eco, size: 12, color: _kGreen), const SizedBox(width: 4),
                    Text(q.targetCrop, style: const TextStyle(fontSize: 11, color: _kGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (isArchive)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => widget.onDeleteArchive(q),
                  constraints: const BoxConstraints(), padding: EdgeInsets.zero,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Text('\u{1FAA9}', style: TextStyle(fontSize: 12)), const SizedBox(width: 4),
                      Text('+${q.reward} Coins', style: const TextStyle(fontSize: 11, color: Color(0xFFB8860B), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(q.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDarkGreen)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer, size: 14, color: Colors.black45), const SizedBox(width: 4),
              Text(q.estimatedTime, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(width: 16),
              const Icon(Icons.bar_chart, size: 14, color: Colors.black45), const SizedBox(width: 4),
              Text(q.difficulty, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
          if (!isArchive) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startQuiz(q),
                style: ElevatedButton.styleFrom(backgroundColor: _kGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Start Quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]
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
                Text(_activeQuiz!.title, style: const TextStyle(fontSize: 14, color: _kGreen, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _activeQuiz!.questions.length,
              backgroundColor: _kLightGreen,
              color: _kGreen,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),
            Text(q.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen)),
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
                        color: isSelected ? _kLightGreen : Colors.white,
                        border: Border.all(color: isSelected ? _kGreen : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? _kGreen : Colors.grey.shade400, width: 2),
                              color: isSelected ? _kGreen : Colors.transparent,
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Text(q.options[i], style: TextStyle(fontSize: 16, color: isSelected ? _kDarkGreen : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
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
                style: ElevatedButton.styleFrom(backgroundColor: _kGreen, disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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
                decoration: const BoxDecoration(color: _kLightGreen, shape: BoxShape.circle),
                child: const Icon(Icons.emoji_events, size: 80, color: Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 32),
              const Text('Quiz Completed!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _kDarkGreen)),
              const SizedBox(height: 16),
              Text('You scored $_score out of $maxScore', style: const TextStyle(fontSize: 18, color: Colors.black87)),
              const SizedBox(height: 24),
              if (reward > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD4AF37))),
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
                  onPressed: _finishQuiz,
                  style: ElevatedButton.styleFrom(backgroundColor: _kGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Back to Dashboard', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// === TASKS DATA MODEL ===
class TaskItem {
  final String id;
  final String title;
  final String description;
  final int reward;
  String status; // 'Not Started', 'Pending Verification', 'Approved'
  String? mockImagePath;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    this.status = 'Not Started',
    this.mockImagePath,
  });
}

// === DASHBOARD VIEW ===
class _DashboardView extends StatefulWidget {
  final int greenCoins;
  final int streak;
  final String farmerName;
  final List<String> registeredCrops;
  final List<String> completedTasks;
  final VoidCallback onShowProfile;
  final void Function(int, String) onAddCoins;
  final void Function(int, String) onLogTransaction;
  final int completedQuizzesCount;
  final List<AppNotification> notifications;
  final VoidCallback onOpenNotifications;

  const _DashboardView({
    required this.greenCoins,
    required this.streak,
    required this.farmerName,
    required this.registeredCrops,
    required this.completedTasks,
    required this.onShowProfile,
    required this.onAddCoins,
    required this.onLogTransaction,
    required this.completedQuizzesCount,
    required this.notifications,
    required this.onOpenNotifications,
  });

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  List<TaskItem> _tasks = [];
  bool _tasksLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasksFromFirestore();
  }

  @override
  void didUpdateWidget(_DashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload tasks if crops changed
    if (oldWidget.registeredCrops != widget.registeredCrops) {
      _loadTasksFromFirestore();
    }
  }

  void _loadTasksFromFirestore() async {
    if (widget.registeredCrops.isEmpty) {
      if (mounted) setState(() { _tasks = []; _tasksLoading = false; });
      return;
    }
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('crop', whereIn: widget.registeredCrops)
          .where('active', isEqualTo: true)
          .get();
      if (mounted) {
        setState(() {
          _tasks = snapshot.docs.map((doc) {
            final d = doc.data();
            return TaskItem(
              id: doc.id,
              title: d['title'] ?? '',
              description: d['description'] ?? '',
              reward: d['coinsReward'] as int? ?? 0,
            );
          }).where((task) => !widget.completedTasks.contains(task.id)).toList();
          _tasksLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _tasksLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onShowProfile,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Namaste,', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        const SizedBox(height: 2),
                        Text('${widget.farmerName} \u{1F33E}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: _kDarkGreen, size: 28),
                          onPressed: widget.onOpenNotifications,
                        ),
                        if (widget.notifications.any((n) => !n.isRead))
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onShowProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.6), width: 1.5),
                          boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.2), blurRadius: 12)],
                        ),
                        child: Row(children: [
                          const Icon(Icons.eco, color: _kGreen, size: 18),
                          const SizedBox(width: 6),
                          Text('${widget.greenCoins} \u{1FAA9}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kDarkGreen)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Quick Progress
            const Text('Quick Progress', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _kDarkGreen)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(children: [
                _progressCard("Today's Streak", '${widget.streak} Days', widget.streak > 0 ? 'Keep it up! 🔥' : 'Start your streak!', Icons.local_fire_department, Colors.orange),
                const SizedBox(width: 14),
                _progressCard('Quizzes Done', '${widget.completedQuizzesCount}', 'Complete to earn coins', Icons.assignment_turned_in, _kGreen),
                const SizedBox(width: 14),
                _progressCard(
                  'Tasks Pending', 
                  '${_tasks.where((t) => t.status != 'Approved').length}', 
                  'Complete for rewards', 
                  Icons.pending_actions, 
                  Colors.blueAccent,
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // Real-life Tasks Window
            const Text('Real-Life Tasks & Rewards', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _kDarkGreen)),
            const SizedBox(height: 12),
            if (_tasksLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: _kGreen),
              ))
            else if (_tasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: Column(children: [
                    Icon(Icons.assignment_outlined, size: 48, color: Colors.black26),
                    SizedBox(height: 12),
                    Text('No tasks assigned yet', style: TextStyle(color: Colors.black45, fontSize: 15)),
                    SizedBox(height: 4),
                    Text('Admin will assign tasks for your crops soon', style: TextStyle(color: Colors.black38, fontSize: 13)),
                  ]),
                ),
              )
            else
              ..._tasks.map((task) => _buildTaskCard(task)),
            const SizedBox(height: 28),

            // Subsidies
            const Text('Active Subsidies & Discounts',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _kDarkGreen)),
            const SizedBox(height: 14),
            _subsidyCard(context, 'Neem Coated Urea', '50% Govt Subsidy applied \u2014 Gov. Price: \u20b9242/bag', 'Govt', Colors.green),
            _subsidyCard(context, 'Mahyco Hybrid Cotton Seeds', '\u20b9250 Cash Discount via Green Coins', 'Store', Colors.orange),
            _subsidyCard(context, 'N-P-K 19:19:19 Fertilizer', '20% Direct Benefit Transfer (DBT) Scheme', 'DBT', Colors.blue),
            _subsidyCard(context, 'Drip Irrigation Lateral Pipes', '80% State Subsidy for small farmers', 'State', Colors.teal),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    Color statusColor = Colors.grey;
    String statusText = 'Not Started';
    IconData statusIcon = Icons.radio_button_unchecked;

    if (task.status == 'Pending Verification') {
      statusColor = Colors.orange;
      statusText = 'Under Admin Review';
      statusIcon = Icons.hourglass_empty;
    } else if (task.status == 'Approved') {
      statusColor = _kGreen;
      statusText = 'Verified & Approved';
      statusIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        border: Border.all(
          color: task.status == 'Approved' 
              ? _kGreen.withOpacity(0.3) 
              : (task.status == 'Pending Verification' ? Colors.orange.withOpacity(0.3) : Colors.transparent),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kDarkGreen),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('\u{1FAA9}', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '+${task.reward} Coins',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFB8860B), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            task.description,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        statusText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (task.status == 'Not Started')
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final XFile? photo = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );
                      if (photo != null && mounted) {
                        setState(() {
                          task.status = 'Pending Verification';
                          task.mockImagePath = photo.path;
                        });
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Photo captured! Verifying with Gemini AI...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        
                        // Call Gemini Verification
                        final verified = await AiService().verifyTaskPhoto(photo.path, task.description);
                        
                        if (mounted) {
                          if (verified) {
                            bool canEarn = await UserService().canEarnTaskRewardToday();
                            await UserService().recordTaskCompletion(task.id, task.reward, canEarn);
                            
                            setState(() {
                              task.status = 'Approved';
                              // If they couldn't earn, it will disappear from UI when stream updates, 
                              // but let's visually mark it approved for a moment.
                            });
                            
                            if (canEarn) {
                              widget.onLogTransaction(task.reward, 'Task Verified: ${task.title}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('AI Verification Success! Task Approved. +${task.reward} Coins!'),
                                  backgroundColor: _kGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Task Verified! (Daily reward already claimed today)'),
                                  backgroundColor: _kGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } else {
                            setState(() {
                              task.status = 'Not Started'; // Reset so they can try again
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('AI Verification Failed. Photo does not match task description. Please try again.'),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error accessing camera: $e'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  label: const Text('Capture Proof', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else if (task.status == 'Pending Verification')
                const Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)),
                        SizedBox(width: 8),
                        Text('AI Verifying...', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.done_all, color: _kGreen, size: 16),
                    SizedBox(width: 4),
                    Text('Completed', style: TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressCard(String title, String value, String sub, IconData icon, Color color) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22)),
        const SizedBox(height: 14),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(sub, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ]),
    );
  }

  Widget _subsidyCard(BuildContext ctx, String title, String sub, String tag, Color tagColor) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: ctx,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _kDarkGreen)),
              const SizedBox(height: 8),
              Text(sub, style: const TextStyle(fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 16),
              const Text('How to Claim:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _kDarkGreen)),
              const SizedBox(height: 8),
              const Text('1. Visit your registered local store.\n2. Tap the central QR scanner button.\n3. Scan the shopkeeper QR code.\n4. Ledger reflects the subsidy automatically.',
                  style: TextStyle(fontSize: 14, height: 1.6)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(backgroundColor: _kGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Got it', style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
            ]),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _kDarkGreen)),
            const SizedBox(height: 5),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ])),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: tagColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(tag, style: TextStyle(color: tagColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 20, color: Colors.black38),
        ]),
      ),
    );
  }
}

// === PROFILE MODAL ===
void _showProfileModal(BuildContext context, int greenCoins, List<Map<String, dynamic>> transactions, List<String> crops, void Function(List<String>) onUpdateCrops) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, sc) => _ProfileModal(
        scrollController: sc,
        greenCoins: greenCoins,
        transactions: transactions,
        crops: crops,
        onUpdateCrops: onUpdateCrops,
      ),
    ),
  );
}

class _ProfileModal extends StatefulWidget {
  final ScrollController? scrollController;
  final int greenCoins;
  final List<Map<String, dynamic>> transactions;
  final List<String> crops;
  final void Function(List<String>) onUpdateCrops;

  const _ProfileModal({
    this.scrollController,
    required this.greenCoins,
    required this.transactions,
    required this.crops,
    required this.onUpdateCrops,
  });
  @override
  State<_ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<_ProfileModal> {
  bool _showHistory = false;
  bool _isEditing = false;
  String _selectedDistrict = 'Latur';
  String _selectedLanguage = 'Marathi';
  final _farmCtrl = TextEditingController(text: '4.5');

  final _mhDistricts = ['Latur', 'Wardha', 'Pune', 'Nashik', 'Jalgaon', 'Aurangabad', 'Nagpur', 'Solapur'];
  final _langs = ['Marathi', 'Hindi', 'English'];

  @override
  void dispose() {
    _farmCtrl.dispose();
    super.dispose();
  }

  void _otpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.security, color: _kDarkGreen), SizedBox(width: 8),
          Text('Aadhaar Re-Verification', style: TextStyle(fontSize: 16, color: _kDarkGreen)),
        ]),
        content: const Text('An OTP will be sent to your Aadhaar-linked mobile to unlock editing of Name or Phone.\n\n(Requires backend integration.)', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: _kGreen),
            child: const Text('Request OTP', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        children: [
          const SizedBox(height: 12),
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Farmer Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDarkGreen)),
              TextButton.icon(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                icon: Icon(_isEditing ? Icons.check_circle : Icons.edit, size: 16, color: _kGreen),
                label: Text(_isEditing ? 'Save' : 'Edit Profile',
                    style: const TextStyle(color: _kGreen, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const SizedBox(height: 8),

          // Identity card
          _card(children: [
            Row(children: [
              const CircleAvatar(radius: 30, backgroundColor: _kLightGreen,
                  child: Icon(Icons.person, size: 32, color: _kGreen)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Rajesh Patil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDarkGreen)),
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: _kGreen, size: 22),
                    onPressed: () => _showQr(context),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                ]),
                const Text('+91 98765 43210', style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _kGreen.withOpacity(0.4))),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.verified_user, size: 12, color: _kGreen), SizedBox(width: 4),
                    Text('Aadhaar Verified', style: TextStyle(fontSize: 11, color: _kGreen, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ])),
            ]),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _otpDialog,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200)),
                child: const Row(children: [
                  Icon(Icons.lock_outline, size: 15, color: Colors.black45), SizedBox(width: 8),
                  Expanded(child: Text('Name & Phone are Aadhaar-locked. Tap to request OTP re-verification.',
                      style: TextStyle(fontSize: 12, color: Colors.black45))),
                ]),
              ),
            ),
          ]),

          // DBT Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
                  borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.account_balance, color: Colors.white, size: 22), SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('DBT Bank Status: Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Direct Benefit Transfers enabled for your account', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ])),
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Farm Details
          _card(title: 'Farm Details', children: [
            _infoRow(Icons.location_on_outlined, 'State', 'Maharashtra', locked: true),
            const Divider(height: 20),
            _isEditing
                ? _dropRow(Icons.map_outlined, 'Primary District', _selectedDistrict, _mhDistricts,
                    (v) => setState(() => _selectedDistrict = v!))
                : _infoRow(Icons.map_outlined, 'Primary District', _selectedDistrict),
            const Divider(height: 20),
            _isEditing
                ? _tfRow(Icons.landscape_outlined, 'Farm Size', _farmCtrl, 'Hectares')
                : _infoRow(Icons.landscape_outlined, 'Farm Size', '${_farmCtrl.text} Hectares'),
            const Divider(height: 20),
            _isEditing
                ? _dropRow(Icons.language_outlined, 'Language', _selectedLanguage, _langs,
                    (v) => setState(() => _selectedLanguage = v!))
                : _infoRow(Icons.language_outlined, 'Language', _selectedLanguage),
          ]),

          // Crops
          _card(title: 'Registered Crops', children: [
            Wrap(
              spacing: 8, runSpacing: 8,
              children: widget.crops.map((c) => Chip(
                label: Text(c, style: const TextStyle(fontSize: 12, color: _kDarkGreen)),
                backgroundColor: _kLightGreen, side: BorderSide.none,
                onDeleted: _isEditing ? () {
                  final newCrops = List<String>.from(widget.crops)..remove(c);
                  widget.onUpdateCrops(newCrops);
                } : null,
              )).toList(),
            ),
          ]),

          // Wallet
          _card(children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kGreen, _kDarkGreen]),
                  borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Green Coins Wallet', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Icon(Icons.account_balance_wallet, color: Colors.white70, size: 18),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Text('${widget.greenCoins}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Text('\u{1FAA9}', style: TextStyle(fontSize: 26)),
                ]),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () => setState(() => _showHistory = !_showHistory),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Transaction History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    Icon(_showHistory ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white),
                  ]),
                ),
                if (_showHistory) ...[
                  const Divider(color: Colors.white24, height: 20),
                  ...widget.transactions.map((tx) => _txRow(tx)),
                ],
              ]),
            ),
          ]),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: _kLightGreen,
                    child: Icon(Icons.qr_code_scanner, color: _kGreen, size: 20)),
                title: const Text('Scan QR Code', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Scan shopkeeper QR to transact', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const QRScannerScreen()));
                  if (!context.mounted) return;
                  if (result != null) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Scanned Value', style: TextStyle(color: _kDarkGreen)),
                          content: Text('$result\n\nProceed with transaction?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Transaction Processed!')));
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: _kGreen),
                              child: const Text('Proceed', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    });
                  }
                },
              ),
              const Divider(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.logout, color: Colors.red, size: 20)),
                title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _card({String? title, required List<Widget> children}) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: Colors.black45, letterSpacing: 0.5)),
            const SizedBox(height: 12),
          ],
          ...children,
        ]),
      );

  Widget _infoRow(IconData icon, String label, String value, {bool locked = false}) => Row(children: [
        Icon(icon, size: 18, color: Colors.black45), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        ])),
        if (locked) const Icon(Icons.lock, size: 14, color: Colors.black26),
      ]);

  Widget _dropRow(IconData icon, String label, String value, List<String> items, ValueChanged<String?> cb) =>
      Row(children: [
        Icon(icon, size: 18, color: _kGreen), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
          DropdownButton<String>(
            value: value, isExpanded: true, isDense: true,
            underline: Container(height: 1, color: _kGreen.withOpacity(0.3)),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: cb,
          ),
        ])),
      ]);

  Widget _tfRow(IconData icon, String label, TextEditingController ctrl, String suffix) => Row(children: [
        Icon(icon, size: 18, color: _kGreen), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
          TextFormField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            decoration: InputDecoration(
              isDense: true, suffixText: suffix,
              suffixStyle: const TextStyle(color: Colors.black54, fontSize: 13),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kGreen.withOpacity(0.3))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _kGreen)),
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ])),
      ]);

  Widget _txRow(Map<String, dynamic> tx) {
    final isCredit = tx['credit'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isCredit ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
          child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, size: 14,
              color: isCredit ? Colors.greenAccent : Colors.redAccent),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('${tx['dt']}  \u2022  ID: ${tx['id']}',
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ])),
        Text('${tx['amount']} \u{1FAA9}',
            style: TextStyle(
                color: isCredit ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }

  void _showQr(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('My QR Code', textAlign: TextAlign.center,
            style: TextStyle(color: _kDarkGreen, fontSize: 16)),
        content: Container(
          width: 200, height: 200,
          decoration: BoxDecoration(color: Colors.white,
              border: Border.all(color: _kGreen, width: 4), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.qr_code_2, size: 160, color: Colors.black87),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }
}

// === MARKET VIEW ===
class _MarketView extends StatefulWidget {
  const _MarketView();
  @override
  State<_MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends State<_MarketView> {
  String _searchQuery = '';
  String? _selectedDistrict;
  final AdminService _adminService = AdminService();

  final _districts = [
    "Ahmednagar", "Akola", "Amravati", "Chhatrapati Sambhajinagar", "Beed", "Bhandara", "Buldhana", "Chandrapur", "Dhule", "Gadchiroli", "Gondia", "Hingoli", "Jalgaon", "Jalna", "Kolhapur", "Latur", "Mumbai City", "Mumbai Suburban", "Nagpur", "Nanded", "Nandurbar", "Nashik", "Osmanabad", "Palghar", "Parbhani", "Pune", "Raigad", "Ratnagiri", "Sangli", "Satara", "Sindhudurg", "Solapur", "Thane", "Wardha", "Washim", "Yavatmal"
  ];

  @override
  void initState() {
    super.initState();
    _adminService.addListener(_onAdminUpdate);
  }

  @override
  void dispose() {
    _adminService.removeListener(_onAdminUpdate);
    super.dispose();
  }

  void _onAdminUpdate() {
    if (mounted) setState(() {});
  }

  final _db = [
    {'cropName': 'Soybean',     'district': 'Latur',      'price': '\u20b94,600/Quintal', 'trend': true,  'lastUpdated': 'Updated Today'},
    {'cropName': 'Sugarcane',   'district': 'Latur',      'price': '\u20b93,200/Ton',     'trend': false, 'lastUpdated': 'Updated Today'},
    {'cropName': 'Tur Dal',     'district': 'Latur',      'price': '\u20b96,800/Quintal', 'trend': true,  'lastUpdated': 'Updated Yesterday'},
    {'cropName': 'Cotton',      'district': 'Wardha',     'price': '\u20b97,100/Quintal', 'trend': true,  'lastUpdated': 'Updated Today'},
    {'cropName': 'Soybean',     'district': 'Wardha',     'price': '\u20b94,550/Quintal', 'trend': false, 'lastUpdated': 'Updated 2 days ago'},
    {'cropName': 'Orange',      'district': 'Nagpur',     'price': '\u20b94,200/Quintal', 'trend': true,  'lastUpdated': 'Updated Today'},
    {'cropName': 'Wheat',       'district': 'Nashik',     'price': '\u20b92,350/Quintal', 'trend': true,  'lastUpdated': 'Updated Yesterday'},
    {'cropName': 'Grapes',      'district': 'Nashik',     'price': '\u20b98,500/Quintal', 'trend': true,  'lastUpdated': 'Updated Today'},
    {'cropName': 'Onion',       'district': 'Nashik',     'price': '\u20b91,800/Quintal', 'trend': false, 'lastUpdated': 'Updated Today'},
    {'cropName': 'Banana',      'district': 'Jalgaon',    'price': '\u20b92,100/Quintal', 'trend': true,  'lastUpdated': 'Updated Today'},
    {'cropName': 'Cotton',      'district': 'Jalgaon',    'price': '\u20b97,050/Quintal', 'trend': false, 'lastUpdated': 'Updated 2 days ago'},
    {'cropName': 'Pomegranate', 'district': 'Solapur',    'price': '\u20b99,200/Quintal', 'trend': true,  'lastUpdated': 'Updated Today'},
    {'cropName': 'Soybean',     'district': 'Aurangabad', 'price': '\u20b94,520/Quintal', 'trend': true,  'lastUpdated': 'Updated Yesterday'},
    {'cropName': 'Maize',       'district': 'Pune',       'price': '\u20b92,050/Quintal', 'trend': false, 'lastUpdated': 'Updated Today'},
    {'cropName': 'Tomato',      'district': 'Pune',       'price': '\u20b91,400/Quintal', 'trend': true,  'lastUpdated': 'Updated Today'},
  ];

  @override
  Widget build(BuildContext context) {
    // Collect live items from AdminService
    final adminItems = _adminService.marketPrices.where((item) {
      final matchesDist = _selectedDistrict == null || item.district == _selectedDistrict;
      final matchesQuery = _searchQuery.isEmpty ||
          item.cropName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.mandiName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesDist && matchesQuery;
    }).map((item) => {
      'cropName': item.cropName,
      'district': '${item.mandiName} (${item.district})',
      'price': '₹${item.currentPrice.toStringAsFixed(0)}/${item.unit}',
      'trend': item.isUp,
      'lastUpdated': 'Govt Verified • Just Now',
      'isGovtVerified': true,
    }).toList();

    final filtered = _selectedDistrict == null && _searchQuery.isEmpty
        ? adminItems
        : [
            ...adminItems,
            ..._db.where((e) =>
                (_selectedDistrict == null || e['district'] == _selectedDistrict) &&
                (e['cropName'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList()
          ];

    return Scaffold(
      backgroundColor: _kCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('APMC Mandi Prices',
            style: TextStyle(color: _kDarkGreen, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _kLightGreen, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kGreen.withOpacity(0.3))),
            child: const Row(children: [
              Icon(Icons.location_on, size: 14, color: _kGreen), SizedBox(width: 4),
              Text('Maharashtra', style: TextStyle(fontSize: 12, color: _kDarkGreen, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDistrict,
                    isExpanded: true,
                    hint: const Row(children: [
                      Icon(Icons.map_outlined, size: 18, color: _kGreen), SizedBox(width: 8),
                      Text('Select your district\u2026', style: TextStyle(color: Colors.black54, fontSize: 14)),
                    ]),
                    icon: const Icon(Icons.keyboard_arrow_down, color: _kGreen),
                    items: _districts.map((d) => DropdownMenuItem(
                      value: d,
                      child: Row(children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: _kGreen), const SizedBox(width: 8),
                        Text(d, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                    )).toList(),
                    onChanged: (v) => setState(() { _selectedDistrict = v; _searchQuery = ''; }),
                  ),
                ),
              ),
              if (_selectedDistrict != null) ...[
                const SizedBox(height: 10),
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search crops in $_selectedDistrict\u2026',
                    prefixIcon: const Icon(Icons.search, color: _kGreen, size: 20),
                    filled: true, fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDistrict == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(color: _kLightGreen, shape: BoxShape.circle),
                          child: const Icon(Icons.store, size: 52, color: _kGreen),
                        ),
                        const SizedBox(height: 20),
                        const Text('Please select your district to view local APMC mandi rates.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)),
                        const SizedBox(height: 10),
                        Text('Prices sourced from official Government APMC portals.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                      ]),
                    ),
                  )
                : filtered.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text('No crops match your search', style: TextStyle(color: Colors.black54)),
                      ]))
                    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('$_selectedDistrict APMC Mandi',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _kDarkGreen)),
                            Text('${filtered.length} crops',
                                style: const TextStyle(color: Colors.black45, fontSize: 13)),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => _cropCard(filtered[i]),
                          ),
                        ),
                      ]),
          ),
        ],
      ),
    );
  }

  Widget _cropCard(Map<String, dynamic> item) {
    final isUp = item['trend'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _kLightGreen, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.grass, size: 18, color: _kGreen),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item['cropName'] as String,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kDarkGreen),
                  overflow: TextOverflow.ellipsis),
            ),
            if (item['isGovtVerified'] == true) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: const Text(
                  'Govt Verified',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ]),
          Row(children: [
            Text(item['price'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isUp ? _kGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isUp ? _kGreen : Colors.redAccent, size: 14),
            ),
          ]),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 13, color: Colors.black45), const SizedBox(width: 3),
            Text(item['district'] as String, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
          Row(children: [
            const Icon(Icons.access_time, size: 12, color: Colors.black38), const SizedBox(width: 3),
            Text(item['lastUpdated'] as String, style: const TextStyle(fontSize: 11, color: Colors.black38)),
          ]),
        ]),
      ]),
    );
  }
}
