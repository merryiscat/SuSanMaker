# 🎮 베이스 캐릭터 + 레이어링 시스템 설계

## 📋 설계 개요

**목표**: 525x525 도트 스타일 캐릭터 커스터마이징 시스템 구현  
**방식**: 대머리 알몸 베이스 캐릭터 + 아이템 레이어 오버레이  
**기술**: Flutter Stack 위젯 + PNG 이미지 레이어링

---

## 🏗️ 시스템 아키텍처

### 1. 베이스 캐릭터 (Base Character)

**사양**:
- 해상도: 525x525 픽셀
- 형태: 대머리, 알몸 상태
- 포즈: 정면 바라보기, 양팔 자연스럽게 내린 상태
- 스타일: 도트 스타일 일러스트
- 표정: 중성적 표정

**핵심 요구사항**:
- 완벽한 해부학적 구조와 비율
- 일관된 조명 (왼쪽 상단에서 오는 광원)
- 고정된 색상 팔레트
- 투명하지 않은 배경 (기본 배경색)

### 2. 레이어링 순서 (Z-Index)

```
Layer 6 (최상위): 이펙트 (Effect) - 오라, 파티클 등
Layer 5: 액세서리 (Accessory) - 안경, 목걸이, 지팡이 등  
Layer 4: 머리 (Headwear) - 모자, 헤어스타일
Layer 3: 상의 (Shirt) - 셔츠, 재킷
Layer 2: 하의 (Pants) - 바지, 치마
Layer 1: 신발 (Shoes) - 신발류
Layer 0 (베이스): 대머리 알몸 캐릭터
```

### 3. 파일 구조

```
assets/
├── characters/
│   └── base_character.png              (525x525, 베이스 캐릭터)
└── items/
    ├── headwear/
    │   ├── common_hat_001.png          (525x525, 투명 배경)
    │   ├── uncommon_cap_001.png        (525x525, 투명 배경)
    │   └── rare_helmet_001.png         (525x525, 투명 배경)
    ├── shirts/
    │   ├── common_shirt_001.png        (525x525, 투명 배경)
    │   └── rare_jacket_001.png         (525x525, 투명 배경)
    ├── pants/
    │   ├── common_pants_001.png        (525x525, 투명 배경)
    │   └── epic_shorts_001.png         (525x525, 투명 배경)
    ├── shoes/
    │   ├── common_sneakers_001.png     (525x525, 투명 배경)
    │   └── legendary_boots_001.png     (525x525, 투명 배경)
    ├── accessories/
    │   ├── common_glasses_001.png      (525x525, 투명 배경)
    │   └── epic_necklace_001.png       (525x525, 투명 배경)
    └── effects/
        ├── legendary_aura_001.png      (525x525, 투명 배경)
        └── epic_sparkles_001.png       (525x525, 투명 배경)
```

---

## 🎨 아트 가이드라인

### 1. 베이스 캐릭터 제작 기준

**색상 팔레트** (16색 제한):
```
피부톤: #FDB5A6, #F7A085, #E8956F
그림자: #D18B6E, #B8785A
하이라이트: #FFEEE6
```

**비율 및 사이즈**:
- 머리: 전체 높이의 25% (131px)
- 몸통: 전체 높이의 45% (236px) 
- 다리: 전체 높이의 30% (158px)
- 어깨 너비: 전체 너비의 35% (184px)

**필수 해부학 포인트** (아이템 정렬 기준점):
- 머리 중심점: (262, 65)
- 목 라인: Y=131
- 어깨 라인: Y=157, X=170~354
- 가슴 라인: Y=210
- 허리 라인: Y=262
- 엉덩이 라인: Y=315
- 무릎 라인: Y=420
- 발목 라인: Y=500

### 2. 아이템 제작 기준

**공통 요구사항**:
- 525x525 캔버스 크기 (베이스와 동일)
- PNG 형식, 투명 배경
- 베이스 캐릭터와 동일한 조명 방향
- 동일한 색상 팔레트 계열 사용
- 픽셀 퍼펙트 정렬

**슬롯별 가이드라인**:

**머리 (Headwear)**:
- 정렬 기준: 머리 중심점 (262, 65)
- 덮는 영역: 머리카락 전체 또는 일부
- 주의사항: 얼굴을 가리지 않도록

