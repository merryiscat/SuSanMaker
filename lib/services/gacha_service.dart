import 'dart:math';
import '../models/gacha_item.dart';

/// 가챠 시스템 및 확률 관리 서비스
/// 설계 문서 섹션 3.2: 가챠 시스템 설계 및 구현
class GachaService {
  static final GachaService _instance = GachaService._internal();
  factory GachaService() => _instance;
  GachaService._internal();

  final Random _random = Random();

  // 설계 문서의 확률표 (design.md 참조)
  static const Map<ItemRarity, double> _rarityProbabilities = {
    ItemRarity.common: 0.60,     // 60%
    ItemRarity.uncommon: 0.25,   // 25%
    ItemRarity.rare: 0.10,       // 10%
    ItemRarity.epic: 0.04,       // 4%
    ItemRarity.legendary: 0.01,  // 1%
  };

  // 천장 시스템 설정 (설계 문서 기준)
  static const Map<ItemRarity, int> _pitySystem = {
    ItemRarity.rare: 10,      // 10회 내 Rare 이상 보장
    ItemRarity.epic: 50,      // 50회 내 Epic 이상 보장
    ItemRarity.legendary: 100, // 100회 내 Legendary 보장
  };

  /// 임시 아이템 데이터 (추후 Firebase나 로컬 JSON으로 이동)
  final List<GachaItem> _itemPool = [
    // Common 아이템들
    GachaItem(
      itemId: 'common_hat_001',
      name: '기본 모자',
      description: '심플한 디자인의 기본 모자',
      rarity: ItemRarity.common,
      slot: ItemSlot.headwear,
      assetUrl: 'assets/items/common_hat_001.png',
      createdAt: DateTime.now(),
    ),
    GachaItem(
      itemId: 'common_shirt_001',
      name: '흰색 티셔츠',
      description: '깔끔한 흰색 티셔츠',
      rarity: ItemRarity.common,
      slot: ItemSlot.shirt,
      assetUrl: 'assets/items/common_shirt_001.png',
      createdAt: DateTime.now(),
    ),
    
    // Uncommon 아이템들
    GachaItem(
      itemId: 'uncommon_hat_001',
      name: '스트라이프 모자',
      description: '세련된 줄무늬 패턴의 모자',
      rarity: ItemRarity.uncommon,
      slot: ItemSlot.headwear,
      assetUrl: 'assets/items/uncommon_hat_001.png',
      createdAt: DateTime.now(),
    ),
    GachaItem(
      itemId: 'uncommon_accessory_001',
      name: '선글라스',
      description: '멋진 선글라스',
      rarity: ItemRarity.uncommon,
      slot: ItemSlot.accessory,
      assetUrl: 'assets/items/uncommon_accessory_001.png',
      createdAt: DateTime.now(),
    ),
    
    // Rare 아이템들
    GachaItem(
      itemId: 'rare_hat_001',
      name: '베레모',
      description: '우아한 베레모',
      rarity: ItemRarity.rare,
      slot: ItemSlot.headwear,
      assetUrl: 'assets/items/rare_hat_001.png',
      createdAt: DateTime.now(),
    ),
    GachaItem(
      itemId: 'rare_shirt_001',
      name: '체크 셔츠',
      description: '클래식한 체크 패턴 셔츠',
      rarity: ItemRarity.rare,
      slot: ItemSlot.shirt,
      assetUrl: 'assets/items/rare_shirt_001.png',
      createdAt: DateTime.now(),
    ),
    
    // Epic 아이템들
    GachaItem(
      itemId: 'epic_accessory_001',
      name: '마법사 지팡이',
      description: '신비로운 힘이 깃든 지팡이',
      rarity: ItemRarity.epic,
      slot: ItemSlot.accessory,
      assetUrl: 'assets/items/epic_accessory_001.png',
      createdAt: DateTime.now(),
    ),
    
    // Legendary 아이템들
    GachaItem(
      itemId: 'legendary_effect_001',
      name: '황금 오라',
      description: '전설적인 황금빛 오라 효과',
      rarity: ItemRarity.legendary,
      slot: ItemSlot.effect,
      assetUrl: 'assets/items/legendary_effect_001.png',
      createdAt: DateTime.now(),
    ),
  ];

  /// 전체 아이템 풀 반환
  List<GachaItem> get allItems => List.unmodifiable(_itemPool);

  /// 희귀도별 아이템 필터링
  List<GachaItem> getItemsByRarity(ItemRarity rarity) {
    return _itemPool.where((item) => item.rarity == rarity).toList();
  }

  /// 슬롯별 아이템 필터링
  List<GachaItem> getItemsBySlot(ItemSlot slot) {
    return _itemPool.where((item) => item.slot == slot).toList();
  }

