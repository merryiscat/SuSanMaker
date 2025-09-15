import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';
import 'app_router.dart';
import 'constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (플랫폼별 옵션 사용)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 위치 권한 초기 요청
  await _requestLocationPermission();

  runApp(
    const ProviderScope(
      child: RanSanMakerApp(),
    ),
  );
}

/// 앱 시작 시 위치 권한 요청
Future<void> _requestLocationPermission() async {
  try {
    // 위치 서비스 활성화 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('위치 서비스가 비활성화되어 있습니다.');
      return;
    }

    // 현재 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();

    // 권한이 거부된 경우에만 요청
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('위치 권한이 거부되었습니다.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('위치 권한이 영구적으로 거부되었습니다. 설정에서 수동으로 권한을 허용해주세요.');
      return;
    }

    print('위치 권한 허용됨: $permission');
  } catch (e) {
    print('위치 권한 요청 중 오류 발생: $e');
  }
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

