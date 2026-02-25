import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/ngo_model.dart';
import '../models/story_model.dart';
import '../models/daily_task_model.dart';
import 'auth_service.dart';
import 'gemini_service.dart';

class DatabaseService {
  static final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://kitahack2026-f1f3e-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  static const _uuid = Uuid();

  // ═══════════════════════════════════════════
  // USER
  // ═══════════════════════════════════════════

  static Stream<UserModel?> watchCurrentUser() {
    final uid = AuthService.currentUserId;
    if (uid == null) return const Stream.empty();
    return _db.child(AppConstants.colUsers).child(uid).onValue.map((event) {
      if (event.snapshot.value == null) return null;
      return UserModel.fromMap(
          event.snapshot.value as Map<dynamic, dynamic>, event.snapshot.key!);
    });
  }

  static Future<UserModel?> getUser(String uid) async {
    final snapshot = await _db.child(AppConstants.colUsers).child(uid).get();
    if (!snapshot.exists) return null;
    return UserModel.fromMap(
        snapshot.value as Map<dynamic, dynamic>, snapshot.key!);
  }

  static Future<PostModel?> getPostById(String postId) async {
    final snapshot = await _db.child(AppConstants.colPosts).child(postId).get();
    if (!snapshot.exists) return null;
    return PostModel.fromMap(
        snapshot.value as Map<dynamic, dynamic>, snapshot.key!);
  }

  static Future<void> updateUserScore(String uid, int pointsToAdd) async {
    final ref = _db.child(AppConstants.colUsers).child(uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final currentScore = data['sdgScore'] as int? ?? 0;
      await ref.update({
        'sdgScore': currentScore + pointsToAdd,
        'lastPostDate': ServerValue.timestamp,
      });
    }
  }

  // ═══════════════════════════════════════════
  // POSTS
  // ═══════════════════════════════════════════

