# 랜덤 산책로 메이커 - 실제 구현 가이드

design.md의 아키텍처 설계를 바탕으로 실제 개발을 위한 단계별 구현 가이드입니다.

## 📋 목차
1. [개발 환경 설정](#개발-환경-설정)
2. [Firebase 초기 설정](#firebase-초기-설정)
3. [화면별 구현 순서](#화면별-구현-순서)
4. [핵심 기능 구현 가이드](#핵심-기능-구현-가이드)
5. [테스트 및 배포](#테스트-및-배포)

---

## 🔧 개발 환경 설정

### 필수 도구
```bash
# Flutter SDK 설치 확인
flutter doctor

# 필요한 권한 설정 (android/app/src/main/AndroidManifest.xml)
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

# iOS 권한 설정 (ios/Runner/Info.plist)
<key>NSLocationWhenInUseUsageDescription</key>
<string>산책 경로 추적을 위해 위치 정보가 필요합니다</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>산책 중 실시간 위치 추적을 위해 위치 정보가 필요합니다</string>
```

### 패키지 의존성 확인
```yaml
# pubspec.yaml에서 확인해야 할 주요 패키지들
dependencies:
  # 상태 관리
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  
  # Firebase
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.5.0
  
  # 위치 서비스
  geolocator: ^13.0.2
  permission_handler: ^11.4.0
  
  # 네트워킹
  dio: ^5.9.0
```

---

## 🔥 Firebase 초기 설정

### 1. Firebase 프로젝트 생성
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# Firebase 프로젝트 초기화
firebase init
```

### 2. Flutter 프로젝트와 Firebase 연결
```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 프로젝트와 연결
flutterfire configure
```

### 3. Firestore 보안 규칙 설정
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자는 자신의 데이터만 읽기/쓰기 가능
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // 사용자 인벤토리
      match /inventory/{inventoryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // 산책 기록은 작성자만 읽기/쓰기 가능
    match /walks/{walkId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // 아이템 마스터 데이터는 모든 사용자가 읽기 가능
    match /items/{itemId} {
      allow read: if request.auth != null;
    }
  }
}
```

---

## 📱 화면별 구현 순서

### Phase 1: 기본 인프라 (1-2주)

#### 1.1 인증 시스템 구현
```dart
// lib/screens/auth_screen.dart 생성
class AuthScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Google/Apple 소셜 로그인 구현
    // Firebase Authentication 연동
  }
}
```

#### 1.2 네비게이션 구조 설정
```dart
// lib/app_router.dart 생성
class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => AuthScreen()),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/walk-setup', builder: (context, state) => WalkSetupScreen()),
      // ... 다른 화면들
    ],
  );
}
```

#### 1.3 사용자 프로필 관리
```dart
// lib/providers/user_provider.dart 수정
@riverpod
Stream<User?> currentUser(CurrentUserRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
Future<UserProfile?> userProfile(UserProfileRef ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return null;
  
  // Firestore에서 사용자 프로필 가져오기
  final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();
    
  return doc.exists ? UserProfile.fromJson(doc.data()!) : null;
}
```

### Phase 2: 핵심 산책 기능 (2-3주)

#### 2.1 산책 설정 화면
```dart
// lib/screens/walk_setup_screen.dart 생성
class WalkSetupScreen extends ConsumerStatefulWidget {
  @override
  _WalkSetupScreenState createState() => _WalkSetupScreenState();
}

class _WalkSetupScreenState extends ConsumerState<WalkSetupScreen> {
  double _distance = 1.0; // km
  int _duration = 30; // minutes
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('산책 설정')),
      body: Column(
        children: [
          // 거리 설정 슬라이더
          Slider(
            value: _distance,
            min: 0.5,
            max: 10.0,
            divisions: 19,
            onChanged: (value) => setState(() => _distance = value),
          ),
          
          // 시간 설정 슬라이더
          Slider(
            value: _duration.toDouble(),
            min: 10,
            max: 120,
            divisions: 22,
            onChanged: (value) => setState(() => _duration = value.round()),
          ),
          
          // 경로 생성 버튼
          ElevatedButton(
            onPressed: _generateRoute,
            child: Text('경로 생성하기'),
          ),
        ],
      ),
    );
  }
  
  void _generateRoute() {
    // 섹션 2.2의 무작위 경로 생성 알고리즘 호출
    ref.read(routeProviderProvider.notifier).generateRoute(
      distance: _distance,
      duration: _duration,
    );
    
    // 경로 미리보기 화면으로 이동
    context.push('/route-preview');
  }
}
```

#### 2.2 경로 생성 알고리즘 구현
```dart
// lib/services/route_generation_service.dart 수정/확장
class RouteGenerationService {
  final Dio _dio = Dio();
  
  Future<GeneratedRoute> generateRandomRoute({
    required LatLng startPoint,
    required double targetDistance, // km
  }) async {
    // 1. 목표 반경 계산 (목표 거리의 약 30%)
    final radius = targetDistance * 0.3 * 1000; // meters
    
    // 2. 무작위 경유지 생성 (2-3개)
    final waypoints = _generateRandomWaypoints(startPoint, radius, 3);
    
    // 3. TMap API 호출하여 실제 경로 계산
    final route = await _calculateRoute(startPoint, waypoints);
    
    // 4. 거리 검증 및 조정
    if (_isDistanceAcceptable(route.totalDistance, targetDistance)) {
      return route;
    } else {
      // 재귀적으로 다시 시도 (최대 5회)
      return generateRandomRoute(
        startPoint: startPoint, 
        targetDistance: targetDistance
      );
    }
  }
  
  List<LatLng> _generateRandomWaypoints(LatLng center, double radius, int count) {
    final random = Random();
    final waypoints = <LatLng>[];
    
    for (int i = 0; i < count; i++) {
      // 무작위 각도와 거리 생성
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * radius;
      
      // 새로운 좌표 계산
      final lat = center.latitude + (distance * cos(angle)) / 111320;
      final lng = center.longitude + (distance * sin(angle)) / (111320 * cos(center.latitude * pi / 180));
      
      waypoints.add(LatLng(lat, lng));
    }
    
    return waypoints;
  }
  
  Future<GeneratedRoute> _calculateRoute(LatLng start, List<LatLng> waypoints) async {
    // TMap API 호출 구현
    // 또는 Google Directions API 호출
    final response = await _dio.post(
      'https://apis.openapi.sk.com/tmap/routes/pedestrian',
      data: {
        'startX': start.longitude,
        'startY': start.latitude,
        'endX': start.longitude, // 시작점으로 돌아옴
        'endY': start.latitude,
        'passList': waypoints.map((w) => '${w.longitude},${w.latitude}').join('_'),
      },
      options: Options(headers: {'appKey': 'YOUR_TMAP_API_KEY'}),
    );
    
    // 응답 파싱하여 GeneratedRoute 객체 생성
    return GeneratedRoute.fromTMapResponse(response.data);
  }
}
```

#### 2.3 실시간 산책 추적 화면
```dart
// lib/screens/walk_tracking_screen.dart 생성
class WalkTrackingScreen extends ConsumerStatefulWidget {
  final GeneratedRoute route;
  
  const WalkTrackingScreen({required this.route});
  
  @override
  _WalkTrackingScreenState createState() => _WalkTrackingScreenState();
}

class _WalkTrackingScreenState extends ConsumerState<WalkTrackingScreen> {
  StreamSubscription<Position>? _positionStream;
  final List<LatLng> _userPath = [];
  late DateTime _startTime;
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startLocationTracking();
  }
  
  void _startLocationTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터마다 업데이트
      ),
    ).listen((Position position) {
      setState(() {
        _userPath.add(LatLng(position.latitude, position.longitude));
      });
      
      // 경로 준수 검증
      _validateRouteCompliance(position);
    });
  }
  
  void _validateRouteCompliance(Position position) {
    // 섹션 2.3의 맵 매칭 알고리즘 구현
    final currentLocation = LatLng(position.latitude, position.longitude);
    final distanceToRoute = _calculateDistanceToRoute(currentLocation, widget.route.polyline);
    
    if (distanceToRoute > 50) { // 50미터 이상 벗어남
      _showRouteDeviationWarning();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도 위젯 (Google Maps 또는 네이버 지도)
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.route.startPoint,
              zoom: 15,
            ),
            polylines: {
              // 원래 경로
              Polyline(
                polylineId: PolylineId('original_route'),
                points: widget.route.polyline,
                color: Colors.blue,
                width: 5,
              ),
              // 사용자 이동 경로
              Polyline(
                polylineId: PolylineId('user_path'),
                points: _userPath,
                color: Colors.red,
                width: 3,
              ),
            },
          ),
          
          // 상단 통계 표시
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('시간', _formatDuration(DateTime.now().difference(_startTime))),
                    _buildStat('거리', '${_calculateTotalDistance().toStringAsFixed(1)}km'),
                    _buildStat('속도', '${_calculateCurrentSpeed().toStringAsFixed(1)}km/h'),
                  ],
                ),
              ),
            ),
          ),
          
          // 하단 종료 버튼
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _finishWalk,
              child: Text('산책 종료'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _finishWalk() async {
    _positionStream?.cancel();
    
    // 산책 데이터 생성
    final walkData = Walk(
      userId: ref.read(currentUserProvider).value!.uid,
      completedAt: DateTime.now(),
      requestedDistance: widget.route.distance,
      actualDistance: _calculateTotalDistance(),
      durationSeconds: DateTime.now().difference(_startTime).inSeconds,
      routePolyline: encodePolyline(widget.route.polyline),
      userPath: _userPath,
    );
    
    // Firestore에 저장
    await ref.read(firestoreServiceProvider).saveWalk(walkData);
    
    // 포인트 계산 및 지급
    final points = ref.read(gamificationServiceProvider).calculatePoints(walkData);
    await ref.read(firestoreServiceProvider).addPoints(walkData.userId, points);
    
    // 결과 화면으로 이동
    context.pushReplacement('/walk-result', extra: walkData);
  }
}
```

### Phase 3: 게임화 시스템 (2주)

#### 3.1 산책 결과 및 포인트 화면
```dart
// lib/screens/walk_result_screen.dart 생성
class WalkResultScreen extends ConsumerWidget {
  final Walk walkData;
  
  const WalkResultScreen({required this.walkData});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.read(gamificationServiceProvider).calculatePoints(walkData);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 축하 메시지
              Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.celebration, size: 80, color: Colors.yellow),
                    SizedBox(height: 16),
                    Text(
                      '산책 완료!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 통계 카드들
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(20),
                  children: [
                    _buildStatCard('거리', '${walkData.actualDistance.toStringAsFixed(1)}km', Icons.straighten),
                    _buildStatCard('시간', _formatDuration(walkData.durationSeconds), Icons.timer),
                    _buildStatCard('평균 속도', '${(walkData.actualDistance / (walkData.durationSeconds / 3600)).toStringAsFixed(1)}km/h', Icons.speed),
                    _buildStatCard('획득 포인트', '$points P', Icons.stars),
                  ],
                ),
              ),
              
              // 액션 버튼들
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/gacha'),
                        icon: Icon(Icons.casino),
                        label: Text('포인트 사용하기!'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(16),
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.go('/home'),
                        child: Text('홈으로 돌아가기'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.all(16),
                        ),
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
```

#### 3.2 가챠 시스템 구현
```dart
// lib/screens/gacha_screen.dart 생성
class GachaScreen extends ConsumerStatefulWidget {
  @override
  _GachaScreenState createState() => _GachaScreenState();
}

class _GachaScreenState extends ConsumerState<GachaScreen> with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _revealController;
  GachaItem? _revealedItem;
  bool _isSpinning = false;
  
  static const int GACHA_COST = 100; // 포인트
  
  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _revealController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final userPoints = ref.watch(userProfileProvider).value?.pointsBalance ?? 0;
    final canAfford = userPoints >= GACHA_COST;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('가챠'),
        actions: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.stars, color: Colors.yellow),
                SizedBox(width: 4),
                Text('$userPoints P'),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 가챠 머신 애니메이션
          Expanded(
            flex: 2,
            child: Center(
              child: AnimatedBuilder(
                animation: _spinController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinController.value * 2 * pi * 5, // 5바퀴 회전
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.purple.shade300, Colors.blue.shade600],
                        ),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Icon(
                        Icons.casino,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // 아이템 공개 영역
          Expanded(
            child: _revealedItem != null 
              ? _buildRevealedItem(_revealedItem!)
              : Container(),
          ),
          
          // 뽑기 버튼
          Padding(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canAfford && !_isSpinning ? _performGacha : null,
                child: _isSpinning 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('${GACHA_COST}P로 뽑기!'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                  backgroundColor: canAfford ? Colors.purple : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _performGacha() async {
    setState(() => _isSpinning = true);
    
    // 포인트 차감
    await ref.read(firestoreServiceProvider).deductPoints(
      ref.read(currentUserProvider).value!.uid, 
      GACHA_COST
    );
    
    // 애니메이션 시작
    _spinController.reset();
    _spinController.forward();
    
    // 가챠 결과 계산 (섹션 3.2의 확률 시스템)
    final item = ref.read(gachaServiceProvider).performGacha();
    
    // 스핀 애니메이션 완료 후 아이템 공개
    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _revealedItem = item;
          _isSpinning = false;
        });
        
        // 아이템을 사용자 인벤토리에 추가
        ref.read(firestoreServiceProvider).addItemToInventory(
          ref.read(currentUserProvider).value!.uid,
          item.itemId,
        );
        
        // 공개 애니메이션 시작
        _revealController.reset();
        _revealController.forward();
      }
    });
  }
  
  Widget _buildRevealedItem(GachaItem item) {
    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, child) {
        return Transform.scale(
          scale: _revealController.value,
          child: Card(
            color: _getRarityColor(item.rarity),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이템 이미지
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // TODO: 실제 아이템 이미지 표시
                    child: Icon(Icons.checkroom, size: 40),
                  ),
                  SizedBox(height: 12),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    item.rarity,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Common': return Colors.grey;
      case 'Uncommon': return Colors.green;
      case 'Rare': return Colors.blue;
      case 'Epic': return Colors.purple;
      case 'Legendary': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
```

#### 3.3 아바타 꾸미기 화면
```dart
// lib/screens/wardrobe_screen.dart 생성
class WardrobeScreen extends ConsumerStatefulWidget {
  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  String _selectedCategory = 'head';
  final List<String> _categories = ['head', 'body', 'accessory'];
  
  @override
  Widget build(BuildContext context) {
    final userInventory = ref.watch(userInventoryProvider);
    final equippedItems = ref.watch(userProfileProvider).value?.equippedItems ?? {};
    
    return Scaffold(
      appBar: AppBar(title: Text('옷장')),
      body: Row(
        children: [
          // 아바타 미리보기
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 아바타 렌더링
                  Container(
                    width: 150,
                    height: 200,
                    child: Stack(
                      children: [
                        // 기본 캐릭터
                        PixelCharacter(),
                        
                        // 장착된 아이템들 오버레이
                        ...equippedItems.entries.map((entry) {
                          return _buildEquippedItem(entry.key, entry.value);
                        }),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  Text(
                    '미리보기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          
          // 아이템 선택 패널
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // 카테고리 탭
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(_getCategoryName(category)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = category);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                // 아이템 그리드
                Expanded(
                  child: userInventory.when(
                    data: (inventory) {
                      final categoryItems = inventory
                          .where((item) => item.type == _selectedCategory)
                          .toList();
                      
                      return GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: categoryItems.length + 1, // +1 for "none" option
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "장착 해제" 옵션
                            return _buildItemCard(
                              null,
                              isEquipped: equippedItems[_selectedCategory] == null,
                              onTap: () => _unequipItem(_selectedCategory),
                            );
                          }
                          
                          final item = categoryItems[index - 1];
                          final isEquipped = equippedItems[_selectedCategory] == item.itemId;
                          
                          return _buildItemCard(
                            item,
                            isEquipped: isEquipped,
                            onTap: () => _equipItem(_selectedCategory, item.itemId),
                          );
                        },
                      );
                    },
                    loading: () => Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('오류 발생: $error')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildItemCard(GachaItem? item, {required bool isEquipped, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isEquipped ? Colors.blue.shade100 : Colors.white,
          border: Border.all(
            color: isEquipped ? Colors.blue : Colors.grey.shade300,
            width: isEquipped ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: item == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.clear, size: 30),
                Text('없음', style: TextStyle(fontSize: 12)),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO: 실제 아이템 이미지
                Icon(Icons.checkroom, size: 30),
                SizedBox(height: 4),
                Text(
                  item.name,
                  style: TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
      ),
    );
  }
  
  void _equipItem(String category, String itemId) async {
    await ref.read(firestoreServiceProvider).updateEquippedItem(
      ref.read(currentUserProvider).value!.uid,
      category,
      itemId,
    );
  }
  
  void _unequipItem(String category) async {
    await ref.read(firestoreServiceProvider).updateEquippedItem(
      ref.read(currentUserProvider).value!.uid,
      category,
      null,
    );
  }
}
```

---

## 🧪 테스트 및 배포

### 단위 테스트
```dart
// test/services/route_generation_test.dart
void main() {
  group('RouteGenerationService', () {
    late RouteGenerationService service;
    
    setUp(() {
      service = RouteGenerationService();
    });
    
    test('should generate waypoints within specified radius', () {
      final center = LatLng(37.5665, 126.9780); // 서울시청
      final radius = 1000.0; // 1km
      
      final waypoints = service.generateRandomWaypoints(center, radius, 3);
      
      expect(waypoints.length, equals(3));
      
      for (final waypoint in waypoints) {
        final distance = Geolocator.distanceBetween(
          center.latitude, center.longitude,
          waypoint.latitude, waypoint.longitude,
        );
        expect(distance, lessThanOrEqualTo(radius));
      }
    });
  });
}
```

### 통합 테스트
```dart
// integration_test/app_test.dart
void main() {
  group('App Integration Tests', () {
    testWidgets('complete walk flow', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // 로그인
      await tester.tap(find.byKey(Key('google_login_button')));
      await tester.pumpAndSettle();
      
      // 산책 시작
      await tester.tap(find.text('산책 시작하기'));
      await tester.pumpAndSettle();
      
      // 거리 설정
      await tester.drag(find.byType(Slider).first, Offset(100, 0));
      await tester.pumpAndSettle();
      
      // 경로 생성
      await tester.tap(find.text('경로 생성하기'));
      await tester.pumpAndSettle();
      
      // 추가 테스트 로직...
    });
  });
}
```

### 배포 설정
```yaml
# android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 21  // 위치 서비스를 위한 최소 버전
        targetSdkVersion 34
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            proguard-android-optimize.txt'
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## 📝 다음 단계

1. **Phase 1 완료 후**: 기본 로그인과 네비게이션이 동작하는지 확인
2. **Phase 2 완료 후**: 실제 위치에서 경로 생성 및 추적 테스트
3. **Phase 3 완료 후**: 전체 게임화 루프 테스트

각 Phase마다 실제 디바이스에서 테스트하여 위치 서비스와 Firebase 연동이 올바르게 작동하는지 확인하는 것이 중요합니다.