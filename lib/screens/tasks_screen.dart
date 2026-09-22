import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/translation_service.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  final List<String> completedTasks;
  final List<String> pendingTasks;
  final String farmerId;
  final String farmerName;
  final String farmerEmail;
  final String farmerState;
  final String farmerDistrict;
  final List<String> registeredCrops;

  const TasksScreen({
    super.key,
    required this.completedTasks,
    required this.pendingTasks,
    required this.farmerId,
    required this.farmerName,
    required this.farmerEmail,
    required this.farmerState,
    required this.farmerDistrict,
    required this.registeredCrops,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Fallback static tasks if none published on Firebase
  final List<Map<String, dynamic>> _fallbackTasks = [
    {
      'id': 'task_weed_01',
      'title': 'Weed Management Proof',
      'desc': 'Take a clear photo showing recent weeding done in your field.',
      'reward': 200,
      'videoId': 'gH2QjG-07d0',
    },
    {
      'id': 'task_irrigation_01',
      'title': 'Irrigation Setup',
      'desc': 'Upload a photo showing your current drip/sprinkler layout.',
      'reward': 150,
      'videoId': 'nQYqY58L2K8',
    },
    {
      'id': 'task_soil_01',
      'title': 'Soil Testing Report',
      'desc': 'Snap a photo of a recent soil health card or lab report.',
      'reward': 300,
      'videoId': '2N3jH720WfE',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              children: [
                const Icon(Icons.assignment, color: Color(0xFF4A7C59), size: 28),
                const SizedBox(width: 12),
                Text(TranslationService.tr('daily_task'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2A5934))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tasks').where('active', isEqualTo: true).snapshots(),
              builder: (context, snapshot) {
                List<Map<String, dynamic>> allTasks = [];
                
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  allTasks = snapshot.data!.docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    data['id'] = d.id;
                    data['reward'] = data['coinsReward'] ?? 0;
                    data['desc'] = data['description'] ?? '';
                    data['videoId'] = data['videoId'] ?? 'gH2QjG-07d0'; // Fallback video ID
                    return data;
                  }).toList();
                } else {
                  allTasks = _fallbackTasks;
                }

                // Determine "Task of the Day" using date math to cycle through available tasks
                final dayOfYear = int.parse(DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays.toString());
                final taskIndex = dayOfYear % allTasks.length;
                final task = allTasks[taskIndex];

                final isCompleted = widget.completedTasks.contains(task['id']);
                final isPending = widget.pendingTasks.contains(task['id']);

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTaskCard(task, isCompleted, isPending),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, bool isCompleted, bool isPending) {
    return GestureDetector(
      onTap: () {
        final crop = widget.registeredCrops.isNotEmpty ? widget.registeredCrops.first : 'General';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(
              task: task,
              isCompleted: isCompleted,
              isPending: isPending,
              farmerId: widget.farmerId,
              farmerName: widget.farmerName,
              farmerEmail: widget.farmerEmail,
              farmerState: widget.farmerState,
              farmerDistrict: widget.farmerDistrict,
              crop: crop,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(isCompleted, isPending),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFD4AF37).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 12)), const SizedBox(width: 4),
                      Text('+${task['reward']} Coins', style: const TextStyle(fontSize: 11, color: Color(0xFFB8860B), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(task['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A5934))),
            const SizedBox(height: 6),
            Text(task['desc'], style: const TextStyle(fontSize: 14, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final crop = widget.registeredCrops.isNotEmpty ? widget.registeredCrops.first : 'General';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(
                        task: task,
                        isCompleted: isCompleted,
                        isPending: isPending,
                        farmerId: widget.farmerId,
                        farmerName: widget.farmerName,
                        farmerEmail: widget.farmerEmail,
                        farmerState: widget.farmerState,
                        farmerDistrict: widget.farmerDistrict,
                        crop: crop,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                label: Text(
                  TranslationService.tr('watch_tutorial'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isCompleted, bool isPending) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
        child: Text(TranslationService.tr('verified'), style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
      );
    } else if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
        child: Text(TranslationService.tr('under_review'), style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
        child: Text(TranslationService.tr('available'), style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
      );
    }
  }
}
