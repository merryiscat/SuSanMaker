import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/walk.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';

part 'bonus_provider.g.dart';

/// 보너스 시스템을 관리하는 Provider
/// 설계 문서 섹션 3.1: 일일 첫 산책 보너스, 연속 산책 보너스
@riverpod
class BonusSystem extends _$BonusSystem {
  @override
  Map<String, dynamic> build() {
    return {
      'lastWalkDate': null,
      'currentStreak': 0,
      'dailyFirstWalkBonus': 50, // 일일 첫 산책 보너스 포인트
      'streakBonusMultiplier': 0.1, // 연속 일수당 10% 추가
    };
  }

  /// 포인트 계산 (기본 공식 + 보너스)
  /// 설계 문서 섹션 3.1: Points=(Distance*DMultiplier)+(Time*TMultiplier) + 보너스
  int calculatePointsWithBonus({
    required double distance,
    required int durationInSeconds,
    required bool isFirstWalkToday,
    required int currentStreak,
  }) {
    // 기본 포인트 계산 (설계 문서의 공식)
    const int distanceMultiplier = 100; // 1km당 100포인트
    const double timeMultiplier = 1.0; // 1분당 1포인트

    final distancePoints = (distance * distanceMultiplier).round();
    final timePoints = (durationInSeconds / 60 * timeMultiplier).round();
    int totalPoints = distancePoints + timePoints;

    // 일일 첫 산책 보너스
    if (isFirstWalkToday) {
      totalPoints += state['dailyFirstWalkBonus'] as int;
    }

    // 연속 산책 보너스 (2일차부터 적용)
    if (currentStreak >= 2) {
      final streakMultiplier = state['streakBonusMultiplier'] as double;
      final streakBonus = (totalPoints * streakMultiplier * (currentStreak - 1)).round();
      totalPoints += streakBonus;
    }

    return totalPoints;
  }

  /// 현재 사용자의 연속 산책 일수 확인
  Future<int> getCurrentStreak() async {
    final currentUser = ref.read(currentUserProvider);
    await for (final user in currentUser.take(1)) {
      if (user != null) {
        final firestoreService = ref.read(firestoreServiceProvider);
        final recentWalks = await firestoreService.getRecentWalks(user.uid, limit: 30);

        return _calculateStreakFromWalks(recentWalks);
      }
    }
    return 0;
  }

  /// 오늘 첫 산책인지 확인
  Future<bool> isFirstWalkToday() async {
    final currentUser = ref.read(currentUserProvider);
    await for (final user in currentUser.take(1)) {
      if (user != null) {
        final firestoreService = ref.read(firestoreServiceProvider);
        final recentWalks = await firestoreService.getRecentWalks(user.uid, limit: 10);

        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);

        // 오늘 날짜의 산책이 있는지 확인
        final todayWalks = recentWalks.where((walk) {
          final walkDate = walk.completedAt;
          final walkDayStart = DateTime(walkDate.year, walkDate.month, walkDate.day);
          return walkDayStart.isAtSameMomentAs(todayStart);
        }).toList();

        return todayWalks.isEmpty;
      }
    }
    return true;
  }

  /// 산책 기록에서 연속 일수 계산
  int _calculateStreakFromWalks(List<Walk> walks) {
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

  /// 보너스 설정 업데이트
  void updateBonusSettings({
    int? dailyFirstWalkBonus,
    double? streakBonusMultiplier,
  }) {
    state = {
      ...state,
      if (dailyFirstWalkBonus != null) 'dailyFirstWalkBonus': dailyFirstWalkBonus,
      if (streakBonusMultiplier != null) 'streakBonusMultiplier': streakBonusMultiplier,
    };
  }

  /// 보너스 정보 요약 가져오기
  Future<Map<String, dynamic>> getBonusSummary() async {
    final isFirst = await isFirstWalkToday();
    final streak = await getCurrentStreak();

    return {
      'isFirstWalkToday': isFirst,
      'currentStreak': streak,
      'dailyFirstWalkBonus': state['dailyFirstWalkBonus'],
      'streakBonusPercentage': streak >= 2 ? (streak - 1) * 10 : 0, // 10% per day
      'nextStreakDay': streak + 1,
    };
  }
}

/// 사용자의 보너스 통계를 제공하는 Provider
@riverpod
Future<Map<String, dynamic>> userBonusStats(UserBonusStatsRef ref) async {
  final bonusSystem = ref.read(bonusSystemProvider.notifier);
  return await bonusSystem.getBonusSummary();
}