  /// 단일 가챠 뽑기
  /// [pityCounters] 현재 천장 카운터 상태
  /// Returns: 뽑은 아이템과 업데이트된 천장 카운터
  GachaResult performSingleGacha(Map<ItemRarity, int> pityCounters) {
    // 천장 시스템 확인
    ItemRarity guaranteedRarity = _checkPitySystem(pityCounters);
    
    ItemRarity selectedRarity;
    if (guaranteedRarity != ItemRarity.common) {
      // 천장 발동
      selectedRarity = guaranteedRarity;
    } else {
      // 일반 확률 계산
      selectedRarity = _rollRarity();
    }
    
    // 해당 희귀도의 아이템 중 랜덤 선택
    List<GachaItem> availableItems = getItemsByRarity(selectedRarity);
    if (availableItems.isEmpty) {
      // Fallback: Common 아이템으로
      availableItems = getItemsByRarity(ItemRarity.common);
    }
    
    GachaItem selectedItem = availableItems[_random.nextInt(availableItems.length)];
    
    // 천장 카운터 업데이트
    Map<ItemRarity, int> updatedCounters = _updatePityCounters(pityCounters, selectedRarity);
    
    return GachaResult(
      item: selectedItem,
      pityCounters: updatedCounters,
      wasPityActivated: guaranteedRarity != ItemRarity.common,
    );
  }

  /// 10연차 가챠 뽑기
  List<GachaResult> performTenGacha(Map<ItemRarity, int> initialPityCounters) {
    List<GachaResult> results = [];
    Map<ItemRarity, int> currentCounters = Map.from(initialPityCounters);
    
    for (int i = 0; i < 10; i++) {
      GachaResult result = performSingleGacha(currentCounters);
      results.add(result);
      currentCounters = result.pityCounters;
    }
    
    return results;
  }

  /// 희귀도 확률 롤
  ItemRarity _rollRarity() {
    double roll = _random.nextDouble();
    double cumulative = 0.0;
    
    for (var entry in _rarityProbabilities.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) {
        return entry.key;
      }
    }
    
    // Fallback (should not happen)
    return ItemRarity.common;
  }

  /// 천장 시스템 확인
  ItemRarity _checkPitySystem(Map<ItemRarity, int> pityCounters) {
    // 높은 희귀도부터 확인 (Legendary -> Epic -> Rare)
    if ((pityCounters[ItemRarity.legendary] ?? 0) >= _pitySystem[ItemRarity.legendary]!) {
      return ItemRarity.legendary;
    }
    if ((pityCounters[ItemRarity.epic] ?? 0) >= _pitySystem[ItemRarity.epic]!) {
      return ItemRarity.epic;
    }
    if ((pityCounters[ItemRarity.rare] ?? 0) >= _pitySystem[ItemRarity.rare]!) {
      return ItemRarity.rare;
    }
    
    return ItemRarity.common; // 천장 미발동
  }

  /// 천장 카운터 업데이트
  Map<ItemRarity, int> _updatePityCounters(Map<ItemRarity, int> currentCounters, ItemRarity drawnRarity) {
    Map<ItemRarity, int> updated = Map.from(currentCounters);
    
    // 뽑은 희귀도에 따라 카운터 리셋
    switch (drawnRarity) {
      case ItemRarity.legendary:
        updated[ItemRarity.legendary] = 0;
        updated[ItemRarity.epic] = 0;
        updated[ItemRarity.rare] = 0;
        break;
      case ItemRarity.epic:
        updated[ItemRarity.epic] = 0;
        updated[ItemRarity.rare] = 0;
        // Legendary 카운터는 증가
        updated[ItemRarity.legendary] = (updated[ItemRarity.legendary] ?? 0) + 1;
        break;
      case ItemRarity.rare:
        updated[ItemRarity.rare] = 0;
        // Epic, Legendary 카운터는 증가
        updated[ItemRarity.epic] = (updated[ItemRarity.epic] ?? 0) + 1;
        updated[ItemRarity.legendary] = (updated[ItemRarity.legendary] ?? 0) + 1;
        break;
      default:
        // Common, Uncommon의 경우 모든 카운터 증가
        updated[ItemRarity.rare] = (updated[ItemRarity.rare] ?? 0) + 1;
        updated[ItemRarity.epic] = (updated[ItemRarity.epic] ?? 0) + 1;
        updated[ItemRarity.legendary] = (updated[ItemRarity.legendary] ?? 0) + 1;
        break;
    }
    
    return updated;
  }

  /// 확률 정보 반환 (UI 표시용)
  Map<String, dynamic> getProbabilityInfo() {
    return {
      'rarityProbabilities': _rarityProbabilities.map(
        (rarity, probability) => MapEntry(rarity.name, probability * 100)
      ),
      'pitySystem': _pitySystem.map(
        (rarity, count) => MapEntry(rarity.name, count)
      ),
    };
  }

  /// 초기 천장 카운터 생성
  Map<ItemRarity, int> createInitialPityCounters() {
    return {
      ItemRarity.rare: 0,
      ItemRarity.epic: 0,
      ItemRarity.legendary: 0,
    };
  }
}

/// 가챠 결과를 담는 클래스
class GachaResult {
  final GachaItem item;
  final Map<ItemRarity, int> pityCounters;
  final bool wasPityActivated;
  
  const GachaResult({
    required this.item,
    required this.pityCounters,
    required this.wasPityActivated,
  });
}