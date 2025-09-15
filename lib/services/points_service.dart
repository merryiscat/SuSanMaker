import 'dart:math' as math;

/// 포인트 계산 및 관리 서비스
/// 설계 문서 섹션 3.1: 인게임 경제 포인트 루프
class PointsService {
  static final PointsService _instance = PointsService._internal();
  factory PointsService() => _instance;
  PointsService._internal();

  // 포인트 계산 멀티플라이어 (design.md 기준)
  static const double distanceMultiplier = 100.0; // 1km당 100포인트
  static const double timeMultiplier = 2.0; // 1분당 2포인트
  
  // 보너스 포인트
  static const int dailyFirstWalkBonus = 50; // 일일 첫 산책 보너스
  static const double streakMultiplier = 0.1; // 연속 일수당 10% 보너스

  /// 산책 완료 시 포인트 계산
  /// [distanceKm] 이동 거리 (km)
  /// [durationMinutes] 소요 시간 (분)
  /// [isFirstWalkToday] 오늘 첫 산책 여부
  /// [streakDays] 연속 산책 일수
  int calculateWalkPoints({
    required double distanceKm,
    required int durationMinutes,
    bool isFirstWalkToday = false,
    int streakDays = 0,
  }) {
    // 기본 포인트 계산
    double basePoints = (distanceKm * distanceMultiplier) + 
                       (durationMinutes * timeMultiplier);
    
    // 일일 첫 산책 보너스
    if (isFirstWalkToday) {
      basePoints += dailyFirstWalkBonus;
    }
    
    // 연속 산책 보너스 (최대 50% 보너스)
    double streakBonus = math.min(streakDays * streakMultiplier, 0.5);
    basePoints *= (1 + streakBonus);
    
    // 최소 포인트 보장 (1분 이상 걸었으면 최소 10포인트)
    if (durationMinutes >= 1) {
      basePoints = math.max(basePoints, 10);
    }
    
    return basePoints.round();
  }

  /// 포인트 상세 내역 계산 (UI 표시용)
  Map<String, dynamic> calculatePointsBreakdown({
    required double distanceKm,
    required int durationMinutes,
    bool isFirstWalkToday = false,
    int streakDays = 0,
  }) {
    double distancePoints = distanceKm * distanceMultiplier;
    double timePoints = durationMinutes * timeMultiplier;
    double baseTotal = distancePoints + timePoints;
    
    int firstWalkBonus = isFirstWalkToday ? dailyFirstWalkBonus : 0;
    double streakBonus = math.min(streakDays * streakMultiplier, 0.5);
    double streakBonusPoints = baseTotal * streakBonus;
    
    double finalTotal = baseTotal + firstWalkBonus + streakBonusPoints;
    
    // 최소 포인트 적용
    if (durationMinutes >= 1) {
      finalTotal = math.max(finalTotal, 10);
    }
    
    return {
      'distancePoints': distancePoints.round(),
      'timePoints': timePoints.round(),
      'baseTotal': baseTotal.round(),
      'firstWalkBonus': firstWalkBonus,
      'streakBonusPercent': (streakBonus * 100).round(),
      'streakBonusPoints': streakBonusPoints.round(),
      'finalTotal': finalTotal.round(),
      'breakdown': [
        if (distancePoints > 0) '거리: ${distancePoints.round()}P (${distanceKm.toStringAsFixed(1)}km)',
        if (timePoints > 0) '시간: ${timePoints.round()}P (${durationMinutes}분)',
        if (firstWalkBonus > 0) '첫 산책 보너스: +${firstWalkBonus}P',
        if (streakBonusPoints > 0) '연속 보너스: +${streakBonusPoints.round()}P (${(streakBonus * 100).round()}%)',
      ],
    };
  }

  /// 가챠 1회 비용
  static const int singleGachaCost = 100;
  
  /// 가챠 10회 비용 (10% 할인)
  static const int tenGachaCost = 900;
  
  /// 포인트로 가챠 가능 횟수 계산
  Map<String, int> calculateGachaPossible(int currentPoints) {
    int singlePossible = currentPoints ~/ singleGachaCost;
    int tenPossible = currentPoints ~/ tenGachaCost;
    
    return {
      'single': singlePossible,
      'ten': tenPossible,
      'singleCost': singleGachaCost,
      'tenCost': tenGachaCost,
    };
  }

  /// 평균 산책 시간 기준 포인트 예상 계산
  int estimatePointsForWalk(double distanceKm, int estimatedMinutes) {
    return calculateWalkPoints(
      distanceKm: distanceKm,
      durationMinutes: estimatedMinutes,
      isFirstWalkToday: false,
      streakDays: 0,
    );
  }

  /// 목표 포인트 달성을 위한 필요 산책량 계산
  Map<String, dynamic> calculateRequiredWalkForPoints(int targetPoints) {
    // 기본적으로 거리와 시간이 균등하다고 가정 (평균 속도 4km/h)
    double avgSpeedKmPerHour = 4.0;
    double avgSpeedKmPerMin = avgSpeedKmPerHour / 60;
    
    // 기본 포인트만으로 계산 (보너스 제외)
    // targetPoints = distance * distanceMultiplier + time * timeMultiplier
    // time = distance / avgSpeedKmPerMin
    // targetPoints = distance * distanceMultiplier + (distance / avgSpeedKmPerMin) * timeMultiplier
    
    double totalMultiplier = distanceMultiplier + (timeMultiplier / avgSpeedKmPerMin);
    double requiredDistance = targetPoints / totalMultiplier;
    int requiredMinutes = (requiredDistance / avgSpeedKmPerMin).round();
    
    return {
      'distanceKm': double.parse(requiredDistance.toStringAsFixed(1)),
      'minutes': requiredMinutes,
      'estimatedPoints': estimatePointsForWalk(requiredDistance, requiredMinutes),
    };
  }
}