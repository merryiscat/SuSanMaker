import 'package:cloud_firestore/cloud_firestore.dart';

/// 가챠 아이템의 희귀도를 나타내는 열거형
enum ItemRarity {
  /// 일반 아이템 (60% 확률)
  common,

  /// 고급 아이템 (25% 확률)
  uncommon,

  /// 희귀 아이템 (10% 확률)
  rare,

  /// 영웅 아이템 (4% 확률)
  epic,

  /// 전설 아이템 (1% 확률)
  legendary,
}

/// 아이템 슬롯 타입을 나타내는 열거형
enum ItemSlot {
  /// 머리 장식품 (모자, 헤어밴드 등)
  headwear,

  /// 상의 (셔츠, 재킷 등)
  shirt,

  /// 하의 (바지, 치마 등)
  pants,

  /// 신발
  shoes,

  /// 액세서리 (안경, 목걸이 등)
  accessory,
}

/// 가챠 아이템을 나타내는 데이터 모델 클래스
/// Firestore의 items 컬렉션에 저장되는 아이템 정보를 정의합니다
class GachaItem {
  /// 아이템 고유 ID
  final String itemId;

  /// 아이템 이름
  final String name;

  /// 아이템 설명
  final String description;

  /// 아이템 희귀도
  final ItemRarity rarity;

  /// 아이템 장착 슬롯
  final ItemSlot slot;

  /// 아이템 이미지 URL
  final String assetUrl;

  /// 아이템이 생성된 시간
  final DateTime? createdAt;

  /// GachaItem 생성자
  const GachaItem({
    required this.itemId,
    required this.name,
    required this.description,
    required this.rarity,
    required this.slot,
    required this.assetUrl,
    this.createdAt,
  });

  /// Firestore 문서에서 GachaItem 객체로 변환하는 팩토리 생성자
  factory GachaItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GachaItem(
      itemId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      rarity: _parseRarity(data['rarity']),
      slot: _parseSlot(data['slot']),
      assetUrl: data['assetUrl'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// JSON Map에서 GachaItem 객체를 생성하는 팩토리 생성자
  factory GachaItem.fromJson(Map<String, dynamic> json) {
    return GachaItem(
      itemId: json['itemId'],
      name: json['name'],
      description: json['description'],
      rarity: _parseRarity(json['rarity']),
      slot: _parseSlot(json['slot']),
      assetUrl: json['assetUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : null,
    );
  }

  /// GachaItem 객체를 Firestore에 저장할 수 있는 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'rarity': rarity.name,
      'slot': slot.name,
      'assetUrl': assetUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  /// GachaItem 객체를 JSON Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'description': description,
      'rarity': rarity.name,
      'slot': slot.name,
      'assetUrl': assetUrl,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  /// 희귀도에 따른 표시 색상을 반환
  int get rarityColor {
    switch (rarity) {
      case ItemRarity.common:
        return 0xFF9E9E9E; // 회색
      case ItemRarity.uncommon:
        return 0xFF4CAF50; // 녹색
      case ItemRarity.rare:
        return 0xFF2196F3; // 파란색
      case ItemRarity.epic:
        return 0xFF9C27B0; // 보라색
      case ItemRarity.legendary:
        return 0xFFFF9800; // 주황색
    }
  }

  /// 희귀도에 따른 표시 텍스트를 반환
  String get rarityDisplayName {
    switch (rarity) {
      case ItemRarity.common:
        return '일반';
      case ItemRarity.uncommon:
        return '고급';
      case ItemRarity.rare:
        return '희귀';
      case ItemRarity.epic:
        return '영웅';
      case ItemRarity.legendary:
        return '전설';
    }
  }

  /// 슬롯에 따른 표시 텍스트를 반환
  String get slotDisplayName {
    switch (slot) {
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
    }
  }

  /// 문자열을 ItemRarity로 변환하는 헬퍼 메서드
  static ItemRarity _parseRarity(String? rarity) {
    switch (rarity) {
      case 'common':
        return ItemRarity.common;
      case 'uncommon':
        return ItemRarity.uncommon;
      case 'rare':
        return ItemRarity.rare;
      case 'epic':
        return ItemRarity.epic;
      case 'legendary':
        return ItemRarity.legendary;
      default:
        return ItemRarity.common;
    }
  }

  /// 문자열을 ItemSlot으로 변환하는 헬퍼 메서드
  static ItemSlot _parseSlot(String? slot) {
    switch (slot) {
      case 'headwear':
        return ItemSlot.headwear;
      case 'shirt':
        return ItemSlot.shirt;
      case 'pants':
        return ItemSlot.pants;
      case 'shoes':
        return ItemSlot.shoes;
      case 'accessory':
        return ItemSlot.accessory;
      default:
        return ItemSlot.shirt;
    }
  }

  /// GachaItem 객체의 특정 필드를 업데이트한 새 객체를 반환
  GachaItem copyWith({
    String? itemId,
    String? name,
    String? description,
    ItemRarity? rarity,
    ItemSlot? slot,
    String? assetUrl,
    DateTime? createdAt,
  }) {
    return GachaItem(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      description: description ?? this.description,
      rarity: rarity ?? this.rarity,
      slot: slot ?? this.slot,
      assetUrl: assetUrl ?? this.assetUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'GachaItem(itemId: $itemId, name: $name, rarity: ${rarity.name}, slot: ${slot.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GachaItem &&
        other.itemId == itemId &&
        other.name == name &&
        other.description == description &&
        other.rarity == rarity &&
        other.slot == slot &&
        other.assetUrl == assetUrl;
  }

  @override
  int get hashCode {
    return itemId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        rarity.hashCode ^
        slot.hashCode ^
        assetUrl.hashCode;
  }
}