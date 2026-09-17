import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_service.dart';

class TaskSubmissionItem {
  final String id;
  final String taskId;
  final String taskTitle;
  final String taskDescription;
  final String crop;
  final int coinsReward;
  final String farmerId;
  final String farmerName;
  final String farmerEmail;
  final String farmerState;
  final String farmerDistrict;
  final String mediaType; // 'photo' or 'video'
  final String? imageBase64;
  final String? localMediaPath;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime submittedAt;
  final String? verifiedBy; // 'Admin' or 'AI (Gemini Vision)'
  final DateTime? verifiedAt;
  final int? aiConfidence;
  final String? aiReason;
  final String? rejectReason;

  TaskSubmissionItem({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.taskDescription,
    required this.crop,
    required this.coinsReward,
    required this.farmerId,
    required this.farmerName,
    required this.farmerEmail,
    required this.farmerState,
    required this.farmerDistrict,
    this.mediaType = 'photo',
    this.imageBase64,
    this.localMediaPath,
    required this.status,
    required this.submittedAt,
    this.verifiedBy,
    this.verifiedAt,
    this.aiConfidence,
    this.aiReason,
    this.rejectReason,
  });

  factory TaskSubmissionItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskSubmissionItem(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      taskTitle: data['taskTitle'] ?? '',
      taskDescription: data['taskDescription'] ?? '',
      crop: data['crop'] ?? '',
      coinsReward: (data['coinsReward'] as num?)?.toInt() ?? 0,
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? 'Farmer',
      farmerEmail: data['farmerEmail'] ?? '',
      farmerState: data['farmerState'] ?? '',
      farmerDistrict: data['farmerDistrict'] ?? '',
      mediaType: data['mediaType'] ?? 'photo',
      imageBase64: data['imageBase64'],
      localMediaPath: data['localMediaPath'],
      status: data['status'] ?? 'pending',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verifiedBy: data['verifiedBy'],
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      aiConfidence: (data['aiConfidence'] as num?)?.toInt(),
      aiReason: data['aiReason'],
      rejectReason: data['rejectReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'taskTitle': taskTitle,
      'taskDescription': taskDescription,
      'crop': crop,
      'coinsReward': coinsReward,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerEmail': farmerEmail,
      'farmerState': farmerState,
      'farmerDistrict': farmerDistrict,
      'mediaType': mediaType,
      'imageBase64': imageBase64,
      'localMediaPath': localMediaPath,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'aiConfidence': aiConfidence,
      'aiReason': aiReason,
      'rejectReason': rejectReason,
    };
  }
}

