import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integrated_agri_hub/services/user_service.dart';
import 'package:integrated_agri_hub/services/task_verification_service.dart';


const Color _kGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);

class TaskItem {
  final String id;
  final String title;
  final String description;
  final int reward;
  String status; // 'Not Started', 'Pending Verification', 'Approved', 'Rejected'
  String? mockImagePath;
  String? rejectionReason;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    this.status = 'Not Started',
    this.mockImagePath,
    this.rejectionReason,
  });
}

class TasksView extends StatefulWidget {
  final List<String> registeredCrops;
  final List<String> completedTasks;
  final String farmerName;

  const TasksView({
    super.key,
    required this.registeredCrops,
    required this.completedTasks,
    required this.farmerName,
  });

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  List<TaskItem> _tasks = [];
  bool _tasksLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasksFromFirestore();
  }

  @override
  void didUpdateWidget(TasksView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.registeredCrops != widget.registeredCrops) {
      _loadTasksFromFirestore();
    }
  }

  void _loadTasksFromFirestore() async {
    final crops = widget.registeredCrops.isNotEmpty
        ? widget.registeredCrops
        : ['Cotton', 'Soybean', 'Sugarcane', 'Wheat', 'Rice'];

    try {
      final uid = UserService().currentUid;
      // 1. Fetch active tasks for crops
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('crop', whereIn: crops)
          .where('active', isEqualTo: true)
          .get();

      // 2. Fetch submissions for this farmer
      Map<String, Map<String, dynamic>> submissionsMap = {};
      if (uid != null) {
        final subSnap = await FirebaseFirestore.instance
            .collection('task_submissions')
            .where('farmerId', isEqualTo: uid)
            .get();
        for (var d in subSnap.docs) {
          final data = d.data();
          final taskId = (data['taskId'] ?? '').toString();
          // Prioritize 'pending' if multiple submissions exist
          if (!submissionsMap.containsKey(taskId) || data['status'] == 'pending') {
            submissionsMap[taskId] = data;
          }
        }
      }

      if (mounted) {
        setState(() {
          List<TaskItem> fetchedTasks = snapshot.docs.map((doc) {
            final d = doc.data();
            final tId = doc.id;
            
            final submission = submissionsMap[tId];
            String status = 'Not Started';
            String? rejectionReason;
            
            if (submission != null) {
              if (submission['status'] == 'pending') {
                status = 'Pending Verification';
              } else if (submission['status'] == 'rejected') {
                status = 'Rejected';
                rejectionReason = submission['rejectionReason']?.toString();
              } else if (submission['status'] == 'approved') {
                status = 'Approved';
              }
            }

            return TaskItem(
              id: tId,
              title: d['title'] ?? '',
              description: d['description'] ?? '',
              reward: (d['coinsReward'] as num?)?.toInt() ?? 50,
              status: status,
              rejectionReason: rejectionReason,
            );
          }).toList();

          if (fetchedTasks.isEmpty && crops.isNotEmpty) {
            final dateStr = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
            final tId = 'daily_task_${crops.first}_$dateStr';
            final submission = submissionsMap[tId];
            String status = 'Not Started';
            String? rejectionReason;
            if (submission != null) {
              if (submission['status'] == 'pending') {
                status = 'Pending Verification';
              } else if (submission['status'] == 'rejected') {
                status = 'Rejected';
                rejectionReason = submission['rejectionReason']?.toString();
              } else if (submission['status'] == 'approved') {
                status = 'Approved';
              }
            }
            fetchedTasks.add(TaskItem(
              id: tId,
              title: 'Daily Field Inspection: ${crops.first}',
              description: 'Take a clear, live photo or video of your ${crops.first} crop for AI health analysis and claim your daily reward.',
              reward: 100,
              status: status,
              rejectionReason: rejectionReason,
            ));
          }

          _tasks = fetchedTasks;
          _tasksLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _tasksLoading = false);
    }
  }

  void _showProofUploadModal(TaskItem task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Capture Live Proof: ${task.title}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _kDarkGreen),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please capture live photo or video directly from your farm/field using camera for authentic verification.',
              style: TextStyle(color: Colors.black54, fontSize: 12.5),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: _kGreen, size: 24),
              ),
              title: const Text('Capture Live Photo (Camera)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
              subtitle: const Text('Take photo directly from your field right now', style: TextStyle(fontSize: 11.5)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSubmitProof(task, isVideo: false);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
                child: const Icon(Icons.videocam_rounded, color: Color(0xFFD97706), size: 24),
              ),
              title: const Text('Record Live Video (Camera)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
              subtitle: const Text('Record a short 5-15 second farm video proof', style: TextStyle(fontSize: 11.5)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSubmitProof(task, isVideo: true);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _pickAndSubmitProof(TaskItem task, {required bool isVideo}) async {
    try {
      XFile? file;
      if (isVideo) {
        file = await ImagePicker().pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 30),
        );
      } else {
        file = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
      }

      if (file == null || !mounted) return;

      setState(() {
        task.status = 'Pending Verification';
        task.mockImagePath = file!.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uploading proof to Admin & AI verification portal...'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final uid = UserService().currentUid ?? 'guest_farmer';

      await TaskVerificationService().submitTaskProof(
        taskId: task.id,
        taskTitle: task.title,
        taskDescription: task.description,
        crop: widget.registeredCrops.isNotEmpty ? widget.registeredCrops.first : 'Farm Crop',
        coinsReward: task.reward,
        farmerId: uid,
        farmerName: widget.farmerName,
        farmerEmail: '',
        farmerState: '',
        farmerDistrict: '',
        filePath: file.path,
        isVideo: isVideo,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🌾 Task proof submitted! Sent to Admin & AI Verification Portal. You will receive +${task.reward} Green Coins upon approval.'),
            backgroundColor: _kGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading task proof: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildTaskCard(TaskItem task) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;
    String statusText = task.status;

    switch (task.status) {
      case 'Not Started':
        statusColor = Colors.grey;
        statusIcon = Icons.radio_button_unchecked;
        break;
      case 'Pending Verification':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'Approved':
        statusColor = _kGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        border: Border.all(
          color: task.status == 'Approved' 
              ? _kGreen.withValues(alpha: 0.3) 
              : (task.status == 'Rejected' 
                  ? Colors.red.withValues(alpha: 0.3) 
                  : (task.status == 'Pending Verification' ? Colors.orange.withValues(alpha: 0.3) : Colors.transparent)),
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
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 12)),
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
          if (task.status == 'Rejected' && task.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.feedback_outlined, size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Admin Feedback: ${task.rejectionReason}',
                      style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              if (task.status == 'Not Started' || task.status == 'Rejected')
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () => _showProofUploadModal(task),
                    icon: const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.white),
                    label: FittedBox(child: Text(task.status == 'Rejected' ? 'Retry Upload' : 'Upload Proof', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.status == 'Rejected' ? Colors.red : _kGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                )
              else if (task.status == 'Pending Verification')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.8, color: Colors.orange)),
                      SizedBox(width: 6),
                      Text('Submitted to Admin/AI', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.done_all, color: _kGreen, size: 16),
                    SizedBox(width: 4),
                    Text('Coins Claimed', style: TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

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
            child: const Row(
              children: [
                Icon(Icons.assignment, color: _kGreen, size: 28),
                SizedBox(width: 12),
                Text('Field Tasks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kDarkGreen)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
