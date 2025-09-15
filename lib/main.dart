import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_router.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const RanSanMakerApp());
}

class RanSanMakerApp extends StatelessWidget {
  const RanSanMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 상태바 스타일 설정 (어두운 배경에 맞게)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp.router(
      title: '랜덤 산책로 메이커',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
          surface: AppColors.surface,
          onPrimary: AppColors.onPrimary,
          onBackground: AppColors.onBackground,
          onSurface: AppColors.onSurface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        fontFamily: 'monospace', // 픽셀 게임 느낌의 모노스페이스 폰트
      ),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
    );
  }
}

