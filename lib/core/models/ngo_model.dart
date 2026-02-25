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
    return NGOModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  factory NGOModel.fromMap(Map<dynamic, dynamic> data, String id) {
    GeoPoint? parseLoc(dynamic val) {
      if (val is GeoPoint) return val;
      if (val is Map) {
        return GeoPoint(
            (val['lat'] ?? 0).toDouble(), (val['lng'] ?? 0).toDouble());
      }
      return null;
    }

    return NGOModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      logoURL: data['logoURL'] ?? '',
      sdgGoals: List<int>.from(data['sdgGoals'] ?? []),
      contactEmail: data['contactEmail'] ?? '',
      location: parseLoc(data['location']),
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
    return VolunteerEventModel.fromMap(
        doc.data() as Map<String, dynamic>, doc.id);
  }

  factory VolunteerEventModel.fromMap(Map<dynamic, dynamic> data, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    GeoPoint? parseLoc(dynamic val) {
      if (val is GeoPoint) return val;
      if (val is Map) {
        return GeoPoint(
            (val['lat'] ?? 0).toDouble(), (val['lng'] ?? 0).toDouble());
      }
      return null;
    }

    List<T> parseList<T>(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.cast<T>();
      if (val is Map) return val.values.cast<T>().toList();
      return [];
    }

    return VolunteerEventModel(
      id: id,
      ngoId: data['ngoId'] ?? '',
      ngoName: data['ngoName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: parseLoc(data['location']),
      address: data['address'] ?? '',
      date: parseDate(data['date']),
      sdgGoals: parseList<int>(data['sdgGoals']),
      sdgPointsReward: data['sdgPointsReward'] ?? 50,
      registeredUsers: parseList<String>(data['registeredUsers']),
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
    return MarketplaceProduct.fromMap(
        doc.data() as Map<String, dynamic>, doc.id);
  }

  factory MarketplaceProduct.fromMap(Map<dynamic, dynamic> data, String id) {
    return MarketplaceProduct(
      id: id,
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
  final String type;
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
    return RewardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  factory RewardModel.fromMap(Map<dynamic, dynamic> data, String id) {
    return RewardModel(
      id: id,
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
  final List<String> neededItems;
  final double targetAmount;
  final double raisedAmount;
  final int targetPoints;
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
    return DonationProject.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  factory DonationProject.fromMap(Map<dynamic, dynamic> data, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return DonationProject(
      id: id,
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
      endDate: parseDate(data['endDate']),
      active: data['active'] ?? true,
    );
  }
}
