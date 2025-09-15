import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/pixel_button.dart';
import '../services/points_service.dart';

class WalkResultScreen extends StatelessWidget {
  final Map<String, dynamic>? walkData;
  
  const WalkResultScreen({super.key, this.walkData});

  @override
  Widget build(BuildContext context) {
    final pointsService = PointsService();
    
    // 실제 산책 데이터 또는 Mock 데이터 사용
    final data = walkData ?? {
      'totalDistance': 2.3,
      'elapsedSeconds': 1935, // 32분 15초
      'averageSpeed': 4.3,
    };
    
    // 포인트 계산
    final distanceKm = (data['totalDistance'] ?? 0.0) as double;
    final elapsedSeconds = (data['elapsedSeconds'] ?? 0) as int;
    final durationMinutes = (elapsedSeconds / 60).round();
    final speed = (data['averageSpeed'] ?? 0.0) as double;
    
    // 실제 포인트 계산 (임시로 첫 산책으로 설정)
    final pointsBreakdown = pointsService.calculatePointsBreakdown(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      isFirstWalkToday: true, // TODO: 실제 첫 산책 여부 확인
      streakDays: 1, // TODO: 실제 연속 일수 확인
    );
    
    final displayData = {
      'distance': distanceKm,
      'duration': _formatDuration(elapsedSeconds),
      'speed': speed,
      'points': pointsBreakdown['finalTotal'],
      'pointsBreakdown': pointsBreakdown,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.3),
              AppColors.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // 축하 메시지
                const SizedBox(height: 32),
                Icon(
                  Icons.celebration,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '산책 완료!',
                  style: TextStyle(
                    color: AppColors.pixelWhite,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '수고하셨습니다!',
                  style: TextStyle(
                    color: AppColors.pixelWhite.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // 통계 그리드
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        '거리',
                        '${displayData['distance']!.toStringAsFixed(1)}km',
                        Icons.straighten,
                      ),
                      _buildStatCard(
                        '시간',
                        '${displayData['duration']}',
                        Icons.timer,
                      ),
                      _buildStatCard(
                        '평균 속도',
                        '${displayData['speed']!.toStringAsFixed(1)}km/h',
                        Icons.speed,
                      ),
                      _buildStatCard(
                        '획득 포인트',
                        '${displayData['points']} P',
                        Icons.stars,
                        isHighlight: true,
                        showBreakdown: true,
                        pointsBreakdown: pointsBreakdown,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 액션 버튼들
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: PixelButton(
                        text: '포인트 사용하기! 🎰',
                        isLarge: true,
                        onPressed: () => context.push('/gacha'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PixelButton(
                            text: '기록 보기',
                            onPressed: () {
                              // TODO: 산책 기록 화면으로 이동
                              context.go('/');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PixelButton(
                            text: '홈으로',
                            onPressed: () => context.go('/'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label, 
    String value, 
    IconData icon, {
    bool isHighlight = false,
    bool showBreakdown = false,
    Map<String, dynamic>? pointsBreakdown,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isHighlight 
          ? Border.all(color: AppColors.primary, width: 2)
          : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isHighlight ? AppColors.primary : AppColors.onSurface,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? AppColors.primary : AppColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isHighlight 
                ? AppColors.primary.withOpacity(0.8)
                : AppColors.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 초를 "시:분:초" 형식으로 변환
  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}