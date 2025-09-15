import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/pixel_button.dart';
import '../widgets/avatar_renderer.dart';
import '../services/inventory_service.dart';
import '../models/gacha_item.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final InventoryService _inventoryService = InventoryService();
  
  ItemSlot _selectedSlot = ItemSlot.headwear;
  List<GachaItem> _currentSlotItems = [];
  Map<ItemSlot, String?> _equippedItems = {};

  @override
  void initState() {
    super.initState();
    _initializeInventory();
    _listenToInventoryChanges();
    _updateCurrentSlotItems();
  }

  void _initializeInventory() {
    // 테스트용 초기 아이템들 추가 (실제로는 저장된 데이터에서 로드)
    if (_inventoryService.ownedItems.isEmpty) {
      _inventoryService.initializeWithTestItems();
    }
    _equippedItems = _inventoryService.equippedItems;
  }

  void _listenToInventoryChanges() {
    _inventoryService.inventoryStream.listen((_) {
      _updateCurrentSlotItems();
    });

    _inventoryService.equippedItemsStream.listen((equippedItems) {
      setState(() {
        _equippedItems = equippedItems;
      });
    });
  }

  void _updateCurrentSlotItems() {
    setState(() {
      _currentSlotItems = _inventoryService.getItemsBySlot(_selectedSlot);
    });
  }

  void _onSlotTabChanged(ItemSlot slot) {
    setState(() {
      _selectedSlot = slot;
      _updateCurrentSlotItems();
    });
  }

  void _onItemTapped(GachaItem item) {
    final isCurrentlyEquipped = _inventoryService.isItemEquipped(item.itemId);
    
    if (isCurrentlyEquipped) {
      // 현재 장착중이면 해제
      _inventoryService.unequipSlot(item.slot);
      _showSnackBar('${item.name} 장착 해제됨');
    } else {
      // 장착되지 않았으면 장착
      _inventoryService.equipItem(item.itemId);
      _showSnackBar('${item.name} 장착됨');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('옷장'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _inventoryService.clearInventory();
              _inventoryService.initializeWithTestItems();
            },
            tooltip: '인벤토리 초기화 (테스트용)',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 아바타 미리보기 + 현재 장착 아이템 정보
              _buildAvatarPreviewSection(),
              
              const SizedBox(height: 16),
              
              // 슬롯 카테고리 탭
              _buildSlotTabs(),
              
              const SizedBox(height: 16),
              
              // 아이템 그리드
              _buildItemGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreviewSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 아바타 미리보기 (왼쪽)
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아바타 렌더러 사용
                AvatarRenderer(
                  equippedItems: _equippedItems,
                  size: 120.0,
                  showPlaceholder: true,
                ),
                const SizedBox(height: 8),
                Text(
                  '현재 아바타',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 현재 장착 아이템 정보 (오른쪽)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 장착 아이템',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildEquippedItemsList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquippedItemsList() {
    return ListView(
      children: ItemSlot.values.map((slot) {
        final equippedItem = _inventoryService.getEquippedItem(slot);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Icon(
                _getSlotIcon(slot),
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${slot.displayName}: ${equippedItem?.name ?? '없음'}',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlotTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ItemSlot.values.length,
        itemBuilder: (context, index) {
          final slot = ItemSlot.values[index];
          final isSelected = slot == _selectedSlot;
          final itemCount = _inventoryService.getItemsBySlot(slot).length;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 90,
              child: PixelButton(
                text: '${slot.displayName}\n($itemCount)',
                onPressed: () => _onSlotTabChanged(slot),
                isSelected: isSelected,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemGrid() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _currentSlotItems.isEmpty
            ? _buildEmptyState()
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _currentSlotItems.length,
                itemBuilder: (context, index) {
                  final item = _currentSlotItems[index];
                  final isEquipped = _inventoryService.isItemEquipped(item.itemId);
                  
                  return _buildItemCard(item, isEquipped);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: AppColors.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '${_selectedSlot.displayName} 아이템이 없습니다',
            style: TextStyle(
              color: AppColors.onSurface.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '산책을 완료하고 가챠를 돌려보세요!',
            style: TextStyle(
              color: AppColors.onSurface.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(GachaItem item, bool isEquipped) {
    return GestureDetector(
      onTap: () => _onItemTapped(item),
      child: Container(
        decoration: BoxDecoration(
          color: isEquipped ? AppColors.primary.withOpacity(0.2) : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEquipped 
                ? AppColors.primary 
                : Color(item.rarityColor).withOpacity(0.5),
            width: isEquipped ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이템 아이콘 (추후 실제 이미지로 교체)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(item.rarityColor).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getSlotIcon(item.slot),
                color: Color(item.rarityColor),
                size: 24,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 아이템 이름
            Text(
              item.name,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // 희귀도
            Text(
              item.rarityDisplayName,
              style: TextStyle(
                color: Color(item.rarityColor),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // 장착 상태 표시
            if (isEquipped)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '장착중',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getSlotIcon(ItemSlot slot) {
    switch (slot) {
      case ItemSlot.headwear:
        return Icons.sports_baseball;
      case ItemSlot.shirt:
        return Icons.checkroom;
      case ItemSlot.pants:
        return Icons.content_cut;
      case ItemSlot.shoes:
        return Icons.directions_walk;
      case ItemSlot.accessory:
        return Icons.visibility;
      case ItemSlot.effect:
        return Icons.auto_awesome;
    }
  }
}

// ItemSlot에 대한 확장 (display name)
extension ItemSlotExtension on ItemSlot {
  String get displayName {
    switch (this) {
      case ItemSlot.headwear:
        return '머리';
      case ItemSlot.shirt:
        return '상의';
      case ItemSlot.pants:
        return '하의';
      case ItemSlot.shoes:
        return '신발';
      case ItemSlot.accessory:
        return '액세서리';
      case ItemSlot.effect:
        return '이펙트';
    }
  }
}