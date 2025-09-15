import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/pixel_button.dart';
import '../widgets/avatar_renderer.dart';
import '../services/auth_service.dart';
import '../models/gacha_item.dart';

/// Firebase 연동 테스트를 위한 화면
class FirebaseTestScreen extends ConsumerStatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  ConsumerState<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends ConsumerState<FirebaseTestScreen> {
  String _testResult = '';
  bool _isLoading = false;
  final Map<ItemSlot, String?> _testEquippedItems = {
    ItemSlot.headwear: null,
    ItemSlot.shirt: null,
    ItemSlot.pants: null,
    ItemSlot.shoes: null,
    ItemSlot.accessory: null,
    ItemSlot.effect: null,
  };

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  /// Firebase 연결 상태 확인
  Future<void> _checkFirebaseConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Firebase 연결 확인 중...';
    });

    try {
      final authService = ref.read(authServiceProvider);

      // 현재 인증 상태 확인
      final isLoggedIn = authService.isLoggedIn;
      final userId = authService.userId;

      setState(() {
        _testResult = '''Firebase 연결 성공! ✅
현재 로그인 상태: ${isLoggedIn ? '로그인됨' : '로그인 안됨'}
사용자 ID: ${userId ?? '없음'}
프로젝트: ran-san-maker-test''';
      });

    } catch (e) {
      setState(() {
        _testResult = 'Firebase 연결 실패: $e ❌';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 익명 로그인 테스트
  Future<void> _testAnonymousLogin() async {
    setState(() {
      _isLoading = true;
      _testResult = '익명 로그인 시도 중...';
    });

    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInAnonymously();

      if (userCredential != null) {
        setState(() {
          _testResult = '''익명 로그인 성공! ✅
사용자 ID: ${userCredential.user?.uid}
생성 시간: ${userCredential.user?.metadata.creationTime}''';
        });
      } else {
        setState(() {
          _testResult = '익명 로그인 실패 ❌';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '익명 로그인 오류: $e ❌';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 로그아웃 테스트
  Future<void> _testLogout() async {
    setState(() {
      _isLoading = true;
      _testResult = '로그아웃 시도 중...';
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      setState(() {
        _testResult = '로그아웃 성공! ✅';
      });
    } catch (e) {
      setState(() {
        _testResult = '로그아웃 오류: $e ❌';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 아바타 시스템 테스트 (가상 아이템 장착)
  void _testAvatarSystem() {
    setState(() {
      if (_testEquippedItems[ItemSlot.headwear] == null) {
        _testEquippedItems[ItemSlot.headwear] = 'basic_cap';
        _testResult = '모자 장착 테스트 ✅\n(실제 이미지는 아직 없음)';
      } else if (_testEquippedItems[ItemSlot.shirt] == null) {
        _testEquippedItems[ItemSlot.shirt] = 'red_tshirt';
        _testResult = '티셔츠 장착 테스트 ✅\n(실제 이미지는 아직 없음)';
      } else {
        // 모든 아이템 해제
        _testEquippedItems.updateAll((key, value) => null);
        _testResult = '모든 아이템 해제 ✅';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 사용자 상태를 실시간으로 감시
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Firebase 테스트'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 아바타 테스트 섹션
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '아바타 시스템 테스트',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AvatarRenderer(
                      equippedItems: _testEquippedItems,
                      size: 150,
                      showPlaceholder: true,
                    ),
                    const SizedBox(height: 16),
                    PixelButton(
                      text: '아바타 테스트',
                      onPressed: _testAvatarSystem,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Firebase 상태 섹션
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Firebase 연결 상태',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 실시간 사용자 상태 표시
                    userAsync.when(
                      data: (user) => Text(
                        user != null
                          ? '✅ 로그인됨\nUID: ${user.uid.substring(0, 8)}...'
                          : '❌ 로그인 안됨',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text(
                        '오류: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 테스트 버튼들
              PixelButton(
                text: '연결 상태 확인',
                isLarge: true,
                onPressed: _isLoading ? null : _checkFirebaseConnection,
              ),

              const SizedBox(height: 12),

              PixelButton(
                text: '익명 로그인 테스트',
                isLarge: true,
                onPressed: _isLoading ? null : _testAnonymousLogin,
              ),

              const SizedBox(height: 12),

              PixelButton(
                text: '로그아웃 테스트',
                isLarge: true,
                onPressed: _isLoading ? null : _testLogout,
              ),

              const SizedBox(height: 16),

              // 테스트 결과 표시
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '테스트 결과',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoading
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('처리 중...'),
                            ],
                          )
                        : Text(
                            _testResult.isEmpty ? '테스트 버튼을 눌러보세요.' : _testResult,
                            style: TextStyle(
                              color: AppColors.onSurface.withOpacity(0.8),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}