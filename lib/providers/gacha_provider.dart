import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/gacha_item.dart';
import '../models/user_inventory.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';
import 'dart:math';

part 'gacha_provider.g.dart';

/// 가챠 아이템 마스터 데이터를 관리하는 Provider
/// 설계 문서 섹션 3.2: 가챠 시스템
@riverpod
Stream<List<GachaItem>> gachaItems(GachaItemsRef ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getGachaItemsStream();
}

/// 사용자 인벤토리를 관리하는 Provider
@riverpod
Stream<List<UserInventory>> userInventory(UserInventoryRef ref) async* {
  final currentUser = ref.watch(currentUserProvider);

  await for (final user in currentUser) {
    if (user == null) {
      yield [];
    } else {
      final firestoreService = ref.read(firestoreServiceProvider);
      yield* firestoreService.getUserInventoryStream(user.uid);
    }
  }
}

/// 가챠 시스템을 관리하는 NotifierProvider
@riverpod
class GachaSystem extends _$GachaSystem {
  @override
  Map<String, dynamic> build() {
    return {
      'pityCountRare': 0, // Rare 등급 천장 카운터
      'pityCountEpic': 0, // Epic 등급 천장 카운터
    };
  }

  /// 가챠 1회 뽑기
  /// 설계 문서 섹션 3.2의 확률표와 천장 시스템 구현
  Future<GachaItem?> performSingleDraw() async {
    const int gachaCost = 100; // 1회 뽑기 비용

    final currentUser = ref.read(currentUserProvider);
    await for (final user in currentUser.take(1)) {
      if (user == null || user.pointsBalance < gachaCost) {
        throw Exception('포인트가 부족합니다');
      }

      // 가챠 아이템 목록 가져오기
      final gachaItems = ref.read(gachaItemsProvider);
      final itemList = await gachaItems.first;

      if (itemList.isEmpty) {
        throw Exception('가챠 아이템이 없습니다');
      }

      // 확률 계산 및 아이템 선택
      final selectedItem = _selectItemByRarity(itemList);

      // 천장 시스템 업데이트
      _updatePityCounters(selectedItem.rarity.name);

      // 포인트 차감
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateUserPoints(user.uid, -gachaCost);

      // 인벤토리에 아이템 추가
      final inventoryItem = UserInventory(
        inventoryId: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        itemId: selectedItem.itemId,
        acquiredAt: DateTime.now(),
        isNew: true,
      );

      await firestoreService.addToInventory(inventoryItem);

      return selectedItem;
    }

    return null;
  }

  /// 확률에 따른 아이템 선택 로직
  /// 설계 문서 섹션 3.2의 확률표 구현
  GachaItem _selectItemByRarity(List<GachaItem> items) {
    final random = Random();
    final randomValue = random.nextDouble() * 100;

    // 천장 시스템 확인
    if (state['pityCountRare'] >= 10) {
      // Rare 이상 보장
      state = {...state, 'pityCountRare': 0};
      return _selectItemFromRarity(items, ['rare', 'epic', 'legendary']);
    }

    if (state['pityCountEpic'] >= 50) {
      // Epic 이상 보장
      state = {...state, 'pityCountEpic': 0, 'pityCountRare': 0};
      return _selectItemFromRarity(items, ['epic', 'legendary']);
    }

    // 일반 확률 적용 (설계 문서의 확률표)
    if (randomValue <= 1.0) {
      // 1% - Legendary
      return _selectItemFromRarity(items, ['legendary']);
    } else if (randomValue <= 5.0) {
      // 4% - Epic
      return _selectItemFromRarity(items, ['epic']);
    } else if (randomValue <= 15.0) {
      // 10% - Rare
      return _selectItemFromRarity(items, ['rare']);
    } else if (randomValue <= 40.0) {
      // 25% - Uncommon
      return _selectItemFromRarity(items, ['uncommon']);
    } else {
      // 60% - Common
      return _selectItemFromRarity(items, ['common']);
    }
  }

  /// 특정 희귀도에서 아이템 선택
  GachaItem _selectItemFromRarity(List<GachaItem> items, List<String> rarities) {
    final filteredItems = items
        .where((item) => rarities.contains(item.rarity.name))
        .toList();

    if (filteredItems.isEmpty) {
      // 대체 아이템 반환
      return items.first;
    }

    final random = Random();
    return filteredItems[random.nextInt(filteredItems.length)];
  }

  /// 천장 카운터 업데이트
  void _updatePityCounters(String rarity) {
    if (rarity == 'legendary' || rarity == 'epic') {
      // Epic 이상을 뽑으면 모든 카운터 초기화
      state = {...state, 'pityCountRare': 0, 'pityCountEpic': 0};
    } else if (rarity == 'rare') {
      // Rare를 뽑으면 Rare 카운터만 초기화
      state = {...state, 'pityCountRare': 0, 'pityCountEpic': state['pityCountEpic'] + 1};
    } else {
      // Common, Uncommon의 경우 카운터 증가
      state = {
        ...state,
        'pityCountRare': state['pityCountRare'] + 1,
        'pityCountEpic': state['pityCountEpic'] + 1,
      };
    }
  }

  /// 아이템 장착
  Future<void> equipItem(String itemId, String slot) async {
    final currentUser = ref.read(currentUserProvider);
    await for (final user in currentUser.take(1)) {
      if (user != null) {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.updateEquippedItem(user.uid, slot, itemId);
        break;
      }
    }
  }
}