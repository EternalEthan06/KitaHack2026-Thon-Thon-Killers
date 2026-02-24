import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final int sdgScore;
  final int streak;
  final DateTime? lastPostDate;
  final DateTime joinedAt;
  final List<String> badges;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL = '',
    this.sdgScore = 0,
    this.streak = 0,
    this.lastPostDate,
    required this.joinedAt,
    this.badges = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> data, String id) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.tryParse(val.toString());
    }

    return UserModel(
      uid: id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'] ?? '',
      sdgScore: data['sdgScore'] ?? 0,
      streak: data['streak'] ?? 0,
      lastPostDate: parseDate(data['lastPostDate']),
      joinedAt: parseDate(data['joinedAt']) ?? DateTime.now(),
      badges: List<String>.from(data['badges'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'email': email,
        'photoURL': photoURL,
        'sdgScore': sdgScore,
        'streak': streak,
        'lastPostDate': lastPostDate?.millisecondsSinceEpoch,
        'joinedAt': joinedAt.millisecondsSinceEpoch,
        'badges': badges,
      };

  UserModel copyWith({
    String? displayName,
    String? photoURL,
    int? sdgScore,
    int? streak,
    DateTime? lastPostDate,
    List<String>? badges,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoURL: photoURL ?? this.photoURL,
      sdgScore: sdgScore ?? this.sdgScore,
      streak: streak ?? this.streak,
      lastPostDate: lastPostDate ?? this.lastPostDate,
      joinedAt: joinedAt,
      badges: badges ?? this.badges,
    );
  }
}
