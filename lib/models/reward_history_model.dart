import 'package:cloud_firestore/cloud_firestore.dart';

class RewardHistoryModel {
  final String id;
  final String userId;
  final String type;
  final int coins;
  final String description;
  final DateTime createdAt;

  RewardHistoryModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.coins,
    required this.description,
    required this.createdAt,
  });

  factory RewardHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardHistoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      coins: data['coins'] ?? 0,
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'coins': coins,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
