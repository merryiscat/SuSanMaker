import 'package:flutter/material.dart';
import '../models/gacha_item.dart';

/// 아바타 레이어링 시스템의 핵심 렌더링 위젯
///
/// 6개 레이어를 Stack으로 겹쳐서 최종 아바타를 렌더링합니다:
/// Layer 0: 베이스 캐릭터 (항상 표시)
/// Layer 1: 신발 (shoes)
/// Layer 2: 하의 (pants)
/// Layer 3: 상의 (shirts)
/// Layer 4: 머리 (headwear)
/// Layer 5: 액세서리 (accessories)
/// Layer 6: 이펙트 (effects)
class AvatarRenderer extends StatelessWidget {
  final Map<ItemSlot, String?> equippedItems;
  final double size;
  final bool showPlaceholder;

  const AvatarRenderer({
    super.key,
    required this.equippedItems,
    this.size = 200.0,
    this.showPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 0: 베이스 캐릭터 (항상 표시)
          _buildBaseCharacter(),

          // Layer 1: 신발
          if (equippedItems[ItemSlot.shoes] != null)
            _buildItemLayer(ItemSlot.shoes, equippedItems[ItemSlot.shoes]!),

          // Layer 2: 하의
          if (equippedItems[ItemSlot.pants] != null)
            _buildItemLayer(ItemSlot.pants, equippedItems[ItemSlot.pants]!),

          // Layer 3: 상의
          if (equippedItems[ItemSlot.shirt] != null)
            _buildItemLayer(ItemSlot.shirt, equippedItems[ItemSlot.shirt]!),

          // Layer 4: 머리
          if (equippedItems[ItemSlot.headwear] != null)
            _buildItemLayer(ItemSlot.headwear, equippedItems[ItemSlot.headwear]!),

          // Layer 5: 액세서리
          if (equippedItems[ItemSlot.accessory] != null)
            _buildItemLayer(ItemSlot.accessory, equippedItems[ItemSlot.accessory]!),

          // Layer 6: 이펙트
          if (equippedItems[ItemSlot.effect] != null)
            _buildItemLayer(ItemSlot.effect, equippedItems[ItemSlot.effect]!),
        ],
      ),
    );
  }

  /// 베이스 캐릭터 이미지 빌드
  Widget _buildBaseCharacter() {
    return Image.asset(
      'assets/characters/base_character.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        if (showPlaceholder) {
          return _buildPlaceholder();
        }
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person,
            color: Colors.grey,
            size: 100,
          ),
        );
      },
    );
  }

  /// 아이템 레이어 이미지 빌드
  Widget _buildItemLayer(ItemSlot slot, String itemId) {
    final String assetPath = _getAssetPath(slot, itemId);

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // 아이템 로딩 실패 시 투명하게 처리 (레이어는 선택적)
        return Container(
          width: size,
          height: size,
          color: Colors.transparent,
        );
      },
    );
  }

  /// 슬롯별 에셋 경로 생성
  String _getAssetPath(ItemSlot slot, String itemId) {
    final String slotFolder = _getSlotFolder(slot);
    return 'assets/items/$slotFolder/$itemId.png';
  }

  /// 슬롯별 폴더명 매핑
  String _getSlotFolder(ItemSlot slot) {
    switch (slot) {
      case ItemSlot.headwear:
        return 'headwear';
      case ItemSlot.shirt:
        return 'shirts';
      case ItemSlot.pants:
        return 'pants';
      case ItemSlot.shoes:
        return 'shoes';
      case ItemSlot.accessory:
        return 'accessories';
      case ItemSlot.effect:
        return 'effects';
    }
  }

  /// 플레이스홀더 위젯 (개발/테스트용)
  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            color: Colors.blue[400],
            size: size * 0.4,
          ),
          const SizedBox(height: 8),
          Text(
            'Base\nCharacter',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 아바타 미리보기용 위젯 (작은 크기)
class AvatarPreview extends StatelessWidget {
  final Map<ItemSlot, String?> equippedItems;
  final double size;

  const AvatarPreview({
    super.key,
    required this.equippedItems,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipOval(
        child: AvatarRenderer(
          equippedItems: equippedItems,
          size: size,
        ),
      ),
    );
  }
}

/// 아바타 선택용 위젯 (중간 크기, 선택 상태 표시)
class SelectableAvatar extends StatelessWidget {
  final Map<ItemSlot, String?> equippedItems;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;

  const SelectableAvatar({
    super.key,
    required this.equippedItems,
    this.isSelected = false,
    this.onTap,
    this.size = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AvatarRenderer(
          equippedItems: equippedItems,
          size: size,
        ),
      ),
    );
  }
}