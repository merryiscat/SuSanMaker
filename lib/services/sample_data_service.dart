import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gacha_item.dart';

/// 샘플 데이터 초기화 서비스
/// 개발 및 테스트용 가챠 아이템 데이터를 생성합니다
class SampleDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 샘플 가챠 아이템들을 Firestore에 추가
  static Future<void> initializeSampleGachaItems() async {
    try {
      // 기존 아이템이 있는지 확인
      final existingItems = await _firestore.collection('items').limit(1).get();
      if (existingItems.docs.isNotEmpty) {
        print('샘플 아이템이 이미 존재합니다.');
        return;
      }

      final sampleItems = _createSampleItems();

      // 배치로 아이템들 추가
      final batch = _firestore.batch();

      for (final item in sampleItems) {
        final docRef = _firestore.collection('items').doc();
        batch.set(docRef, item.toFirestore());
      }

      await batch.commit();
      print('샘플 가챠 아이템 ${sampleItems.length}개가 추가되었습니다.');
    } catch (e) {
      print('샘플 데이터 초기화 실패: $e');
      rethrow;
    }
  }

  /// 샘플 아이템 목록 생성
  static List<GachaItem> _createSampleItems() {
    final now = DateTime.now();

    return [
      // Common 아이템 (60%)
      GachaItem(
        itemId: 'common_hat_1',
        name: '기본 모자',
        description: '평범한 검은색 모자입니다.',
        rarity: ItemRarity.common,
        slot: ItemSlot.headwear,
        assetUrl: 'assets/items/common_hat_1.png',
        createdAt: now,
      ),
      GachaItem(
        itemId: 'common_shirt_1',
        name: '흰색 티셔츠',
        description: '깔끔한 흰색 티셔츠입니다.',
        rarity: ItemRarity.common,
        slot: ItemSlot.shirt,
        assetUrl: 'assets/items/common_shirt_1.png',
        createdAt: now,
      ),
      GachaItem(
        itemId: 'common_pants_1',
        name: '청바지',
        description: '편안한 청바지입니다.',
        rarity: ItemRarity.common,
        slot: ItemSlot.pants,
        assetUrl: 'assets/items/common_pants_1.png',
        createdAt: now,
      ),
      GachaItem(
        itemId: 'common_shoes_1',
        name: '운동화',
        description: '기본적인 운동화입니다.',
        rarity: ItemRarity.common,
        slot: ItemSlot.shoes,
        assetUrl: 'assets/items/common_shoes_1.png',
        createdAt: now,
      ),

      // Uncommon 아이템 (25%)
      GachaItem(
        itemId: 'uncommon_hat_1',
        name: '패턴 캡',
        description: '멋진 패턴이 있는 캡모자입니다.',
        rarity: ItemRarity.uncommon,
        slot: ItemSlot.headwear,
        assetUrl: 'assets/items/uncommon_hat_1.png',
        createdAt: now,
      ),
      GachaItem(
        itemId: 'uncommon_shirt_1',
        name: '스트라이프 셔츠',
        description: '세련된 줄무늬 셔츠입니다.',
        rarity: ItemRarity.uncommon,
        slot: ItemSlot.shirt,
        assetUrl: 'assets/items/uncommon_shirt_1.png',
        createdAt: now,
      ),
      GachaItem(
        itemId: 'uncommon_accessory_1',
        name: '기본 안경',
        description: '지적인 느낌의 안경입니다.',
        rarity: ItemRarity.uncommon,
        slot: ItemSlot.accessory,
        assetUrl: 'assets/items/uncommon_accessory_1.png',
        createdAt: now,
      ),

      // Rare 아이템 (10%)
      GachaItem(
        itemId: 'rare_hat_1',
        name: '특이한 베레모',
        description: '예술가 느낌의 특별한 베레모입니다.',
        rarity: ItemRarity.rare,
        slot: ItemSlot.headwear,
        assetUrl: 'assets/items/rare_hat_1.png',
        createdAt: now,
      ),
      GachaItem(
        itemId: 'rare_shirt_1',
        name: '디자이너 재킷',
        description: '고급스러운 디자이너 재킷입니다.',
        rarity: ItemRarity.rare,
        slot: ItemSlot.shirt,
        assetUrl: 'assets/items/rare_shirt_1.png',
        createdAt: now,
      ),
      GachaItem(
        itemId: 'rare_accessory_1',
        name: '디자인 안경',
        description: '독특한 디자인의 명품 안경입니다.',
        rarity: ItemRarity.rare,
        slot: ItemSlot.accessory,
        assetUrl: 'assets/items/rare_accessory_1.png',
        createdAt: now,
      ),

      // Epic 아이템 (4%)
      GachaItem(
        itemId: 'epic_hat_1',
        name: '왕관',
        description: '화려한 보석이 박힌 왕관입니다.',
        rarity: ItemRarity.epic,
        slot: ItemSlot.headwear,
        assetUrl: 'assets/items/epic_hat_1.png',
        createdAt: now,
      ),
      GachaItem(
        itemId: 'epic_accessory_1',
        name: '마법의 목걸이',
        description: '신비로운 힘이 깃든 목걸이입니다.',
        rarity: ItemRarity.epic,
        slot: ItemSlot.accessory,
        assetUrl: 'assets/items/epic_accessory_1.png',
        createdAt: now,
      ),
      GachaItem(
        itemId: 'epic_shoes_1',
        name: '부팅 부츠',
        description: '특별한 효과가 있는 부츠입니다.',
        rarity: ItemRarity.epic,
        slot: ItemSlot.shoes,
        assetUrl: 'assets/items/epic_shoes_1.png',
        createdAt: now,
      ),

      // Legendary 아이템 (1%)
      GachaItem(
        itemId: 'legendary_hat_1',
        name: '전설의 헬멧',
        description: '빛나는 이펙트와 함께하는 전설의 헬멧입니다.',
        rarity: ItemRarity.legendary,
        slot: ItemSlot.headwear,
        assetUrl: 'assets/items/legendary_hat_1.png',
        createdAt: now,
      ),
      GachaItem(
        itemId: 'legendary_accessory_1',
        name: '용의 목걸이',
        description: '움직이는 용 이펙트가 있는 희귀한 목걸이입니다.',
        rarity: ItemRarity.legendary,
        slot: ItemSlot.accessory,
        assetUrl: 'assets/items/legendary_accessory_1.png',
        createdAt: now,
      ),
    ];
  }

  /// 샘플 사용자 데이터 생성 (테스트용)
  static Future<void> createSampleUser(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.set({
        'userId': userId,
        'email': 'test@example.com',
        'displayName': '테스트 사용자',
        'createdAt': Timestamp.now(),
        'pointsBalance': 500, // 테스트용 포인트
        'totalDistanceWalked': 0.0,
        'totalWalksCompleted': 0,
        'equippedItems': {}, // 빈 장착 아이템
        'lastUpdated': Timestamp.now(),
      });

      print('샘플 사용자가 생성되었습니다: $userId');
    } catch (e) {
      print('샘플 사용자 생성 실패: $e');
      rethrow;
    }
  }

  /// 개발용 데이터 초기화 (아이템 + 사용자)
  static Future<void> initializeAllSampleData({String? testUserId}) async {
    try {
      print('샘플 데이터 초기화 시작...');

      // 1. 가챠 아이템 초기화
      await initializeSampleGachaItems();

      // 2. 테스트 사용자 생성 (옵션)
      if (testUserId != null) {
        await createSampleUser(testUserId);
      }

      print('샘플 데이터 초기화 완료!');
    } catch (e) {
      print('샘플 데이터 초기화 실패: $e');
      rethrow;
    }
  }

  /// 데이터 초기화 (개발용)
  static Future<void> clearAllSampleData() async {
    try {
      print('샘플 데이터 삭제 시작...');

      // 아이템 컬렉션 삭제
      final itemsQuery = await _firestore.collection('items').get();
      final itemsBatch = _firestore.batch();

      for (final doc in itemsQuery.docs) {
        itemsBatch.delete(doc.reference);
      }

      await itemsBatch.commit();
      print('샘플 데이터 삭제 완료!');
    } catch (e) {
      print('샘플 데이터 삭제 실패: $e');
      rethrow;
    }
  }
}