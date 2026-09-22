import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../services/task_verification_service.dart';
import '../services/translation_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final bool isCompleted;
  final bool isPending;
  final String farmerId;
  final String farmerName;
  final String farmerEmail;
  final String farmerState;
  final String farmerDistrict;
  final String crop;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.isCompleted,
    required this.isPending,
    required this.farmerId,
    required this.farmerName,
    required this.farmerEmail,
    required this.farmerState,
    required this.farmerDistrict,
    required this.crop,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late YoutubePlayerController _ytController;
  bool _isUploading = false;
  final TaskVerificationService _taskService = TaskVerificationService();

  @override
  void initState() {
    super.initState();
    // Use the provided video ID or fallback to a standard farming tutorial video
    final videoId = widget.task['videoId'] ?? 'gH2QjG-07d0'; // Placeholder ID (change as needed)
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _ytController.close();
    super.dispose();
  }

  Future<void> _uploadProof() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 30, // Compress heavily to stay under 1MB Firestore limit
    );

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      await _taskService.submitTaskProof(
        taskId: widget.task['id'],
        taskTitle: widget.task['title'],
        taskDescription: widget.task['desc'],
        crop: widget.crop,
        coinsReward: widget.task['reward'],
        farmerId: widget.farmerId,
        farmerName: widget.farmerName,
        farmerEmail: widget.farmerEmail,
        farmerState: widget.farmerState,
        farmerDistrict: widget.farmerDistrict,
        filePath: pickedFile.path,
        isVideo: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TranslationService.tr('pending_verification') + '!'),
            backgroundColor: const Color(0xFF4A7C59),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(TranslationService.tr('daily_task'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2A5934),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Tutorial Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: YoutubePlayer(
                controller: _ytController,
                aspectRatio: 16 / 9,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.play_circle_fill, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  TranslationService.tr('watch_tutorial'),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Task Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(widget.isCompleted, widget.isPending),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFD4AF37).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 12)), const SizedBox(width: 4),
                            Text('+${widget.task['reward']} Coins', style: const TextStyle(fontSize: 12, color: Color(0xFFB8860B), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.task['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2A5934))),
                  const SizedBox(height: 12),
                  Text(TranslationService.tr('task_description'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text(widget.task['desc'], style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Upload Action Section
            if (_isUploading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4A7C59)),
                    SizedBox(height: 8),
                    Text('Uploading proof...', style: TextStyle(color: Color(0xFF4A7C59), fontWeight: FontWeight.bold))
                  ],
                ),
              )
            else
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: (widget.isCompleted || widget.isPending) ? null : _uploadProof,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7C59),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  icon: Icon(
                    widget.isCompleted ? Icons.check_circle : (widget.isPending ? Icons.hourglass_empty : Icons.camera_alt),
                    color: (widget.isCompleted || widget.isPending) ? Colors.black54 : Colors.white,
                  ),
                  label: Text(
                    widget.isCompleted 
                      ? TranslationService.tr('completed') 
                      : (widget.isPending ? TranslationService.tr('pending_verification') : TranslationService.tr('take_photo_proof')),
                    style: TextStyle(
                      color: (widget.isCompleted || widget.isPending) ? Colors.black54 : Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
        child: Text(TranslationService.tr('verified'), style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
      );
    } else if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
        child: Text(TranslationService.tr('under_review'), style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
        child: Text(TranslationService.tr('available'), style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
      );
    }
  }
}
