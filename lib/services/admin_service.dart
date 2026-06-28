import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDashboardStats() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final usersSnap = await _firestore
        .collection(AppConstants.usersCollection)
        .get();
    final withdrawSnap = await _firestore
        .collection(AppConstants.withdrawHistoryCollection)
        .get();

    int totalCoins = 0;
    int totalAdsWatched = 0;
    int todayUsers = 0;

    for (final doc in usersSnap.docs) {
      final data = doc.data();
      totalCoins += (data['coins'] as num?)?.toInt() ?? 0;
      totalAdsWatched +=
          (data['totalAdsWatched'] as num?)?.toInt() ?? 0;
      final lastActive =
          (data['lastActive'] as Timestamp?)?.toDate();
      if (lastActive != null &&
          lastActive.isAfter(todayStart)) {
        todayUsers++;
      }
    }

    double totalPendingAmount = 0;
    int totalWithdrawals = withdrawSnap.docs.length;

    for (final doc in withdrawSnap.docs) {
      final data = doc.data();
      if (data['status'] == 'pending') {
        totalPendingAmount +=
            (data['amount'] as num?)?.toDouble() ?? 0;
      }
    }

    return {
      'totalUsers': usersSnap.docs.length,
      'totalCoins': totalCoins,
      'totalAdsWatched': totalAdsWatched,
      'totalWithdrawals': totalWithdrawals,
      'totalPendingAmount': totalPendingAmount,
      'todayUsers': todayUsers,
    };
  }

  Stream<List<Map<String, dynamic>>> getAllWithdrawals({
    String? status,
  }) {
    Query query = _firestore
        .collection(AppConstants.withdrawHistoryCollection)
        .orderBy('createdAt', descending: true);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id
            })
        .toList());
  }

  Future<bool> updateWithdrawalStatus(
    String withdrawId,
    String status,
    String? adminNote,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.withdrawHistoryCollection)
          .doc(withdrawId)
          .update({
        'status': status,
        'updatedAt': Timestamp.now(),
        if (adminNote != null) 'adminNote': adminNote,
      });
      if (status == 'rejected') {
        final withdrawDoc = await _firestore
            .collection(AppConstants.withdrawHistoryCollection)
            .doc(withdrawId)
            .get();
        if (withdrawDoc.exists) {
          final data = withdrawDoc.data()!;
          final userId = data['userId'] as String;
          final coins = (data['coins'] as num).toInt();
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .update({
            'coins': FieldValue.increment(coins)
          });
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }
}
