import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawModel {
  final String id;
  final String userId;
  final String userName;
  final String phone;
  final String upiId;
  final int coins;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminNote;

  WithdrawModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.phone,
    required this.upiId,
    required this.coins,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.adminNote,
  });

  factory WithdrawModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WithdrawModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      phone: data['phone'] ?? '',
      upiId: data['upiId'] ?? '',
      coins: data['coins'] ?? 0,
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      adminNote: data['adminNote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'phone': phone,
      'upiId': upiId,
      'coins': coins,
      'amount': amount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null)
        'updatedAt': Timestamp.fromDate(updatedAt!),
      if (adminNote != null) 'adminNote': adminNote,
    };
  }
}
