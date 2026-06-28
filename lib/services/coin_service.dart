import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reward_history_model.dart';
import '../utils/constants.dart';

class CoinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<bool> addRewardAdCoins() async {
    if (_uid == null) return false;
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(_uid);
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;
        final currentCoins = userDoc.data()?['coins'] ?? 0;
        final currentAds =
            userDoc.data()?['totalAdsWatched'] ?? 0;
        transaction.update(userRef, {
          'coins': currentCoins + AppConstants.rewardAdCoins,
          'totalAdsWatched': currentAds + 1,
          'lastActive': Timestamp.now(),
        });
        final historyRef = _firestore
            .collection(AppConstants.rewardHistoryCollection)
            .doc();
        transaction.set(historyRef, {
          'userId': _uid,
          'type': 'reward_ad',
          'coins': AppConstants.rewardAdCoins,
          'description': 'Reward Ad Completed',
          'createdAt': Timestamp.now(),
        });
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addQuizCoins(
      String question, bool isCorrect) async {
    if (_uid == null) return false;
    try {
      final coins =
          isCorrect ? AppConstants.quizCorrectCoins : 0;
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(_uid);
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;
        final currentCoins = userDoc.data()?['coins'] ?? 0;
        final currentQuiz =
            userDoc.data()?['totalQuizCorrect'] ?? 0;
        if (isCorrect) {
          transaction.update(userRef, {
            'coins': currentCoins + coins,
            'totalQuizCorrect': currentQuiz + 1,
          });
        }
        final historyRef = _firestore
            .collection(AppConstants.quizHistoryCollection)
            .doc();
        transaction.set(historyRef, {
          'userId': _uid,
          'question': question,
          'isCorrect': isCorrect,
          'coins': coins,
          'createdAt': Timestamp.now(),
        });
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitWithdrawal({
    required String userName,
    required String phone,
    required String upiId,
    required int coins,
  }) async {
    if (_uid == null) return false;
    try {
      final double amount = AppConstants.coinsToRupees(coins);
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(_uid);
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;
        final currentCoins = userDoc.data()?['coins'] ?? 0;
        if (currentCoins < AppConstants.minWithdrawCoins) {
          throw Exception('Insufficient coins');
        }
        transaction.update(userRef, {
          'coins': currentCoins - coins,
          'totalWithdrawn':
              (userDoc.data()?['totalWithdrawn'] ?? 0) + 1,
        });
        final withdrawRef = _firestore
            .collection(AppConstants.withdrawHistoryCollection)
            .doc();
        transaction.set(withdrawRef, {
          'userId': _uid,
          'userName': userName,
          'phone': phone,
          'upiId': upiId,
          'coins': coins,
          'amount': amount,
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<RewardHistoryModel>> getRewardHistory() {
    if (_uid == null) return Stream.value([]);
    return _firestore
        .collection(AppConstants.rewardHistoryCollection)
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RewardHistoryModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getQuizHistory() {
    if (_uid == null) return Stream.value([]);
    return _firestore
        .collection(AppConstants.quizHistoryCollection)
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getWithdrawHistory() {
    if (_uid == null) return Stream.value([]);
    return _firestore
        .collection(AppConstants.withdrawHistoryCollection)
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }
}
