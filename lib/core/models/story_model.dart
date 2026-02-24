import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String userId;
  final String userDisplayName;
  final String userPhotoURL;
  final String imageURL;
  final String caption;
  final List<int> sdgGoals;
  final int pointsAwarded;
  final String aiReason;
  final DateTime createdAt;
  final DateTime expiresAt; // 24h after creation
  final List<String> viewedBy;

  StoryModel({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoURL = '',
    required this.imageURL,
    this.caption = '',
    this.sdgGoals = const [],
    this.pointsAwarded = 0,
    this.aiReason = '',
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isViewed => viewedBy.contains(''); // filled client-side

  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    return StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  factory StoryModel.fromMap(Map<dynamic, dynamic> data, String id) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? fallback;
      return fallback;
    }

    return StoryModel(
      id: id,
      userId: data['userId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? '',
      userPhotoURL: data['userPhotoURL'] ?? '',
      imageURL: data['imageURL'] ?? '',
      caption: data['caption'] ?? '',
      sdgGoals: List<int>.from(data['sdgGoals'] ?? []),
      pointsAwarded: data['pointsAwarded'] ?? 0,
      aiReason: data['aiReason'] ?? '',
      createdAt: parseDate(data['createdAt'], DateTime.now()),
      expiresAt: parseDate(
          data['expiresAt'], DateTime.now().add(const Duration(hours: 24))),
      viewedBy: List<String>.from(data['viewedBy'] ?? []),
    );
  }
}