**상의 (Shirt)**:
- 정렬 기준: 어깨 라인 Y=157
- 덮는 영역: 어깨~허리/엉덩이
- 소매는 팔 전체를 덮을 수 있음

**하의 (Pants)**:
- 정렬 기준: 허리 라인 Y=262
- 덮는 영역: 허리~발목
- 베이스의 다리 부분을 완전히 덮어야 함

**신발 (Shoes)**:
- 정렬 기준: 발목 라인 Y=500
- 덮는 영역: 발 전체
- 베이스의 발 부분을 완전히 덮어야 함

**액세서리 (Accessory)**:
- 자유로운 위치
- 다른 아이템과 겹치지 않도록 주의
- 투명도 활용 가능

**이펙트 (Effect)**:
- 캐릭터 전체 둘러싸기 가능
- 반투명도 적극 활용
- 애니메이션 가능 (추후 구현)

---

## 💻 기술 구현

### 1. Flutter 위젯 구조

```dart
class AvatarRenderer extends StatelessWidget {
  final Map<ItemSlot, String?> equippedItems;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Layer 0: 베이스 캐릭터
          Image.asset(
            'assets/characters/base_character.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          
          // Layer 1: 신발
          if (equippedItems[ItemSlot.shoes] != null)
            Image.asset(
              'assets/items/shoes/${equippedItems[ItemSlot.shoes]}.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          
          // Layer 2: 하의
          if (equippedItems[ItemSlot.pants] != null)
            Image.asset(
              'assets/items/pants/${equippedItems[ItemSlot.pants]}.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          
          // Layer 3: 상의
          if (equippedItems[ItemSlot.shirt] != null)
            Image.asset(
              'assets/items/shirts/${equippedItems[ItemSlot.shirt]}.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          
          // Layer 4: 머리
          if (equippedItems[ItemSlot.headwear] != null)
            Image.asset(
              'assets/items/headwear/${equippedItems[ItemSlot.headwear]}.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          
          // Layer 5: 액세서리
          if (equippedItems[ItemSlot.accessory] != null)
            Image.asset(
              'assets/items/accessories/${equippedItems[ItemSlot.accessory]}.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          
          // Layer 6: 이펙트
          if (equippedItems[ItemSlot.effect] != null)
            Image.asset(
              'assets/items/effects/${equippedItems[ItemSlot.effect]}.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }
}
```

### 2. 아이템 모델 확장

```dart
class GachaItem {
  // 기존 필드들...
  
  /// 아이템 파일 경로 자동 생성
  String get assetPath {
    final slotFolder = _getSlotFolder(slot);
    return 'assets/items/$slotFolder/$itemId.png';
  }
  
  String _getSlotFolder(ItemSlot slot) {
    switch (slot) {
      case ItemSlot.headwear: return 'headwear';
      case ItemSlot.shirt: return 'shirts';
      case ItemSlot.pants: return 'pants';
      case ItemSlot.shoes: return 'shoes';
      case ItemSlot.accessory: return 'accessories';
      case ItemSlot.effect: return 'effects';
    }
  }
}
```

### 3. 성능 최적화

**이미지 캐싱**:
```dart
class AvatarImageCache {
  static final Map<String, ui.Image> _cache = {};
  
  static Future<ui.Image> getImage(String assetPath) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath]!;
    }
    
    final ImageStream stream = AssetImage(assetPath).resolve(ImageConfiguration.empty);
    final Completer<ui.Image> completer = Completer();
    late ImageStreamListener listener;
    
    listener = ImageStreamListener((ImageInfo info, bool _) {
      _cache[assetPath] = info.image;
      completer.complete(info.image);
      stream.removeListener(listener);
    });
    
    stream.addListener(listener);
    return completer.future;
  }
}
```

---

## 🤖 AI 생성 전략

### 1. 베이스 캐릭터 프롬프트

```
"Create a bald naked chibi character for mobile game avatar system, 
525x525 pixels, pixel art illustration style, front facing view, 
neutral expression, arms naturally at sides, anatomically correct proportions,
soft lighting from top-left, clean art style, vibrant but not oversaturated colors,
suitable for clothing layering system, mobile game quality"

Style: Pixel art, chibi, mobile game
Colors: Warm, friendly palette
Mood: Neutral, customizable base
Technical: 525x525, high resolution pixel art
```

### 2. 아이템별 프롬프트 템플릿

