import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { sdg, normal }

enum PostStatus { pending, scored, rejected }

class PostModel {
  final String id;
  final String userId;
  final String userDisplayName;
  final String userPhotoURL;
  final PostType type;
  final String mediaURL;
  final List<String> imageURLs; // up to 5 images
  final String mediaType;
  final String caption;
  final List<int> sdgGoals;
  final int sdgScore;
  final String aiReason;
  final int likes;
  final List<String> likedBy;
  final DateTime createdAt;
  final PostStatus status;

  PostModel({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoURL = '',
    required this.type,
    required this.mediaURL,
    this.imageURLs = const [],
    this.mediaType = 'image',
    required this.caption,
    this.sdgGoals = const [],
    this.sdgScore = 0,
    this.aiReason = '',
    this.likes = 0,
    this.likedBy = const [],
    required this.createdAt,
    this.status = PostStatus.pending,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    return PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  factory PostModel.fromMap(Map<dynamic, dynamic> data, String id) {
    final mainUrl = data['mediaURL'] as String? ?? '';
    final extras = List<String>.from(data['imageURLs'] ?? []);
    final allImages = <String>[
      if (mainUrl.isNotEmpty) mainUrl,
      ...extras.where((u) => u != mainUrl)
    ];

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PostModel(
      id: id,
      userId: data['userId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? '',
      userPhotoURL: data['userPhotoURL'] ?? '',
      type: data['type'] == 'sdg' ? PostType.sdg : PostType.normal,
      mediaURL: mainUrl,
      imageURLs: allImages,
      mediaType: data['mediaType'] ?? 'image',
      caption: data['caption'] ?? '',
      sdgGoals: List<int>.from(data['sdgGoals'] ?? []),
      sdgScore: data['sdgScore'] ?? 0,
      aiReason: data['aiReason'] ?? '',
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: parseDate(data['createdAt']),
      status: PostStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'pending'),
        orElse: () => PostStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'userDisplayName': userDisplayName,
        'userPhotoURL': userPhotoURL,
        'type': type.name,
        'mediaURL': mediaURL,
        'imageURLs': imageURLs,
        'mediaType': mediaType,
        'caption': caption,
        'sdgGoals': sdgGoals,
        'sdgScore': sdgScore,
        'aiReason': aiReason,
        'likes': likes,
        'likedBy': likedBy,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'status': status.name,
      };
}
