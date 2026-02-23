import 'package:cloud_firestore/cloud_firestore.dart';

class NGOModel {
  final String id;
  final String name;
  final String description;
  final String logoURL;
  final List<int> sdgGoals;
  final String contactEmail;
  final GeoPoint? location;
  final String address;

  NGOModel({
    required this.id,
    required this.name,
    required this.description,
    this.logoURL = '',
    this.sdgGoals = const [],
    this.contactEmail = '',
    this.location,
    this.address = '',
  });

  factory NGOModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NGOModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      logoURL: data['logoURL'] ?? '',
      sdgGoals: List<int>.from(data['sdgGoals'] ?? []),
      contactEmail: data['contactEmail'] ?? '',
      location: data['location'] as GeoPoint?,
      address: data['address'] ?? '',
    );
  }
}

class VolunteerEventModel {
  final String id;
  final String ngoId;
  final String ngoName;
  final String title;
  final String description;
  final GeoPoint? location;
  final String address;
  final DateTime date;
  final List<int> sdgGoals;
  final int sdgPointsReward;
  final List<String> registeredUsers;
  final String imageURL;

  VolunteerEventModel({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.title,
    required this.description,
    this.location,
    this.address = '',
    required this.date,
    this.sdgGoals = const [],
    this.sdgPointsReward = 50,
    this.registeredUsers = const [],
    this.imageURL = '',
  });

  factory VolunteerEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VolunteerEventModel(
      id: doc.id,
      ngoId: data['ngoId'] ?? '',
      ngoName: data['ngoName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] as GeoPoint?,
      address: data['address'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sdgGoals: List<int>.from(data['sdgGoals'] ?? []),
      sdgPointsReward: data['sdgPointsReward'] ?? 50,
      registeredUsers: List<String>.from(data['registeredUsers'] ?? []),
      imageURL: data['imageURL'] ?? '',
    );
  }
}

class MarketplaceProduct {
  final String id;
  final String ngoId;
  final String ngoName;
  final String name;
  final String description;
  final double price;
  final String imageURL;
  final int stock;
  final List<int> sdgGoals;

  MarketplaceProduct({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.name,
    required this.description,
    required this.price,
    this.imageURL = '',
    this.stock = 0,
    this.sdgGoals = const [],
  });

  factory MarketplaceProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketplaceProduct(
      id: doc.id,
      ngoId: data['ngoId'] ?? '',
      ngoName: data['ngoName'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageURL: data['imageURL'] ?? '',
      stock: data['stock'] ?? 0,
      sdgGoals: List<int>.from(data['sdgGoals'] ?? []),
    );
  }
}

class RewardModel {
  final String id;
  final String title;
  final String description;
  final int costInScore;
  final String type; // 'voucher' | 'tree' | 'badge'
  final String imageURL;
  final bool available;

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.costInScore,
    required this.type,
    this.imageURL = '',
    this.available = true,
  });

  factory RewardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      costInScore: data['costInScore'] ?? 0,
      type: data['type'] ?? 'voucher',
      imageURL: data['imageURL'] ?? '',
      available: data['available'] ?? true,
    );
  }
}

class DonationProject {
  final String id;
  final String ngoId;
  final String ngoName;
  final String title;
  final String description;
  final String imageURL;
  final List<int> sdgGoals;
  final List<String> neededItems; // e.g. ['100 seedlings', '5 shovels']
  final double targetAmount; // in RM
  final double raisedAmount;
  final int targetPoints; // in SDG points
  final int raisedPoints;
  final DateTime endDate;
  final bool active;

  DonationProject({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.title,
    required this.description,
    this.imageURL = '',
    this.sdgGoals = const [],
    this.neededItems = const [],
    required this.targetAmount,
    this.raisedAmount = 0,
    this.targetPoints = 0,
    this.raisedPoints = 0,
    required this.endDate,
    this.active = true,
  });

  double get moneyProgress =>
      targetAmount > 0 ? (raisedAmount / targetAmount).clamp(0, 1) : 0;
  double get pointsProgress =>
      targetPoints > 0 ? (raisedPoints / targetPoints).clamp(0, 1) : 0;

  factory DonationProject.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonationProject(
      id: doc.id,
      ngoId: data['ngoId'] ?? '',
      ngoName: data['ngoName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageURL: data['imageURL'] ?? '',
      sdgGoals: List<int>.from(data['sdgGoals'] ?? []),
      neededItems: List<String>.from(data['neededItems'] ?? []),
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      raisedAmount: (data['raisedAmount'] ?? 0).toDouble(),
      targetPoints: data['targetPoints'] ?? 0,
      raisedPoints: data['raisedPoints'] ?? 0,
      endDate: (data['endDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      active: data['active'] ?? true,
    );
  }
}