**머리 아이템**:
```
"[ITEM_DESCRIPTION] on the same bald character as reference, 
same exact pose and lighting, same art style, 525x525 pixels,
transparent background except for the [ITEM_TYPE],
pixel art illustration, mobile game avatar item,
perfectly aligned to cover head area only"

Examples:
- "Blue baseball cap on the same bald character..."
- "Long flowing hair on the same bald character..."  
- "Medieval helmet on the same bald character..."
```

**상의 아이템**:
```
"[ITEM_DESCRIPTION] on the same naked character as reference,
covers torso and arms, same exact pose and lighting,
transparent background except for the clothing,
525x525 pixels, pixel art illustration style"

Examples:
- "Red t-shirt on the same naked character..."
- "Business suit jacket on the same naked character..."
- "Medieval armor chest piece on the same naked character..."
```

### 3. 품질 관리 체크리스트

**AI 생성 후 확인사항**:
- [ ] 525x525 정확한 크기
- [ ] 투명 배경 (베이스 제외)
- [ ] 베이스 캐릭터와 일관된 조명
- [ ] 픽셀 퍼펙트 정렬 (중요 포인트들)
- [ ] 색상 팔레트 일관성
- [ ] 아이템이 적절한 영역만 덮음
- [ ] 다른 슬롯과의 호환성

---

## 🎯 구현 로드맵

### Phase 1: 베이스 시스템 구축
1. **베이스 캐릭터 완성** (최우선)
   - AI 생성 + 수동 보정
   - 해부학 포인트 정확한 마킹
   - 색상 팔레트 확정

2. **Flutter 렌더링 시스템**
   - `AvatarRenderer` 위젯 구현
   - Stack 레이어링 로직
   - 이미지 캐싱 시스템

3. **기본 아이템 세트** (각 슬롯 2-3개)
   - Common 등급 기본 아이템들
   - 레이어링 테스트 및 조정

### Phase 2: 아이템 확장
1. **AI 생성 파이프라인 구축**
   - 프롬프트 템플릿 완성
   - 배치 생성 워크플로우
   - 품질 검증 프로세스

2. **아이템 대량 생성**
   - 각 슬롯별 10-20개 아이템
   - 희귀도별 밸런스 조정
   - 가챠 시스템과 연동 테스트

### Phase 3: 고급 기능
1. **애니메이션 효과**
   - 이펙트 슬롯 애니메이션
   - 호버 효과
   - 트랜지션 애니메이션

2. **성능 최적화**
   - 이미지 압축 최적화
   - 메모리 관리 개선
   - 로딩 성능 향상

---

## 📊 예상 결과물

### 1. 파일 크기 및 성능
- 베이스 캐릭터: ~200KB (PNG)
- 일반 아이템: ~50-100KB (투명 PNG)
- 전체 앱 크기 증가: 100개 아이템 기준 ~8-10MB
- 렌더링 성능: 60fps 유지 가능

### 2. 가챠 매력도
- 시각적 임팩트: ⭐⭐⭐⭐⭐
- 조합 다양성: 6슬롯 × 평균 15개 = 11,390,625가지 조합
- 수집 욕구: 고해상도 아트로 프리미엄 느낌

### 3. 개발 효율성
- 베이스 제작: 1-2주 (초기 투자)
- 아이템 생성: 1개당 30분-1시간
- 유지보수: 새 아이템 추가 용이

---

## ⚠️ 리스크 및 대응책

### 1. AI 생성 품질 이슈
**리스크**: 아이템별 스타일 불일치  
**대응**: 엄격한 품질 체크리스트 + 수동 보정 예산 확보

### 2. 레이어링 문제
**리스크**: 아이템 간 겹침/충돌  
**대응**: 해부학 포인트 기준 엄격한 가이드라인

### 3. 파일 크기 증가
**리스크**: 앱 크기 과도한 증가  
**대응**: 이미지 압축 최적화 + 필요시 다운로드 방식

---

## 💡 추후 확장 가능성

1. **다양한 베이스 캐릭터**
   - 남성/여성 버전
   - 다양한 체형
   - 동물 캐릭터

2. **고급 커스터마이징**
   - 피부색 변경
   - 표정 변경
   - 포즈 변형

3. **소셜 기능**
   - 아바타 공유
   - 룩북 시스템
   - 커뮤니티 투표

---

이 설계를 기반으로 525x525 도트 스타일 아바타 시스템을 성공적으로 구현할 수 있을 것입니다! 🎮✨