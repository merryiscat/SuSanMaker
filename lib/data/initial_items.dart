import '../models/gacha_item.dart';

/// 앱 초기 실행 시 Firestore에 추가될 기본 아이템 목록
/// 실제 아이템 이미지가 준비되면 이 데이터를 사용해 Firestore에 업로드
class InitialItemsData {
  static final List<GachaItem> basicItems = [
    // 머리 아이템
    GachaItem(
      itemId: 'basic_cap',
      name: '기본 모자',
      description: '간단한 회색 야구 모자',
      rarity: ItemRarity.common,
      slot: ItemSlot.headwear,
      assetUrl: 'basic_cap.png', // assets/items/headwear/ 경로 제외하고 파일명만
    ),

    // 상의 아이템
    GachaItem(
      itemId: 'red_tshirt',
      name: '빨간 티셔츠',
      description: '간단한 빨간색 반팔 티셔츠',
      rarity: ItemRarity.common,
      slot: ItemSlot.shirt,
      assetUrl: 'red_tshirt.png',
    ),

    GachaItem(
      itemId: 'blue_hoodie',
      name: '파란 후드티',
      description: '편안한 파란색 후드 티셔츠',
      rarity: ItemRarity.uncommon,
      slot: ItemSlot.shirt,
      assetUrl: 'blue_hoodie.png',
    ),

    // 하의 아이템
    GachaItem(
      itemId: 'blue_jeans',
      name: '파란 청바지',
      description: '기본적인 파란색 청바지',
      rarity: ItemRarity.common,
      slot: ItemSlot.pants,
      assetUrl: 'blue_jeans.png',
    ),

    GachaItem(
      itemId: 'black_shorts',
      name: '검정 반바지',
      description: '시원한 검정색 반바지',
      rarity: ItemRarity.common,
      slot: ItemSlot.pants,
      assetUrl: 'black_shorts.png',
    ),

    // 신발 아이템
    GachaItem(
      itemId: 'white_sneakers',
      name: '흰색 운동화',
      description: '깔끔한 흰색 운동화',
      rarity: ItemRarity.common,
      slot: ItemSlot.shoes,
      assetUrl: 'white_sneakers.png',
    ),

    GachaItem(
      itemId: 'red_sneakers',
      name: '빨간 운동화',
      description: '스타일리시한 빨간색 운동화',
      rarity: ItemRarity.uncommon,
      slot: ItemSlot.shoes,
      assetUrl: 'red_sneakers.png',
    ),

    // 액세서리 아이템
    GachaItem(
      itemId: 'black_glasses',
      name: '검정 안경',
      description: '심플한 검은 테 안경',
      rarity: ItemRarity.uncommon,
      slot: ItemSlot.accessory,
      assetUrl: 'black_glasses.png',
    ),

    GachaItem(
      itemId: 'gold_necklace',
      name: '골드 목걸이',
      description: '반짝이는 골드 체인 목걸이',
      rarity: ItemRarity.rare,
      slot: ItemSlot.accessory,
      assetUrl: 'gold_necklace.png',
    ),

    // 이펙트 아이템
    GachaItem(
      itemId: 'blue_aura',
      name: '파란 오라',
      description: '신비로운 파란색 오라 효과',
      rarity: ItemRarity.epic,
      slot: ItemSlot.effect,
      assetUrl: 'blue_aura.png',
    ),

    GachaItem(
      itemId: 'golden_sparkles',
      name: '황금 반짝임',
      description: '화려한 황금 반짝임 효과',
      rarity: ItemRarity.legendary,
      slot: ItemSlot.effect,
      assetUrl: 'golden_sparkles.png',
    ),
  ];

  /// 희귀도별 아이템 개수 확인
  static Map<ItemRarity, int> getItemCountByRarity() {
    final Map<ItemRarity, int> counts = {};

    for (final item in basicItems) {
      counts[item.rarity] = (counts[item.rarity] ?? 0) + 1;
    }

    return counts;
  }

  /// 슬롯별 아이템 개수 확인
  static Map<ItemSlot, int> getItemCountBySlot() {
    final Map<ItemSlot, int> counts = {};

    for (final item in basicItems) {
      counts[item.slot] = (counts[item.slot] ?? 0) + 1;
    }

    return counts;
  }

  /// 특정 슬롯의 아이템만 반환
  static List<GachaItem> getItemsBySlot(ItemSlot slot) {
    return basicItems.where((item) => item.slot == slot).toList();
  }

  /// 특정 희귀도의 아이템만 반환
  static List<GachaItem> getItemsByRarity(ItemRarity rarity) {
    return basicItems.where((item) => item.rarity == rarity).toList();
  }

  /// 아이템 통계 정보 출력 (디버그용)
  static void printItemStats() {
    print('=== 초기 아이템 통계 ===');
    print('총 아이템 수: ${basicItems.length}');

    print('\n희귀도별 분포:');
    final rarityCount = getItemCountByRarity();
    for (final entry in rarityCount.entries) {
      print('  ${entry.key.name}: ${entry.value}개');
    }

    print('\n슬롯별 분포:');
    final slotCount = getItemCountBySlot();
    for (final entry in slotCount.entries) {
      print('  ${entry.key.name}: ${entry.value}개');
    }
  }
}