import 'dart:async';
import '../models/gacha_item.dart';

/// 사용자 인벤토리 관리 서비스
/// 사용자가 보유한 아이템들과 현재 장착한 아이템들을 관리합니다
class InventoryService {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  // 임시 저장소 (추후 SharedPreferences나 Firebase로 연동)
  final List<GachaItem> _ownedItems = [];
  final Map<ItemSlot, String?> _equippedItems = {};

  // 스트림 컨트롤러
  final StreamController<List<GachaItem>> _inventoryController = 
      StreamController<List<GachaItem>>.broadcast();
  final StreamController<Map<ItemSlot, String?>> _equippedItemsController = 
      StreamController<Map<ItemSlot, String?>>.broadcast();

  /// 인벤토리 변경 스트림
  Stream<List<GachaItem>> get inventoryStream => _inventoryController.stream;

  /// 장착 아이템 변경 스트림
  Stream<Map<ItemSlot, String?>> get equippedItemsStream => _equippedItemsController.stream;

  /// 현재 보유 아이템 목록 반환
  List<GachaItem> get ownedItems => List.unmodifiable(_ownedItems);

  /// 현재 장착한 아이템들 반환
  Map<ItemSlot, String?> get equippedItems => Map.unmodifiable(_equippedItems);

  /// 새 아이템을 인벤토리에 추가
  void addItem(GachaItem item) {
    _ownedItems.add(item);
    _inventoryController.add(List.unmodifiable(_ownedItems));
  }

  /// 특정 슬롯의 아이템들만 필터링하여 반환
  List<GachaItem> getItemsBySlot(ItemSlot slot) {
    return _ownedItems.where((item) => item.slot == slot).toList();
  }

  /// 아이템 장착
  void equipItem(String itemId) {
    // 아이템이 인벤토리에 있는지 확인
    final item = _ownedItems.firstWhere(
      (item) => item.itemId == itemId,
      orElse: () => throw Exception('Item not found in inventory: $itemId'),
    );

    // 해당 슬롯에 아이템 장착
    _equippedItems[item.slot] = itemId;
    _equippedItemsController.add(Map.unmodifiable(_equippedItems));
  }

  /// 특정 슬롯의 아이템 해제
  void unequipSlot(ItemSlot slot) {
    _equippedItems[slot] = null;
    _equippedItemsController.add(Map.unmodifiable(_equippedItems));
  }

  /// 특정 슬롯에 현재 장착된 아이템 반환
  GachaItem? getEquippedItem(ItemSlot slot) {
    final itemId = _equippedItems[slot];
    if (itemId == null) return null;

    try {
      return _ownedItems.firstWhere((item) => item.itemId == itemId);
    } catch (e) {
      return null;
    }
  }

  /// 아이템 ID로 아이템 객체 찾기
  GachaItem? getItemById(String itemId) {
    try {
      return _ownedItems.firstWhere((item) => item.itemId == itemId);
    } catch (e) {
      return null;
    }
  }

  /// 특정 아이템이 현재 장착되어 있는지 확인
  bool isItemEquipped(String itemId) {
    return _equippedItems.values.contains(itemId);
  }

  /// 인벤토리 초기화 (테스트용)
  void clearInventory() {
    _ownedItems.clear();
    _equippedItems.clear();
    _inventoryController.add([]);
    _equippedItemsController.add({});
  }

  /// 테스트용 초기 아이템들 추가
  void initializeWithTestItems() {
    // 각 슬롯별로 하나씩 기본 아이템 추가
    final testItems = [
      GachaItem(
        itemId: 'default_headwear',
        name: '기본 모자',
        description: '처음부터 가지고 있던 기본 모자',
        rarity: ItemRarity.common,
        slot: ItemSlot.headwear,
        assetUrl: 'assets/items/default_headwear.png',
        createdAt: DateTime.now(),
      ),
      GachaItem(
        itemId: 'default_shirt',
        name: '기본 티셔츠',
        description: '처음부터 가지고 있던 기본 티셔츠',
        rarity: ItemRarity.common,
        slot: ItemSlot.shirt,
        assetUrl: 'assets/items/default_shirt.png',
        createdAt: DateTime.now(),
      ),
    ];

    for (final item in testItems) {
      addItem(item);
      equipItem(item.itemId); // 기본 아이템들은 자동으로 장착
    }
  }

  /// 서비스 해제
  void dispose() {
    _inventoryController.close();
    _equippedItemsController.close();
  }
}