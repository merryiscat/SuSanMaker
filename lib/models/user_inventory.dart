import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 인벤토리 아이템을 나타내는 데이터 모델 클래스
/// Firestore의 users/{userId}/inventory 하위 컬렉션에 저장됩니다
class UserInventory {
  /// 인벤토리 항목 ID (Firestore 자동 생성)
  final String inventoryId;

  /// 사용자 ID
  final String userId;

  /// 소유한 아이템 ID (items 컬렉션 참조)
  final String itemId;

  /// 아이템을 획득한 시간
  final DateTime acquiredAt;

  /// 새로 획득한 아이템인지 여부 (UI 표시용)
  final bool isNew;

  /// UserInventory 생성자
  const UserInventory({
    required this.inventoryId,
    required this.userId,
    required this.itemId,
    required this.acquiredAt,
    required this.isNew,
  });

  /// Firestore 문서에서 UserInventory 객체로 변환하는 팩토리 생성자
  factory UserInventory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserInventory(
      inventoryId: doc.id,
      userId: data['userId'] ?? '',
      itemId: data['itemId'] ?? '',
      acquiredAt: (data['acquiredAt'] as Timestamp).toDate(),
      isNew: data['isNew'] ?? false,
    );
  }

  /// JSON Map에서 UserInventory 객체를 생성하는 팩토리 생성자
  factory UserInventory.fromJson(Map<String, dynamic> json) {
    return UserInventory(
      inventoryId: json['inventoryId'],
      userId: json['userId'],
      itemId: json['itemId'],
      acquiredAt: DateTime.fromMillisecondsSinceEpoch(json['acquiredAt']),
      isNew: json['isNew'],
    );
  }

  /// UserInventory 객체를 Firestore에 저장할 수 있는 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'itemId': itemId,
      'acquiredAt': Timestamp.fromDate(acquiredAt),
      'isNew': isNew,
    };
  }

  /// UserInventory 객체를 JSON Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryId,
      'userId': userId,
      'itemId': itemId,
      'acquiredAt': acquiredAt.millisecondsSinceEpoch,
      'isNew': isNew,
    };
  }

  /// UserInventory 객체의 특정 필드를 업데이트한 새 객체를 반환
  UserInventory copyWith({
    String? inventoryId,
    String? userId,
    String? itemId,
    DateTime? acquiredAt,
    bool? isNew,
  }) {
    return UserInventory(
      inventoryId: inventoryId ?? this.inventoryId,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      isNew: isNew ?? this.isNew,
    );
  }

  @override
  String toString() {
    return 'UserInventory(inventoryId: $inventoryId, userId: $userId, itemId: $itemId, isNew: $isNew)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserInventory &&
        other.inventoryId == inventoryId &&
        other.userId == userId &&
        other.itemId == itemId &&
        other.acquiredAt == acquiredAt &&
        other.isNew == isNew;
  }

  @override
  int get hashCode {
    return inventoryId.hashCode ^
        userId.hashCode ^
        itemId.hashCode ^
        acquiredAt.hashCode ^
        isNew.hashCode;
  }
}