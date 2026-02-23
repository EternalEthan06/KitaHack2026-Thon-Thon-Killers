import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/ngo_model.dart';
import '../models/story_model.dart';
import 'auth_service.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  // ═══════════════════════════════════════════
  // USER
  // ═══════════════════════════════════════════

  static Stream<UserModel?> watchCurrentUser() {
    final uid = AuthService.currentUserId;
    if (uid == null) return const Stream.empty();
    return _db
        .collection(AppConstants.colUsers)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  static Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.colUsers).doc(uid).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  static Future<PostModel?> getPostById(String postId) async {
    final doc = await _db.collection(AppConstants.colPosts).doc(postId).get();
    return doc.exists ? PostModel.fromFirestore(doc) : null;
  }

  static Future<void> updateUserScore(String uid, int pointsToAdd) async {
    await _db.collection(AppConstants.colUsers).doc(uid).update({
      'sdgScore': FieldValue.increment(pointsToAdd),
      'lastPostDate': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════
  // POSTS
  // ═══════════════════════════════════════════

  /// Upload image bytes and create post document (web-compatible)
  static Future<PostModel> createPostFromBytes({
    required Uint8List imageBytes,
    required String fileName,
    required String caption,
    required PostType type,
    required UserModel author,
  }) async {
    final postId = _uuid.v4();
    final ext = fileName.split('.').last.toLowerCase();
    final storagePath = 'posts/$postId.$ext';

    // Upload to Firebase Storage
    final ref = _storage.ref(storagePath);
    final metadata = SettableMetadata(contentType: 'image/$ext');
    await ref.putData(imageBytes, metadata);
    final mediaURL = await ref.getDownloadURL();

    // Create Firestore document
    final post = PostModel(
      id: postId,
      userId: author.uid,
      userDisplayName: author.displayName,
      userPhotoURL: author.photoURL,
      type: type,
      mediaURL: mediaURL,
      mediaType: 'image',
      caption: caption,
      createdAt: DateTime.now(),
      status: type == PostType.sdg ? PostStatus.pending : PostStatus.scored,
    );

    await _db
        .collection(AppConstants.colPosts)
        .doc(postId)
        .set(post.toFirestore());

    return post;
  }

  /// Update post with Gemini AI score result
  static Future<void> updatePostScore({
    required String postId,
    required String userId,
    required int score,
    required List<int> sdgGoals,
    required String aiReason,
    required bool isAccepted,
  }) async {
    await _db.collection(AppConstants.colPosts).doc(postId).update({
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

  /// Toggle like on a post
  static Future<void> toggleLike(String postId, String userId) async {
    final ref = _db.collection(AppConstants.colPosts).doc(postId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final likedBy = List<String>.from(doc['likedBy'] ?? []);
    if (likedBy.contains(userId)) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likes': FieldValue.increment(1),
      });
    }
  }

  /// Feed: all posts sorted by newest (client-side filter to avoid composite index)
  static Stream<List<PostModel>> watchFeed() {
    return _db
        .collection(AppConstants.colPosts)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map(PostModel.fromFirestore)
            .where((p) => p.status != PostStatus.rejected)
            .toList());
  }

  /// SDG-only feed — no orderBy to avoid composite index requirement
  static Stream<List<PostModel>> watchSdgFeed() {
    return _db
        .collection(AppConstants.colPosts)
        .where('type', isEqualTo: 'sdg')
        .limit(50)
        .snapshots()
        .map((snap) {
      final posts = snap.docs
          .map(PostModel.fromFirestore)
          .where((p) => p.status == PostStatus.scored)
          .toList();
      // Sort newest first client-side
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  /// User's own posts
  static Stream<List<PostModel>> watchUserPosts(String userId) {
    return _db
        .collection(AppConstants.colPosts)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PostModel.fromFirestore).toList());
  }

  // ═══════════════════════════════════════════
  // STREAKS
  // ═══════════════════════════════════════════

  static Future<void> _updateStreak(String userId) async {
    final userDoc =
        await _db.collection(AppConstants.colUsers).doc(userId).get();
    if (!userDoc.exists) return;

    final user = UserModel.fromFirestore(userDoc);
    final now = DateTime.now();
    final lastPost = user.lastPostDate;

    int newStreak = user.streak;
    if (lastPost == null) {
      newStreak = 1;
    } else {
      final daysSinceLast = now.difference(lastPost).inDays;
      if (daysSinceLast == 0) {
        // Same day, no change
      } else if (daysSinceLast == 1) {
        newStreak += 1; // Consecutive day!
      } else {
        newStreak = 1; // Reset streak
      }
    }

    await _db.collection(AppConstants.colUsers).doc(userId).update({
      'streak': newStreak,
    });
  }

  // ═══════════════════════════════════════════
  // REWARDS
  // ═══════════════════════════════════════════

  static Stream<List<RewardModel>> watchRewards() {
    return _db
        .collection(AppConstants.colRewards)
        .where('available', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(RewardModel.fromFirestore).toList());
  }

  static Future<bool> redeemReward(
      String userId, RewardModel reward, int userScore) async {
    if (userScore < reward.costInScore) return false;

    final batch = _db.batch();
    batch.update(_db.collection(AppConstants.colUsers).doc(userId), {
      'sdgScore': FieldValue.increment(-reward.costInScore),
    });
    // Store full reward details for history display
    batch.set(
      _db
          .collection(AppConstants.colUsers)
          .doc(userId)
          .collection('redeemed')
          .doc(),
      {
        'rewardId': reward.id,
        'title': reward.title,
        'description': reward.description,
        'type': reward.type,
        'costInScore': reward.costInScore,
        'imageURL': reward.imageURL,
        'status': 'pending', // pending → delivered
        'redeemedAt': FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();
    return true;
  }

  static Stream<List<Map<String, dynamic>>> watchUserRedemptions(
      String userId) {
    return _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('redeemed')
        .orderBy('redeemedAt', descending: true)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ═══════════════════════════════════════════
  // VOLUNTEER EVENTS
  // ═══════════════════════════════════════════

  static Stream<List<VolunteerEventModel>> watchVolunteerEvents() {
    return _db
        .collection(AppConstants.colVolunteerEvents)
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map(VolunteerEventModel.fromFirestore).toList());
  }

  /// Register for event — records as 'pending_approval', NO points yet
  static Future<void> registerForEvent(
      String eventId, String userId, VolunteerEventModel event) async {
    final batch = _db.batch();
    // Add userId to event's registeredUsers list
    batch.update(_db.collection(AppConstants.colVolunteerEvents).doc(eventId), {
      'registeredUsers': FieldValue.arrayUnion([userId]),
    });
    // Record pending registration in user's sub-collection
    batch.set(
      _db
          .collection(AppConstants.colUsers)
          .doc(userId)
          .collection('volunteer_registrations')
          .doc(eventId),
      {
        'eventId': eventId,
        'eventTitle': event.title,
        'ngoName': event.ngoName,
        'address': event.address,
        'date': Timestamp.fromDate(event.date),
        'sdgGoals': event.sdgGoals,
        'sdgPointsReward': event.sdgPointsReward,
        'imageURL': '',
        'status': 'pending_approval', // → confirmed → completed
        'registeredAt': FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();
  }

  /// Stream of the current user's volunteer registrations (My Calendar)
  static Stream<List<Map<String, dynamic>>> watchUserRegistrations(
      String userId) {
    return _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('volunteer_registrations')
        .orderBy('date')
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Top 10 contributors this week by SDG score (leaderboard)
  static Stream<List<Map<String, dynamic>>> watchTopContributors() {
    return _db
        .collection(AppConstants.colUsers)
        .orderBy('sdgScore', descending: true)
        .limit(10)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ═══════════════════════════════════════════
  // NGO & MARKETPLACE
  // ═══════════════════════════════════════════

  static Stream<List<NGOModel>> watchNGOs() {
    return _db
        .collection(AppConstants.colNGOs)
        .snapshots()
        .map((snap) => snap.docs.map(NGOModel.fromFirestore).toList());
  }

  static Stream<List<MarketplaceProduct>> watchProducts() {
    return _db
        .collection(AppConstants.colProducts)
        .where('stock', isGreaterThan: 0)
        .snapshots()
        .map(
            (snap) => snap.docs.map(MarketplaceProduct.fromFirestore).toList());
  }

  // ═══════════════════════════════════════════
  // DONATIONS
  // ═══════════════════════════════════════════

  static Stream<List<DonationProject>> watchDonationProjects() {
    return _db
        .collection('donation_projects')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final projects = snap.docs.map(DonationProject.fromFirestore).toList();
      projects.sort((a, b) => a.ngoName.compareTo(b.ngoName));
      return projects;
    });
  }

  /// Donate money (RM) to a project — records donation and updates progress
  static Future<void> donateMoneyToProject({
    required String userId,
    required DonationProject project,
    required double amount,
    required String message,
  }) async {
    final batch = _db.batch();
    // Record donation
    final donRef = _db.collection(AppConstants.colDonations).doc();
    batch.set(donRef, {
      'userId': userId,
      'projectId': project.id,
      'ngoId': project.ngoId,
      'ngoName': project.ngoName,
      'projectTitle': project.title,
      'type': 'money',
      'amount': amount,
      'message': message,
      'sdgGoalsSupported': project.sdgGoals,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Update project raised amount
    batch.update(_db.collection('donation_projects').doc(project.id), {
      'raisedAmount': FieldValue.increment(amount),
    });
    await batch.commit();
    // Bonus SDG points (10 pts per RM, capped at 100)
    await updateUserScore(userId, (amount * 10).round().clamp(10, 100));
  }

  /// Donate SDG points to a project
  static Future<bool> donatePointsToProject({
    required String userId,
    required DonationProject project,
    required int points,
    required int userCurrentScore,
  }) async {
    if (userCurrentScore < points) return false;
    final batch = _db.batch();
    final donRef = _db.collection(AppConstants.colDonations).doc();
    batch.set(donRef, {
      'userId': userId,
      'projectId': project.id,
      'ngoId': project.ngoId,
      'ngoName': project.ngoName,
      'projectTitle': project.title,
      'type': 'points',
      'points': points,
      'sdgGoalsSupported': project.sdgGoals,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Update project raised points
    batch.update(_db.collection('donation_projects').doc(project.id), {
      'raisedPoints': FieldValue.increment(points),
    });
    // Deduct from user score
    batch.update(_db.collection(AppConstants.colUsers).doc(userId), {
      'sdgScore': FieldValue.increment(-points),
    });
    await batch.commit();
    return true;
  }

  /// Legacy: generic donation to an NGO
  static Future<void> makeDonation({
    required String userId,
    required String ngoId,
    required double amount,
    required String message,
    required List<int> sdgGoals,
  }) async {
    await _db.collection(AppConstants.colDonations).add({
      'userId': userId,
      'ngoId': ngoId,
      'amount': amount,
      'message': message,
      'sdgGoalsSupported': sdgGoals,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await updateUserScore(userId, (amount * 0.1).round().clamp(5, 50));
  }

  // ═══════════════════════════════════════════
  // STORIES
  // ═══════════════════════════════════════════

  static Stream<List<StoryModel>> watchStories() {
    final cutoff = Timestamp.fromDate(DateTime.now().toUtc());
    return _db
        .collection('stories')
        .where('expiresAt', isGreaterThan: cutoff)
        .limit(30)
        .snapshots()
        .map((snap) {
      final stories = snap.docs.map(StoryModel.fromFirestore).toList();
      stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return stories;
    });
  }

  static Future<void> createStory({
    required String userId,
    required String userDisplayName,
    required String userPhotoURL,
    required Uint8List imageBytes,
    required String caption,
    required List<int> sdgGoals,
    required int pointsAwarded,
    required String aiReason,
  }) async {
    // Upload image to Firebase Storage
    final path = 'stories/$userId/${_uuid.v4()}.jpg';
    final ref = _storage.ref().child(path);
    await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
    final imageURL = await ref.getDownloadURL();

    final now = DateTime.now().toUtc();
    await _db.collection('stories').add({
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoURL': userPhotoURL,
      'imageURL': imageURL,
      'caption': caption,
      'sdgGoals': sdgGoals,
      'pointsAwarded': pointsAwarded,
      'aiReason': aiReason,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 24))),
      'viewedBy': [],
    });
    if (pointsAwarded > 0) await updateUserScore(userId, pointsAwarded);
  }

  static Future<void> markStoryViewed(String storyId, String userId) async {
    await _db.collection('stories').doc(storyId).update({
      'viewedBy': FieldValue.arrayUnion([userId]),
    });
  }

  // ═══════════════════════════════════════════
  // NGO LEADERBOARD
  // ═══════════════════════════════════════════

  static Stream<List<NGOModel>> watchTopNGOs() {
    return _db
        .collection(AppConstants.colNGOs)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map(NGOModel.fromFirestore).toList());
  }
}