class TaskVerificationService {
  static final TaskVerificationService _instance = TaskVerificationService._internal();
  factory TaskVerificationService() => _instance;
  TaskVerificationService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Submit task proof from Farmer side
  Future<String> submitTaskProof({
    required String taskId,
    required String taskTitle,
    required String taskDescription,
    required String crop,
    required int coinsReward,
    required String farmerId,
    required String farmerName,
    required String farmerEmail,
    required String farmerState,
    required String farmerDistrict,
    required String filePath,
    required bool isVideo,
  }) async {
    try {
      String? base64Img;
      if (!isVideo && File(filePath).existsSync()) {
        final bytes = await File(filePath).readAsBytes();
        base64Img = base64Encode(bytes);
      }

      final docRef = await _db.collection('task_submissions').add({
        'taskId': taskId,
        'taskTitle': taskTitle,
        'taskDescription': taskDescription,
        'crop': crop,
        'coinsReward': coinsReward,
        'farmerId': farmerId,
        'farmerName': farmerName,
        'farmerEmail': farmerEmail,
        'farmerState': farmerState,
        'farmerDistrict': farmerDistrict,
        'mediaType': isVideo ? 'video' : 'photo',
        'imageBase64': base64Img,
        'localMediaPath': filePath,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Also register submission in farmer doc so they see pending status
      await _db.collection('farmers').doc(farmerId).update({
        'pendingTasks': FieldValue.arrayUnion([taskId]),
      }).catchError((_) {});

      return docRef.id;
    } catch (e) {
      if (kDebugMode) print('submitTaskProof error: $e');
      rethrow;
    }
  }

  /// Approve a task submission (by Admin or AI) and credit Green Coins to Farmer
  Future<void> approveSubmission({
    required String submissionId,
    required String farmerId,
    required String taskId,
    required int coinsReward,
    required String taskTitle,
    String verifiedBy = 'Admin',
    int? aiConfidence,
    String? aiReason,
  }) async {
    try {
      final batch = _db.batch();

      // 1. Update task submission document
      final subRef = _db.collection('task_submissions').doc(submissionId);
      batch.update(subRef, {
        'status': 'approved',
        'verifiedBy': verifiedBy,
        'verifiedAt': FieldValue.serverTimestamp(),
        'aiConfidence': aiConfidence,
        'aiReason': aiReason,
      });

      // 2. Credit Green Coins to farmer
      final farmerRef = _db.collection('farmers').doc(farmerId);
      batch.update(farmerRef, {
        'greenCoins': FieldValue.increment(coinsReward),
        'completedTasks': FieldValue.arrayUnion([taskId]),
        'pendingTasks': FieldValue.arrayRemove([taskId]),
        'lastTaskRewardDate': DateTime.now().toIso8601String().substring(0, 10),
      });

      // 3. Create Farmer Notification
      final notifRef = _db.collection('farmers').doc(farmerId).collection('notifications').doc();
      batch.set(notifRef, {
        'title': '🌿 कार्य स्वीकृत! +$coinsReward Green Coins',
        'body': 'आपके द्वारा "$taskTitle" का सत्यापन $verifiedBy द्वारा सफल रहा। Green Coins आपके खाते में जोड़ दिए गए हैं!',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'task_approved',
      });

      // 4. Create Transaction Ledger Entry
      final transRef = _db.collection('farmers').doc(farmerId).collection('transactions').doc();
      batch.set(transRef, {
        'name': 'कार्य सत्यापन: $taskTitle ($verifiedBy)',
        'amount': '+$coinsReward',
        'credit': true,
        'dt': DateTime.now().toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      if (kDebugMode) print('approveSubmission error: $e');
      rethrow;
    }
  }

  /// Reject a task submission (by Admin or AI)
  Future<void> rejectSubmission({
    required String submissionId,
    required String farmerId,
    required String taskId,
    required String taskTitle,
    required String reason,
    String rejectedBy = 'Admin',
  }) async {
    try {
      final batch = _db.batch();

      // 1. Update submission status
      final subRef = _db.collection('task_submissions').doc(submissionId);
      batch.update(subRef, {
        'status': 'rejected',
        'verifiedBy': rejectedBy,
        'verifiedAt': FieldValue.serverTimestamp(),
        'rejectReason': reason,
      });

      // 2. Remove from pending in farmer doc
      final farmerRef = _db.collection('farmers').doc(farmerId);
      batch.update(farmerRef, {
        'pendingTasks': FieldValue.arrayRemove([taskId]),
      });

      // 3. Send Notification to Farmer to retry
      final notifRef = _db.collection('farmers').doc(farmerId).collection('notifications').doc();
      batch.set(notifRef, {
        'title': '⚠️ कार्य सत्यापन अस्वीकृत (Re-upload Needed)',
        'body': '"$taskTitle": $reason कृपया सही फोटो/वीडियो के साथ पुनः प्रयास करें।',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'task_rejected',
      });

      await batch.commit();
    } catch (e) {
      if (kDebugMode) print('rejectSubmission error: $e');
      rethrow;
    }
  }

  /// Verify a single submission using Gemini Vision AI
  Future<AiTaskVerificationResult> verifySingleSubmissionWithAI(TaskSubmissionItem item) async {
    final ai = AiService();
    final result = await ai.verifyTaskProofWithGemini(
      base64Image: item.imageBase64,
      imagePath: item.localMediaPath,
      taskTitle: item.taskTitle,
      taskDescription: item.taskDescription,
      crop: item.crop,
    );

    if (result.isApproved) {
      await approveSubmission(
        submissionId: item.id,
        farmerId: item.farmerId,
        taskId: item.taskId,
        coinsReward: item.coinsReward,
        taskTitle: item.taskTitle,
        verifiedBy: 'AI (Gemini Vision - ${result.confidence}% Match)',
        aiConfidence: result.confidence,
        aiReason: '${result.reasonHindi} (${result.reasonEnglish})',
      );
    } else {
      await rejectSubmission(
        submissionId: item.id,
        farmerId: item.farmerId,
        taskId: item.taskId,
        taskTitle: item.taskTitle,
        reason: result.reasonHindi,
        rejectedBy: 'AI (Gemini Vision - ${result.confidence}% Match)',
      );
    }

    return result;
  }

  /// Auto-verify all pending submissions with AI when Admin is busy
  Future<Map<String, int>> batchVerifyAllPendingWithAI() async {
    int approvedCount = 0;
    int rejectedCount = 0;

    final snapshot = await _db
        .collection('task_submissions')
        .where('status', isEqualTo: 'pending')
        .get();

    for (final doc in snapshot.docs) {
      try {
        final item = TaskSubmissionItem.fromFirestore(doc);
        final result = await verifySingleSubmissionWithAI(item);
        if (result.isApproved) {
          approvedCount++;
        } else {
          rejectedCount++;
        }
      } catch (e) {
        if (kDebugMode) print('Error verifying doc ${doc.id}: $e');
      }
    }

    return {
      'total': snapshot.docs.length,
      'approved': approvedCount,
      'rejected': rejectedCount,
    };
  }
}
