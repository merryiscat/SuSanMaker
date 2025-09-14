import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/walk.dart';
import '../models/gacha_item.dart';
import '../models/user_inventory.dart';

/// Firestore 데이터베이스와의 상호작용을 담당하는 서비스 클래스
/// 모든 CRUD 작업과 실시간 데이터 스트림을 제공합니다
class FirestoreService {
  /// Firestore 인스턴스
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== Users 컬렉션 관련 메서드 ==========

  /// 새 사용자를 Firestore에 저장
  static Future<void> createUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.userId)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('사용자 생성 실패: $e');
    }
  }

  /// 사용자 정보를 업데이트
  static Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);
    } catch (e) {
      throw Exception('사용자 정보 업데이트 실패: $e');
    }
  }

  /// 특정 사용자의 정보를 실시간으로 가져오는 스트림
  static Stream<User?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return User.fromFirestore(snapshot);
      }
      return null;
    });
  }

  /// 특정 사용자의 정보를 한 번만 가져오기
  static Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('사용자 정보 가져오기 실패: $e');
    }
  }

  // ========== Walks 컬렉션 관련 메서드 ==========

  /// 새 산책 기록을 저장
  static Future<String> saveWalk(Walk walk) async {
    try {
      final docRef = await _firestore
          .collection('walks')
          .add(walk.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('산책 기록 저장 실패: $e');
    }
  }

  /// 특정 사용자의 산책 기록을 최신순으로 가져오는 스트림
  static Stream<List<Walk>> getUserWalksStream(String userId) {
    return _firestore
        .collection('walks')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Walk.fromFirestore(doc))
            .toList());
  }

  /// 특정 사용자의 최근 N개 산책 기록 가져오기
  static Future<List<Walk>> getRecentWalks(String userId, {int limit = 10}) async {
    try {
      final query = await _firestore
          .collection('walks')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => Walk.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('최근 산책 기록 가져오기 실패: $e');
    }
  }

  // ========== Items 컬렉션 관련 메서드 ==========

  /// 모든 가챠 아이템 목록을 실시간으로 가져오는 스트림
  static Stream<List<GachaItem>> getGachaItemsStream() {
    return _firestore
        .collection('items')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GachaItem.fromFirestore(doc))
            .toList());
  }

  /// 모든 가챠 아이템 목록을 가져오기 (캐싱용)
  static Future<List<GachaItem>> getAllItems() async {
    try {
      final query = await _firestore
          .collection('items')
          .orderBy('name')
          .get();

      return query.docs.map((doc) => GachaItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('아이템 목록 가져오기 실패: $e');
    }
  }

  /// 특정 희귀도의 아이템들만 가져오기
  static Future<List<GachaItem>> getItemsByRarity(ItemRarity rarity) async {
    try {
      final query = await _firestore
          .collection('items')
          .where('rarity', isEqualTo: rarity.name)
          .get();

      return query.docs.map((doc) => GachaItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('희귀도별 아이템 가져오기 실패: $e');
    }
  }

  /// 특정 아이템 정보 가져오기
  static Future<GachaItem?> getItem(String itemId) async {
    try {
      final doc = await _firestore.collection('items').doc(itemId).get();
      if (doc.exists) {
        return GachaItem.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('아이템 정보 가져오기 실패: $e');
    }
  }

  // ========== User Inventory 관련 메서드 ==========

  /// 사용자 인벤토리에 새 아이템 추가
  static Future<String> addToInventory(UserInventory inventoryItem) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(inventoryItem.userId)
          .collection('inventory')
          .add(inventoryItem.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('인벤토리 아이템 추가 실패: $e');
    }
  }

  /// 사용자 인벤토리에 새 아이템 추가 (간편 메서드)
  static Future<String> addItemToInventory({
    required String userId,
    required String itemId,
  }) async {
    try {
      final inventoryItem = UserInventory(
        inventoryId: '', // Firestore에서 자동 생성
        userId: userId,
        itemId: itemId,
        acquiredAt: DateTime.now(),
        isNew: true,
      );

      return await addToInventory(inventoryItem);
    } catch (e) {
      throw Exception('인벤토리 아이템 추가 실패: $e');
    }
  }

  /// 사용자의 전체 인벤토리를 가져오는 스트림
  static Stream<List<UserInventory>> getUserInventoryStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('inventory')
        .orderBy('acquiredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserInventory.fromFirestore(doc))
            .toList());
  }

  /// 인벤토리 아이템의 isNew 상태 업데이트
  static Future<void> markInventoryItemAsRead({
    required String userId,
    required String inventoryId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('inventory')
          .doc(inventoryId)
          .update({'isNew': false});
    } catch (e) {
      throw Exception('인벤토리 아이템 상태 업데이트 실패: $e');
    }
  }

  // ========== 포인트 관련 메서드 ==========

  /// 사용자 포인트 업데이트 (증가/감소)
  static Future<void> updateUserPoints(String userId, int pointsChange) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('사용자를 찾을 수 없습니다');
        }

        final currentPoints = userDoc.data()?['pointsBalance'] ?? 0;
        final newPoints = currentPoints + pointsChange;

        if (newPoints < 0) {
          throw Exception('포인트가 부족합니다');
        }

        transaction.update(userRef, {
          'pointsBalance': newPoints,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('포인트 업데이트 실패: $e');
    }
  }

  /// 산책 완료 시 통계 업데이트 (포인트, 거리, 횟수)
  static Future<void> updateWalkStats(String userId, double distance, int points) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('사용자를 찾을 수 없습니다');
        }

        final data = userDoc.data()!;
        final currentPoints = data['pointsBalance'] ?? 0;
        final currentDistance = data['totalDistanceWalked'] ?? 0.0;
        final currentWalks = data['totalWalksCompleted'] ?? 0;

        transaction.update(userRef, {
          'pointsBalance': currentPoints + points,
          'totalDistanceWalked': currentDistance + distance,
          'totalWalksCompleted': currentWalks + 1,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('산책 통계 업데이트 실패: $e');
    }
  }

  // ========== 아바타 꾸미기 관련 메서드 ==========

  /// 사용자의 장착 아이템 업데이트
  static Future<void> updateEquippedItem(String userId, String slot, String itemId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'equippedItems.$slot': itemId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('장착 아이템 업데이트 실패: $e');
    }
  }

  /// 사용자의 장착 아이템 제거
  static Future<void> unequipItem(String userId, String slot) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'equippedItems.$slot': FieldValue.delete(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('장착 아이템 제거 실패: $e');
    }
  }

  // ========== 유틸리티 메서드 ==========

  /// 컬렉션의 문서 수 가져오기
  static Future<int> getCollectionCount(String collectionPath) async {
    try {
      final query = await _firestore.collection(collectionPath).get();
      return query.docs.length;
    } catch (e) {
      throw Exception('컬렉션 개수 가져오기 실패: $e');
    }
  }

  /// Firestore 연결 상태 확인
  static Future<bool> checkConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }
}