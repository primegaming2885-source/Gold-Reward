import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String photoUrl;
  final int coins;
  final int totalAdsWatched;
  final int totalQuizCorrect;
  final int totalWithdrawn;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.photoUrl,
    required this.coins,
    required this.totalAdsWatched,
    required this.totalQuizCorrect,
    required this.totalWithdrawn,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      coins: data['coins'] ?? 0,
      totalAdsWatched: data['totalAdsWatched'] ?? 0,
      totalQuizCorrect: data['totalQuizCorrect'] ?? 0,
      totalWithdrawn: data['totalWithdrawn'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'coins': coins,
      'totalAdsWatched': totalAdsWatched,
      'totalQuizCorrect': totalQuizCorrect,
      'totalWithdrawn': totalWithdrawn,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    int? coins,
    int? totalAdsWatched,
    int? totalQuizCorrect,
    int? totalWithdrawn,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      coins: coins ?? this.coins,
      totalAdsWatched: totalAdsWatched ?? this.totalAdsWatched,
      totalQuizCorrect: totalQuizCorrect ?? this.totalQuizCorrect,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      createdAt: createdAt,
      lastActive: DateTime.now(),
    );
  }

  double get rupeesValue => coins / 10.0;
  bool get canWithdraw => coins >= 1000;
}
