import re

with open(r'd:\integrated_agri_hub\lib\screens\farmer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

replacement = """  Widget _buildTaskCard(TaskItem task) {
    Color statusColor = Colors.grey;
    String statusText = 'Not Started';
    IconData statusIcon = Icons.radio_button_unchecked;

    if (task.status == 'Pending Verification' || task.status == 'pending') {
      statusColor = Colors.orange;
      statusText = 'Under Admin Review';
      statusIcon = Icons.hourglass_empty;
    } else if (task.status == 'Approved' || task.status == 'approved') {
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
          color: (task.status == 'Approved' || task.status == 'approved') 
              ? _kGreen.withOpacity(0.3) 
              : ((task.status == 'Pending Verification' || task.status == 'pending') ? Colors.orange.withOpacity(0.3) : Colors.transparent),
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
                    const Text('🌿', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '+\${task.reward} Coins',
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
                            content: Text('Photo captured! Submitting to Admin...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        
                        // Submit to Firebase
                        final farmerUid = FirebaseAuth.instance.currentUser?.uid;
                        if (farmerUid != null) {
                            final bytes = await photo.readAsBytes();
                            final base64Image = base64Encode(bytes);
                            await FirebaseFirestore.instance.collection('task_submissions').add({
                                'taskId': task.id,
                                'taskTitle': task.title,
                                'taskDescription': task.description,
                                'crop': widget.cropData?.cropName ?? 'General',
                                'coinsReward': task.reward,
                                'farmerId': farmerUid,
                                'farmerName': widget.farmerName,
                                'imageBase64': base64Image,
                                'status': 'pending',
                                'submittedAt': FieldValue.serverTimestamp(),
                            });
                            
                            // Also record it in user's pending tasks array
                            await FirebaseFirestore.instance.collection('users').doc(farmerUid).update({
                                'pendingTasks': FieldValue.arrayUnion([task.id]),
                            });
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: \$e'),
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
              else if (task.status == 'Pending Verification' || task.status == 'pending')
                const Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)),
                        SizedBox(width: 8),
                        Text('Admin Verifying...', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
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
"""

content = re.sub(r'  Widget _buildTaskCard\(TaskItem task\).*?    \);\n  }', replacement, content, flags=re.DOTALL)

with open(r'd:\integrated_agri_hub\lib\screens\farmer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed base64 upload")
