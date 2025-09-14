import '../models/gacha_item.dart';
import '../models/user_inventory.dart';
import '../models/walk.dart';
import 'firestore_service.dart';

/// 게임화 시스템의 통합 서비스 클래스
/// 설계 문서 섹션 3: 게임화, 보상 및 경제 시스템
class GamificationService {
  /// 산책 완료 시 포인트 계산 및 보상 처리
  /// 모든 보너스 로직을 통합하여 처리
  static Future<Map<String, dynamic>> processWalkCompletion({
    required String userId,
    required double distance,
    required int durationInSeconds,
  }) async {
    try {
      // 1. 오늘 첫 산책인지 확인
      final recentWalks = await FirestoreService.getRecentWalks(userId, limit: 10);
      final isFirstWalkToday = _isFirstWalkToday(recentWalks);

      // 2. 연속 산책 일수 계산
      final currentStreak = _calculateStreak(recentWalks);

      // 3. 포인트 계산 (기본 + 보너스)
      final pointsData = _calculatePointsWithBonus(
        distance: distance,
        durationInSeconds: durationInSeconds,
        isFirstWalkToday: isFirstWalkToday,
        currentStreak: currentStreak,
      );

      // 4. 사용자 통계 업데이트
      await FirestoreService.updateWalkStats(
        userId,
        distance,
        pointsData['totalPoints'],
      );

      return {
        'success': true,
        'pointsAwarded': pointsData['totalPoints'],
        'breakdown': pointsData['breakdown'],
        'isFirstWalkToday': isFirstWalkToday,
        'currentStreak': currentStreak,
        'nextStreakDay': currentStreak + 1,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 가챠 뽑기 처리
  /// 확률 계산, 천장 시스템, 인벤토리 업데이트를 통합 처리
  static Future<Map<String, dynamic>> performGachaDraw({
    required String userId,
    required int pityCountRare,
    required int pityCountEpic,
  }) async {
    try {
      const int gachaCost = 100;

      // 1. 사용자 포인트 확인
      final user = await FirestoreService.getUser(userId);
      if (user == null || user.pointsBalance < gachaCost) {
        return {
          'success': false,
          'error': '포인트가 부족합니다',
        };
      }

      // 2. 가챠 아이템 목록 가져오기
      final items = await FirestoreService.getAllItems();
      if (items.isEmpty) {
        return {
          'success': false,
          'error': '가챠 아이템이 없습니다',
        };
      }

      // 3. 아이템 선택 (확률 + 천장 시스템)
      final gachaResult = _selectGachaItem(
        items: items,
        pityCountRare: pityCountRare,
        pityCountEpic: pityCountEpic,
      );

      // 4. 포인트 차감
      await FirestoreService.updateUserPoints(userId, -gachaCost);

      // 5. 인벤토리에 아이템 추가
      final inventoryItem = UserInventory(
        inventoryId: '',
        userId: userId,
        itemId: gachaResult['item'].itemId,
        acquiredAt: DateTime.now(),
        isNew: true,
      );

      await FirestoreService.addToInventory(inventoryItem);

      return {
        'success': true,
        'item': gachaResult['item'],
        'newPityCounters': gachaResult['newPityCounters'],
        'pointsSpent': gachaCost,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 아이템 장착/해제 처리
  static Future<Map<String, dynamic>> equipItem({
    required String userId,
    required String itemId,
    required String slot,
  }) async {
    try {
      await FirestoreService.updateEquippedItem(userId, slot, itemId);

      return {
        'success': true,
        'message': '아이템이 장착되었습니다',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 아이템 해제 처리
  static Future<Map<String, dynamic>> unequipItem({
    required String userId,
    required String slot,
  }) async {
    try {
      await FirestoreService.unequipItem(userId, slot);

      return {
        'success': true,
        'message': '아이템이 해제되었습니다',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 포인트 계산 (기본 + 보너스)
  static Map<String, dynamic> _calculatePointsWithBonus({
    required double distance,
    required int durationInSeconds,
    required bool isFirstWalkToday,
    required int currentStreak,
  }) {
    // 기본 포인트 계산 (설계 문서 섹션 3.1)
    const int distanceMultiplier = 100; // 1km당 100포인트
    const double timeMultiplier = 1.0; // 1분당 1포인트

    final distancePoints = (distance * distanceMultiplier).round();
    final timePoints = (durationInSeconds / 60 * timeMultiplier).round();
    int totalPoints = distancePoints + timePoints;

    final breakdown = <String, int>{
      'distance': distancePoints,
      'time': timePoints,
    };

    // 일일 첫 산책 보너스
    if (isFirstWalkToday) {
      const int dailyBonus = 50;
      totalPoints += dailyBonus;
      breakdown['dailyFirstWalk'] = dailyBonus;
    }

    // 연속 산책 보너스 (2일차부터 적용)
    if (currentStreak >= 2) {
      final streakBonus = (totalPoints * 0.1 * (currentStreak - 1)).round();
      totalPoints += streakBonus;
      breakdown['streak'] = streakBonus;
    }

    return {
      'totalPoints': totalPoints,
      'breakdown': breakdown,
    };
  }

  /// 오늘 첫 산책인지 확인
  static bool _isFirstWalkToday(List<Walk> recentWalks) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    for (final walk in recentWalks) {
      final walkDate = walk.completedAt;
      final walkDayStart = DateTime(walkDate.year, walkDate.month, walkDate.day);

      if (walkDayStart.isAtSameMomentAs(todayStart)) {
        return false; // 오늘 이미 산책한 기록이 있음
      }
    }

    return true; // 오늘 첫 산책
  }

  /// 연속 산책 일수 계산
  static int _calculateStreak(List<Walk> walks) {
    if (walks.isEmpty) return 0;

    // 날짜별로 그룹화
    final walksByDate = <DateTime, List<Walk>>{};

    for (final walk in walks) {
      final walkDate = walk.completedAt;
      final dayStart = DateTime(walkDate.year, walkDate.month, walkDate.day);

      if (!walksByDate.containsKey(dayStart)) {
        walksByDate[dayStart] = [];
      }
      walksByDate[dayStart]!.add(walk);
    }

    // 날짜를 최신순으로 정렬
    final sortedDates = walksByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) return 0;

    // 연속 일수 계산
    int streak = 0;
    DateTime? previousDate;

    for (final date in sortedDates) {
      if (previousDate == null) {
        // 첫 날
        streak = 1;
        previousDate = date;
      } else {
        // 이전 날과 연속인지 확인
        final daysDifference = previousDate.difference(date).inDays;

        if (daysDifference == 1) {
          // 연속된 날
          streak++;
          previousDate = date;
        } else {
          // 연속이 끊어짐
          break;
        }
      }
    }

    return streak;
  }

  /// 가챠 아이템 선택 (확률 + 천장 시스템)
  static Map<String, dynamic> _selectGachaItem({
    required List<GachaItem> items,
    required int pityCountRare,
    required int pityCountEpic,
  }) {
    // 천장 시스템 확인
    List<String> forcedRarities = [];

    if (pityCountEpic >= 50) {
      // Epic 이상 보장
      forcedRarities = ['epic', 'legendary'];
    } else if (pityCountRare >= 10) {
      // Rare 이상 보장
      forcedRarities = ['rare', 'epic', 'legendary'];
    }

    GachaItem selectedItem;
    Map<String, int> newPityCounters;

    if (forcedRarities.isNotEmpty) {
      // 천장 시스템 적용
      selectedItem = _selectItemFromRarities(items, forcedRarities);

      if (forcedRarities.contains('epic')) {
        // Epic 이상이 보장된 경우
        newPityCounters = {'rare': 0, 'epic': 0};
      } else {
        // Rare 이상이 보장된 경우
        newPityCounters = {'rare': 0, 'epic': pityCountEpic + 1};
      }
    } else {
      // 일반 확률 적용
      selectedItem = _selectItemByProbability(items);
      newPityCounters = _updatePityCounters(
        selectedItem.rarity.name,
        pityCountRare,
        pityCountEpic,
      );
    }

    return {
      'item': selectedItem,
      'newPityCounters': newPityCounters,
    };
  }

  /// 확률에 따른 아이템 선택
  static GachaItem _selectItemByProbability(List<GachaItem> items) {
    final random = DateTime.now().millisecondsSinceEpoch % 100000;
    final randomValue = random / 1000.0; // 0-99.999 범위

    List<String> targetRarities;

    if (randomValue <= 1.0) {
      // 1% - Legendary
      targetRarities = ['legendary'];
    } else if (randomValue <= 5.0) {
      // 4% - Epic
      targetRarities = ['epic'];
    } else if (randomValue <= 15.0) {
      // 10% - Rare
      targetRarities = ['rare'];
    } else if (randomValue <= 40.0) {
      // 25% - Uncommon
      targetRarities = ['uncommon'];
    } else {
      // 60% - Common
      targetRarities = ['common'];
    }

    return _selectItemFromRarities(items, targetRarities);
  }

  /// 특정 희귀도에서 아이템 선택
  static GachaItem _selectItemFromRarities(List<GachaItem> items, List<String> rarities) {
    final filteredItems = items
        .where((item) => rarities.contains(item.rarity.name))
        .toList();

    if (filteredItems.isEmpty) {
      // 대체 아이템 반환 (Common)
      final commonItems = items.where((item) => item.rarity.name == 'common').toList();
      return commonItems.isNotEmpty ? commonItems.first : items.first;
    }

    final random = DateTime.now().millisecondsSinceEpoch % filteredItems.length;
    return filteredItems[random];
  }

  /// 천장 카운터 업데이트
  static Map<String, int> _updatePityCounters(
    String rarity,
    int currentRareCount,
    int currentEpicCount,
  ) {
    if (rarity == 'legendary' || rarity == 'epic') {
      // Epic 이상을 뽑으면 모든 카운터 초기화
      return {'rare': 0, 'epic': 0};
    } else if (rarity == 'rare') {
      // Rare를 뽑으면 Rare 카운터만 초기화
      return {'rare': 0, 'epic': currentEpicCount + 1};
    } else {
      // Common, Uncommon의 경우 카운터 증가
      return {'rare': currentRareCount + 1, 'epic': currentEpicCount + 1};
    }
  }

  /// 게임화 시스템 상태 요약
  static Future<Map<String, dynamic>> getGamificationSummary(String userId) async {
    try {
      final user = await FirestoreService.getUser(userId);
      final recentWalks = await FirestoreService.getRecentWalks(userId, limit: 30);

      return {
        'success': true,
        'pointsBalance': user?.pointsBalance ?? 0,
        'totalDistanceWalked': user?.totalDistanceWalked ?? 0.0,
        'totalWalksCompleted': user?.totalWalksCompleted ?? 0,
        'currentStreak': _calculateStreak(recentWalks),
        'isFirstWalkToday': _isFirstWalkToday(recentWalks),
        'canPerformGacha': (user?.pointsBalance ?? 0) >= 100,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}