  static Future<PostModel> createPostFromBytes({
    required Uint8List imageBytes,
    required String fileName,
    required String caption,
    required PostType type,
    required UserModel author,
  }) async {
    final postId = _uuid.v4();
    final ext = fileName.split('.').last.toLowerCase();

    try {
      final base64Image = 'data:image/$ext;base64,${base64.encode(imageBytes)}';
      final post = PostModel(
        id: postId,
        userId: author.uid,
        userDisplayName: author.displayName,
        userPhotoURL: author.photoURL,
        type: type,
        mediaURL: base64Image,
        mediaType: 'image',
        caption: caption,
        createdAt: DateTime.now(),
        status: type == PostType.sdg ? PostStatus.pending : PostStatus.scored,
      );

      final data = post.toFirestore();
      data['createdAt'] = ServerValue.timestamp;
      await _db.child(AppConstants.colPosts).child(postId).set(data);
      return post;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updatePostScore({
    required String postId,
    required String userId,
    required int score,
    required List<int> sdgGoals,
    required String aiReason,
    required bool isAccepted,
  }) async {
    await _db.child(AppConstants.colPosts).child(postId).update({
      'sdgScore': score,
      'sdgGoals': sdgGoals,
      'aiReason': aiReason,
      'status': isAccepted ? 'scored' : 'rejected',
    });

    if (isAccepted && score > 0) {
      await updateUserScore(userId, score);
      await _updateStreak(userId);
    }
  }

  static Future<void> toggleLike(String postId, String userId) async {
    final ref = _db.child(AppConstants.colPosts).child(postId);
    final snapshot = await ref.get();
    if (!snapshot.exists) return;

    final data = snapshot.value as Map<dynamic, dynamic>;
    final likedBy = data['likedBy'] != null
        ? List<String>.from(data['likedBy'])
        : <String>[];
    final likes = data['likes'] as int? ?? 0;

    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
      await ref.update({'likedBy': likedBy, 'likes': likes - 1});
    } else {
      likedBy.add(userId);
      await ref.update({'likedBy': likedBy, 'likes': likes + 1});
    }
  }

  static Stream<List<PostModel>> watchFeed() {
    print('📡 watchFeed: Listening to ${AppConstants.colPosts}...');
    return _db
        .child(AppConstants.colPosts)
        .onValue
        .map<List<PostModel>>((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;

      final posts = data.entries
          .map((e) => PostModel.fromMap(e.value as Map, e.key))
          .where((p) {
        // Normal posts appear as long as they aren't rejected
        if (p.type == PostType.normal) {
          return p.status != PostStatus.rejected;
        }
        // SDG posts appear ONLY if they are certified (scored)
        return p.status == PostStatus.scored;
      }).toList();

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts.take(50).toList();
    }).handleError((e) {
      print('❌ ERROR in watchFeed: $e');
      return <PostModel>[];
    });
  }

  static Future<void> deletePost(String postId) async {
    await _db.child(AppConstants.colPosts).child(postId).remove();
  }

  static Future<void> updatePostCaption(
      String postId, String newCaption) async {
    await _db
        .child(AppConstants.colPosts)
        .child(postId)
        .update({'caption': newCaption});
  }

  static Stream<List<PostModel>> watchSdgFeed() {
    return _db.child(AppConstants.colPosts).onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final posts = data.entries
          .map((e) => PostModel.fromMap(e.value as Map, e.key))
          // SDG Posts feed ONLY shows certified SDG actions
          .where((p) => p.type == PostType.sdg && p.status == PostStatus.scored)
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts.take(50).toList();
    });
  }

  static Stream<List<PostModel>> watchUserPosts(String userId) {
    return _db.child(AppConstants.colPosts).onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final posts = data.entries
          .map((e) => PostModel.fromMap(e.value as Map, e.key))
          .where((p) => p.userId == userId)
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  // ═══════════════════════════════════════════
  // DAILY TASKS & STREAKS
  // ═══════════════════════════════════════════

  static String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static double calculateMultiplier(int streak) {
    if (streak < 1) return 1.0;
    // user: 15 days = x2. max x5.
    // Formula: (streak / 15) + 1.0
    double mult = 1.0 + (streak / 15.0);
    return mult.clamp(1.0, AppConstants.maxMultiplier);
  }

  static Future<DailyTaskModel?> getDailyTask() async {
    final uid = AuthService.currentUserId;
    if (uid == null) return null;

    final today = _getTodayKey();
    final ref = _db.child('daily_tasks').child(uid).child(today);
    final snap = await ref.get();

    if (snap.exists) {
      return DailyTaskModel.fromMap(snap.value as Map, snap.key!);
    }

    // Generate new task using AI
    print('🤖 AI: Generating new daily task for $today...');
    final taskData = await GeminiService.instance.generateDailyTask();
    final task = DailyTaskModel(
      id: today,
      title: taskData['title'] ?? 'Eco Hero',
      description: taskData['description'] ?? 'Do something good today!',
      sdgGoals: List<int>.from(taskData['sdgGoals'] ?? []),
      points: taskData['points'] ?? 20,
      difficulty: taskData['difficulty'] ?? 'Easy',
      date: DateTime.now(),
    );

    await ref.set(task.toMap());
    return task;
  }

  static Future<DailyTaskModel?> regenerateDailyTask() async {
    final uid = AuthService.currentUserId;
    if (uid == null) return null;

    final today = _getTodayKey();
    final ref = _db.child('daily_tasks').child(uid).child(today);

    print('🤖 AI: Regenerating new daily task for $today...');
    final taskData = await GeminiService.instance.generateDailyTask();
    final task = DailyTaskModel(
      id: today,
      title: taskData['title'] ?? 'Eco Hero',
      description: taskData['description'] ?? 'Do something good today!',
      sdgGoals: List<int>.from(taskData['sdgGoals'] ?? []),
      points: taskData['points'] ?? 20,
      difficulty: taskData['difficulty'] ?? 'Easy',
      date: DateTime.now(),
    );

    await ref.set(task.toMap());
    return task;
  }

  static Future<void> completeDailyTask(DailyTaskModel task) async {
    final uid = AuthService.currentUserId;
    if (uid == null) return;

    final user = await getUser(uid);
    if (user == null) return;

    final multiplier = calculateMultiplier(user.streak);
    final finalPoints = (task.points * multiplier).round();

    await _db.child('daily_tasks').child(uid).child(task.id).update({
      'isCompleted': true,
    });

    // Update score and streak timestamp
    await _db.child(AppConstants.colUsers).child(uid).update({
      'sdgScore': user.sdgScore + finalPoints,
      'lastPostDate': ServerValue.timestamp,
    });

    print('✅ Task completed! ${task.points} x $multiplier = $finalPoints pts');
  }

  static Future<void> _updateStreak(String userId) async {
    final snap = await _db.child(AppConstants.colUsers).child(userId).get();
    if (!snap.exists) return;
    final user = UserModel.fromMap(snap.value as Map, snap.key!);
    final now = DateTime.now();
    final lastPost = user.lastPostDate;

    int newStreak = user.streak;
    if (lastPost == null) {
      newStreak = 1;
    } else {
      final lastDate = lastPost;
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;

      if (diff == 1) {
        newStreak += 1;
      } else if (diff > 1) {
        newStreak = 1;
      }
    }

    await _db
        .child(AppConstants.colUsers)
        .child(userId)
        .update({'streak': newStreak});
  }

  // ═══════════════════════════════════════════
  // REWARDS
  // ═══════════════════════════════════════════

  static Stream<List<RewardModel>> watchRewards() {
    return _db.child(AppConstants.colRewards).onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries
          .map((e) => RewardModel.fromMap(e.value as Map, e.key))
          .where((r) => r.available)
          .toList();
    });
  }

  static Future<bool> redeemReward(
      String userId, RewardModel reward, int userScore) async {
    if (userScore < reward.costInScore) return false;
    await _db
        .child(AppConstants.colUsers)
        .child(userId)
        .update({'sdgScore': userScore - reward.costInScore});
    await _db
        .child(AppConstants.colUsers)
        .child(userId)
        .child('redeemed')
        .push()
        .set({
      'rewardId': reward.id,
      'title': reward.title,
      'costInScore': reward.costInScore,
      'status': 'pending',
      'redeemedAt': ServerValue.timestamp,
    });
    return true;
  }

  static Stream<List<Map<String, dynamic>>> watchUserRedemptions(
      String userId) {
    return _db
        .child(AppConstants.colUsers)
        .child(userId)
        .child('redeemed')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries
          .map((e) =>
              {'id': e.key, ...Map<String, dynamic>.from(e.value as Map)})
          .toList();
    });
  }

  // ═══════════════════════════════════════════
  // VOLUNTEER
  // ═══════════════════════════════════════════

  static Stream<List<VolunteerEventModel>> watchVolunteerEvents() {
    return _db.child(AppConstants.colVolunteerEvents).onValue.map((event) {
      if (event.snapshot.value == null) return [];
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((e) {
          return VolunteerEventModel.fromMap(e.value as Map, e.key.toString());
        }).toList();
      } catch (e) {
        print('❌ ERROR parsing volunteer events: $e');
        return [];
      }
    });
  }

  static Future<void> registerForEvent(
      String eventId, String userId, VolunteerEventModel event) async {
    await _db
        .child(AppConstants.colVolunteerEvents)
        .child(eventId)
        .child('registeredUsers')
        .push()
        .set(userId);
    await _db
        .child(AppConstants.colUsers)
        .child(userId)
        .child('volunteer_registrations')
        .child(eventId)
        .set({
      'eventId': eventId,
      'eventTitle': event.title,
      'ngoName': event.ngoName,
      'status': 'pending_approval',
      'registeredAt': ServerValue.timestamp,
      'sdgPointsReward': event.sdgPointsReward,
    });
  }

  static Stream<List<Map<String, dynamic>>> watchUserRegistrations(
      String userId) {
    return _db
        .child(AppConstants.colUsers)
        .child(userId)
        .child('volunteer_registrations')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries
          .map((e) =>
              {'id': e.key, ...Map<String, dynamic>.from(e.value as Map)})
          .toList();
    });
  }

  static Stream<List<Map<String, dynamic>>> watchTopContributors() {
    return _db
        .child(AppConstants.colUsers)
        .orderByChild('sdgScore')
        .limitToLast(10)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final list = data.entries
          .map((e) =>
              {'id': e.key, ...Map<String, dynamic>.from(e.value as Map)})
          .toList();
      list.sort((a, b) => (b['sdgScore'] ?? 0).compareTo(a['sdgScore'] ?? 0));
      return list;
    });
  }

  // ═══════════════════════════════════════════
  // NGO & DONATE
  // ═══════════════════════════════════════════

  static Stream<List<NGOModel>> watchNGOs() {
    return _db.child(AppConstants.colNGOs).onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries
          .map((e) => NGOModel.fromMap(e.value as Map, e.key))
          .toList();
    });
  }

  static Stream<List<MarketplaceProduct>> watchProducts() {
    return _db.child(AppConstants.colProducts).onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries
          .map((e) => MarketplaceProduct.fromMap(e.value as Map, e.key))
          .where((p) => p.stock > 0)
          .toList();
    });
  }

  static Stream<List<DonationProject>> watchDonationProjects() {
    return _db.child('donation_projects').onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries
          .map((e) => DonationProject.fromMap(e.value as Map, e.key))
          .where((p) => p.active)
          .toList();
    });
  }

  static Future<void> donateMoneyToProject(
      {required String userId,
      required DonationProject project,
      required double amount,
      required String message}) async {
    // 1. Record Donation
    await _db.child(AppConstants.colDonations).push().set({
      'userId': userId,
      'projectId': project.id,
      'type': 'money',
      'amount': amount,
      'createdAt': ServerValue.timestamp,
    });

    // 2. Update Project Total
    final projectRef = _db.child('donation_projects').child(project.id);
    final projectSnap = await projectRef.child('raisedAmount').get();
    await projectRef
        .update({'raisedAmount': (projectSnap.value as num? ?? 0) + amount});

    // 3. Award Bonus Points (RM1 = 20 pts, capped at 200)
    final bonusPoints = (amount * 20).round().clamp(20, 200);
    await updateUserScore(userId, bonusPoints);
    print('🎁 DONATION: Awarded $bonusPoints pts for RM$amount donation');
  }

  static Stream<List<NGOModel>> watchTopNGOs() =>
      watchNGOs().map((list) => list.take(10).toList());

  // ═══════════════════════════════════════════
  // STORIES
  // ═══════════════════════════════════════════

  static Stream<List<StoryModel>> watchStories() {
    return _db.child('stories').onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final stories = data.entries
          .map((e) => StoryModel.fromMap(e.value as Map, e.key))
          .where((s) => !s.isExpired)
          .toList();
      stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return stories;
    });
  }

  static Future<void> createStory(
      {required String userId,
      required String userDisplayName,
      required String userPhotoURL,
      required Uint8List imageBytes,
      required String caption,
      required List<int> sdgGoals,
      required int pointsAwarded,
      required String aiReason,
      Function(String)? onStatusChanged}) async {
    onStatusChanged?.call('📂 Processing photo...');
    final b64 = 'data:image/jpeg;base64,${base64.encode(imageBytes)}';
    final id = _uuid.v4();
    await _db.child('stories').child(id).set({
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoURL': userPhotoURL,
      'imageURL': b64,
      'caption': caption,
      'sdgGoals': sdgGoals,
      'pointsAwarded': pointsAwarded,
      'aiReason': aiReason,
      'createdAt': ServerValue.timestamp,
      'expiresAt':
          DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch,
      'viewedBy': [],
    });
    if (pointsAwarded > 0) await updateUserScore(userId, pointsAwarded);
  }

  static Future<void> markStoryViewed(String storyId, String userId) async {
    final ref = _db.child('stories').child(storyId).child('viewedBy');
    final snap = await ref.get();
    final list =
        snap.value != null ? List<String>.from(snap.value as List) : <String>[];
    if (!list.contains(userId)) {
      list.add(userId);
      await ref.set(list);
    }
  }

  static Future<void> deleteStory(String storyId) async {
    await _db.child('stories').child(storyId).remove();
  }

  static Future<String> uploadTempImage(Uint8List bytes) async {
    final id = _uuid.v4();
    await _db.child('pending_uploads').child(id).set({
      'userId': AuthService.currentUserId,
      'base64': 'data:image/jpeg;base64,${base64.encode(bytes)}',
      'createdAt': ServerValue.timestamp
    });
    return id;
  }

  static Future<Uint8List?> getTempImage(String id) async {
    final snap = await _db.child('pending_uploads').child(id).get();
    if (!snap.exists) return null;
    final b64 = (snap.value as Map)['base64'] as String?;
    return b64 != null ? base64Decode(b64.split(',').last) : null;
  }

  static Future<void> deleteTempImage(String id) async {
    await _db.child('pending_uploads').child(id).remove();
  }
}
