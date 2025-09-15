import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/pixel_button.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고/타이틀
              Text(
                '랜덤 산책로 메이커',
                style: TextStyle(
                  color: AppColors.pixelWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                '산책을 게임으로!\n포인트를 모아 아바타를 꾸며보세요',
                style: TextStyle(
                  color: AppColors.pixelWhite.withOpacity(0.8),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 64),
              
              // 로그인 버튼들
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: PixelButton(
                      text: 'Google로 로그인',
                      isLarge: true,
                      onPressed: () {
                        // TODO: Google 로그인 구현
                        // 임시로 홈으로 이동
                        context.go('/');
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: PixelButton(
                      text: '게스트로 시작',
                      isLarge: true,
                      onPressed: () {
                        // TODO: 익명 로그인 구현
                        // 임시로 홈으로 이동
                        context.go('/');
                      },
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
}