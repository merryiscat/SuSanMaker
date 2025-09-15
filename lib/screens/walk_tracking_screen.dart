import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/pixel_button.dart';
import '../services/location_service.dart';
import '../models/route_point.dart';

class WalkTrackingScreen extends StatefulWidget {
  const WalkTrackingScreen({super.key});

  @override
  State<WalkTrackingScreen> createState() => _WalkTrackingScreenState();
}

class _WalkTrackingScreenState extends State<WalkTrackingScreen> {
  bool _isWalking = false;
  Duration _elapsed = Duration.zero;
  double _distance = 0.0;
  double _speed = 0.0;
  
  final LocationService _locationService = LocationService();
  StreamSubscription<Map<String, dynamic>>? _walkStatsSubscription;
  StreamSubscription<RoutePoint>? _locationSubscription;
  
  RoutePoint? _currentLocation;
  String _locationStatus = '위치 확인 중...';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _walkStatsSubscription?.cancel();
    _locationSubscription?.cancel();
    if (_isWalking) {
      _locationService.stopTracking();
    }
    _locationService.dispose();
    super.dispose();
  }

  void _initializeLocation() async {
    try {
      // 현재 위치 한 번 가져오기
      _locationStatus = '현재 위치 확인 중...';
      setState(() {});
    } catch (e) {
      _locationStatus = '위치 권한을 확인해주세요';
      setState(() {});
    }
  }

  void _startWalkTracking() async {
    try {
      setState(() {
        _isWalking = true;
        _locationStatus = '산책 추적 시작 중...';
      });

      // LocationService 추적 시작
      await _locationService.startTracking();

      // 위치 업데이트 구독
      _locationSubscription = _locationService.locationStream.listen(
        (RoutePoint location) {
          setState(() {
            _currentLocation = location;
            _locationStatus = '위치 추적 중...';
          });
        },
        onError: (error) {
          setState(() {
            _locationStatus = '위치 추적 오류: $error';
            _isWalking = false;
          });
        },
      );

      // 산책 통계 구독
      _walkStatsSubscription = _locationService.walkStatsStream.listen(
        (Map<String, dynamic> stats) {
          setState(() {
            _distance = stats['totalDistance'] ?? 0.0;
            _elapsed = Duration(seconds: stats['elapsedSeconds'] ?? 0);
            _speed = stats['averageSpeed'] ?? 0.0;
          });
        },
      );

    } catch (e) {
      setState(() {
        _isWalking = false;
        _locationStatus = '추적 시작 실패: $e';
      });
    }
  }

  void _stopWalkTracking() async {
    await _locationService.stopTracking();
    _walkStatsSubscription?.cancel();
    _locationSubscription?.cancel();
    
    setState(() {
      _isWalking = false;
      _locationStatus = '추적 중지됨';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('산책 중'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 지도 영역 (임시)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isWalking ? Icons.my_location : Icons.location_searching,
                          size: 64,
                          color: _isWalking ? AppColors.primary : AppColors.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _locationStatus,
                          style: TextStyle(
                            color: AppColors.onSurface.withOpacity(0.7),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_currentLocation != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '위도: ${_currentLocation!.latitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              color: AppColors.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '경도: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              color: AppColors.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 통계 카드들
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    _buildStatCard('시간', _formatDuration(_elapsed), Icons.timer),
                    const SizedBox(width: 12),
                    _buildStatCard('거리', '${_distance.toStringAsFixed(1)}km', Icons.straighten),
                    const SizedBox(width: 12),
                    _buildStatCard('속도', '${_speed.toStringAsFixed(1)}km/h', Icons.speed),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 컨트롤 버튼들
              Row(
                children: [
                  Expanded(
                    child: PixelButton(
                      text: _isWalking ? '일시정지' : '시작',
                      isLarge: true,
                      onPressed: () {
                        if (_isWalking) {
                          _stopWalkTracking();
                        } else {
                          _startWalkTracking();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PixelButton(
                      text: '완료',
                      isLarge: true,
                      onPressed: () => _finishWalk(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.onSurface.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          '산책을 종료하시겠습니까?',
          style: TextStyle(color: AppColors.onSurface),
        ),
        content: Text(
          '진행 중인 산책이 저장되지 않습니다.',
          style: TextStyle(color: AppColors.onSurface.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('계속하기', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text('종료', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _finishWalk(BuildContext context) async {
    if (_isWalking) {
      await _stopWalkTracking();
    }
    
    // 산책 데이터 추출
    final walkData = _locationService.exportTrackingData();
    print('산책 완료 데이터: $walkData');
    
    // TODO: Firebase에 데이터 저장
    
    // 결과 화면으로 데이터 전달
    context.pushReplacement('/walk-result', extra: walkData);
  }
}