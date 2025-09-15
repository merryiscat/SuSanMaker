import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/walk_setup_screen.dart';
import 'screens/walk_tracking_screen.dart';
import 'screens/walk_result_screen.dart';
import 'screens/gacha_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/firebase_test_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // 인증 화면
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      
      // 홈 화면
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // 산책 설정 화면
      GoRoute(
        path: '/walk-setup',
        builder: (context, state) => const WalkSetupScreen(),
      ),
      
      // 산책 추적 화면
      GoRoute(
        path: '/walk-tracking',
        builder: (context, state) => const WalkTrackingScreen(),
      ),
      
      // 산책 결과 화면
      GoRoute(
        path: '/walk-result',
        builder: (context, state) => WalkResultScreen(
          walkData: state.extra as Map<String, dynamic>?,
        ),
      ),
      
      // 가챠 화면
      GoRoute(
        path: '/gacha',
        builder: (context, state) => const GachaScreen(),
      ),
      
      // 옷장 화면
      GoRoute(
        path: '/wardrobe',
        builder: (context, state) => const WardrobeScreen(),
      ),

      // Firebase 테스트 화면 (개발용)
      GoRoute(
        path: '/firebase-test',
        builder: (context, state) => const FirebaseTestScreen(),
      ),
    ],
    
    // 에러 페이지
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('페이지를 찾을 수 없습니다'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
}