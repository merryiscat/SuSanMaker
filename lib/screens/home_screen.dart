import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/pixel_button.dart';
import '../widgets/avatar_renderer.dart';
import '../models/gacha_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _cloudController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _cloudController.repeat();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 배경 구름들
          _buildClouds(),
          
          // 메인 콘텐츠
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // 로고 영역 (나중에 실제 로고로 교체)
                  Text(
                    '랜덤 산책로 메이커',
                    style: TextStyle(
                      color: AppColors.pixelWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 3),
                  
                  // 메인 버튼들
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        PixelButton(
                          text: '산책 시작하기',
                          isLarge: true,
                          onPressed: () => context.push('/walk-setup'),
                        ),
                        const SizedBox(height: 16),
                        PixelButton(
                          text: '기록 보기',
                          isLarge: true,
                          onPressed: () {
                            // TODO: 기록 화면 구현 예정
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 4),
                  
                  // 아바타 캐릭터
                  AvatarRenderer(
                    equippedItems: const <ItemSlot, String?>{
                      // 기본 상태: 아무 아이템도 장착하지 않음
                      ItemSlot.headwear: null,
                      ItemSlot.shirt: null,
                      ItemSlot.pants: null,
                      ItemSlot.shoes: null,
                      ItemSlot.accessory: null,
                      ItemSlot.effect: null,
                    },
                    size: 200.0,
                    showPlaceholder: true, // 개발 중이므로 플레이스홀더 표시
                  ),
                  
                  const Spacer(flex: 4),
                  
                  // 보조 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PixelButton(
                        text: '상점',
                        icon: Icons.store,
                        onPressed: () => context.push('/gacha'),
                      ),
                      PixelButton(
                        text: '옷장',
                        icon: Icons.checkroom,
                        onPressed: () => context.push('/wardrobe'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 개발용 테스트 버튼 (임시)
                  PixelButton(
                    text: '🔧 Firebase 테스트',
                    onPressed: () => context.push('/firebase-test'),
                  ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClouds() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        return Stack(
          children: [
            _buildCloud(
              top: 80,
              animation: _cloudController,
              duration: 60,
              width: 60,
              height: 30,
            ),
            _buildCloud(
              top: 160,
              animation: _cloudController,
              duration: 45,
              width: 80,
              height: 40,
              delay: 0.3,
            ),
            _buildCloud(
              top: 240,
              animation: _cloudController,
              duration: 70,
              width: 50,
              height: 25,
              delay: 0.6,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCloud({
    required double top,
    required AnimationController animation,
    required int duration,
    required double width,
    required double height,
    double delay = 0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final animationWithDelay = Tween<double>(
      begin: -width,
      end: screenWidth + width,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          delay,
          1.0,
          curve: Curves.linear,
        ),
      ),
    );

    return Positioned(
      top: top,
      left: animationWithDelay.value,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.pixelDarkGray.withOpacity(0.3),
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}