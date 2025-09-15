import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/pixel_button.dart';
import '../services/auth_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;

  /// Google 로그인 처리
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null && mounted) {
        // 로그인 성공 시 홈으로 이동
        context.go('/');
      } else if (mounted) {
        // 로그인 실패 시 에러 메시지
        _showErrorDialog('Google 로그인에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('로그인 중 오류가 발생했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 익명 로그인 처리
  Future<void> _handleAnonymousLogin() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInAnonymously();

      if (userCredential != null && mounted) {
        // 로그인 성공 시 홈으로 이동
        context.go('/');
      } else if (mounted) {
        // 로그인 실패 시 에러 메시지
        _showErrorDialog('게스트 로그인에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('로그인 중 오류가 발생했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          '오류',
          style: TextStyle(color: AppColors.onSurface),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

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
                      text: _isLoading ? '로그인 중...' : 'Google로 로그인',
                      isLarge: true,
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: PixelButton(
                      text: _isLoading ? '로그인 중...' : '게스트로 시작',
                      isLarge: true,
                      onPressed: _isLoading ? null : _handleAnonymousLogin,
                    ),
                  ),

                  if (_isLoading) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}