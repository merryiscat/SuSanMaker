import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/pixel_button.dart';

class WalkSetupScreen extends StatefulWidget {
  const WalkSetupScreen({super.key});

  @override
  State<WalkSetupScreen> createState() => _WalkSetupScreenState();
}

class _WalkSetupScreenState extends State<WalkSetupScreen> {
  double _distance = 2.0; // km
  int _duration = 30; // minutes
  bool _useDistance = true; // true: 거리 기준, false: 시간 기준

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('산책 설정'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 설정 방식 선택
              Text(
                '산책 방식을 선택하세요',
                style: TextStyle(
                  color: AppColors.pixelWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: PixelButton(
                      text: '거리 기준',
                      onPressed: () => setState(() => _useDistance = true),
                      // TODO: 선택된 상태 표시 로직 추가
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PixelButton(
                      text: '시간 기준',
                      onPressed: () => setState(() => _useDistance = false),
                      // TODO: 선택된 상태 표시 로직 추가
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 거리 또는 시간 설정
              if (_useDistance) ...[
                Text(
                  '목표 거리: ${_distance.toStringAsFixed(1)}km',
                  style: TextStyle(
                    color: AppColors.pixelWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _distance,
                  min: 0.5,
                  max: 10.0,
                  divisions: 19,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.surface,
                  onChanged: (value) => setState(() => _distance = value),
                ),
              ] else ...[
                Text(
                  '목표 시간: ${_duration}분',
                  style: TextStyle(
                    color: AppColors.pixelWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _duration.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 22,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.surface,
                  onChanged: (value) => setState(() => _duration = value.round()),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // 현재 위치 정보 (TODO: 실제 위치 가져오기)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '시작 위치',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '현재 위치를 확인 중...',
                      style: TextStyle(
                        color: AppColors.onSurface.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // 경로 생성 버튼
              SizedBox(
                width: double.infinity,
                child: PixelButton(
                  text: '경로 생성하기',
                  isLarge: true,
                  onPressed: () {
                    // TODO: 실제 경로 생성 로직
                    context.push('/walk-tracking');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}