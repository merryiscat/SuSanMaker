
# 랜덤 산책로 메이커 - 프로젝트 마스터 가이드

## 📋 문서 개요

이 프로젝트는 **게임화된 산책 애플리케이션 "랜덤 산책로 메이커"**를 개발하기 위한 종합적인 가이드 모음입니다. 각 문서는 개발의 특정 단계와 측면을 다룹니다.

## 📚 문서 구조 및 사용 가이드

### 🎯 `design.md` - 마스터 설계 문서
**언제 참고:** 프로젝트 전체 비전과 아키텍처를 이해할 때
- **내용**: 완전한 아키텍처 설계서, 기술 스택 선택 이유, 게임화 시스템 설계
- **사용 시점**: 프로젝트 시작 전, 주요 설계 결정이 필요할 때, AI에게 컨텍스트를 제공할 때
- **대상**: 아키텍트, 제품 기획자, 개발팀 전체

### 🚀 `DEVELOPMENT_ROADMAP.md` - 개발 일정 및 우선순위
**언제 참고:** 개발 순서와 일정을 계획할 때
- **내용**: 10주 개발 계획, 주차별 목표, 기능별 우선순위 (P0~P3)
- **사용 시점**: 스프린트 계획, 다음 작업 선택, 진행상황 체크
- **대상**: 개발자, 프로젝트 매니저, 스크럼 마스터

### 🔧 `IMPLEMENTATION_GUIDE.md` - 상세 구현 가이드
**언제 참고:** 실제 코드를 작성할 때
- **내용**: 환경 설정, 화면별 구현 방법, 구체적인 코드 예시
- **사용 시점**: 개발 환경 구축, 새로운 기능 구현, 코드 작성
- **대상**: 프론트엔드 개발자, Flutter 개발자

### 🔥 `FIREBASE_SETUP_GUIDE.md` - Firebase 연동 완전 가이드
**언제 참고:** 백엔드 설정과 Firebase 연동 시
- **내용**: Firebase 프로젝트 생성, 인증 설정, Firestore 스키마, 보안 규칙
- **사용 시점**: 백엔드 설정, 인증 구현, 데이터베이스 연동
- **대상**: 백엔드 개발자, 풀스택 개발자, DevOps

## 🎯 핵심 콘셉트

**"랜덤 산책로 메이커"**는 평범한 산책을 탐험과 수집이라는 보상 기반의 게임으로 전환하는 앱입니다. 사용자는 원하는 거리나 시간을 입력하여 현재 위치 기반의 무작위 산책로를 생성하고, 이를 완주하여 획득한 포인트로 도트 캐릭터를 꾸미는 가챠(Gacha) 시스템을 즐길 수 있습니다.

## 🎯 시장 분석 및 목표 고객

캐주얼 피트니스 및 "라이프스타일 게임화" 시장에 위치하며, Strava 같은 성과 중심 앱이나 "The Walk" 같은 서사 중심 게임과 차별화됩니다. 주요 타겟은 게임화 요소를 선호하고 진입 장벽이 낮은 운동을 찾는 Z세대와 젊은 밀레니얼 세대(20-40세)입니다.

## 🏗 아키텍처 철학

- **신속한 MVP 개발**: 핵심 기능 우선, 빠른 시장 진입
- **확장성**: 소셜, 이벤트 등 향후 기능 추가 용이성
- **게임화 루프**: 지속적 참여를 위한 견고한 보상 시스템
- **AI 개발 워크플로**: 개발 효율성 극대화

## 📖 문서 사용 시나리오

### 🔄 개발 시작 시
1. **`design.md`** 읽고 전체 비전 이해
2. **`DEVELOPMENT_ROADMAP.md`**로 현재 단계 파악
3. **`FIREBASE_SETUP_GUIDE.md`**로 환경 구축
4. **`IMPLEMENTATION_GUIDE.md`**로 코드 작성 시작

### 🎯 특정 기능 개발 시
1. **`design.md`**에서 해당 섹션 참고 (예: 섹션 2.2 경로 생성)
2. **`IMPLEMENTATION_GUIDE.md`**에서 구체적 구현 방법 확인
3. **`DEVELOPMENT_ROADMAP.md`**에서 우선순위와 종속성 체크

### 🐛 문제 해결 시
1. **`FIREBASE_SETUP_GUIDE.md`**에서 설정 문제 해결
2. **`design.md`**에서 원래 의도된 동작 확인
3. **`IMPLEMENTATION_GUIDE.md`**에서 구현 세부사항 검토

### 🤖 AI와 협업 시
1. **`design.md`**의 해당 섹션을 AI에게 컨텍스트로 제공
2. **`IMPLEMENTATION_GUIDE.md`**의 코드 예시 활용
3. 구체적인 요구사항과 함께 AI에게 코드 생성 요청

## 🔧 기술 스택 요약

- **프레임워크**: Flutter (크로스플랫폼)
- **상태 관리**: Riverpod
- **백엔드**: Firebase (Authentication, Firestore, Storage)
- **지도 서비스**: TMap API (한국) / Google Maps (글로벌)
- **위치 서비스**: Geolocator 패키지

## 🚀 MVP 핵심 기능

1. **사용자 인증** (Google/Apple 소셜 로그인)
2. **무작위 경로 생성** (거리/시간 기반)
3. **실시간 산책 추적** (GPS 위치 기반)
4. **포인트 시스템** (산책 완료 시 보상)
5. **가챠 시스템** (포인트로 아이템 뽑기)
6. **아바타 꾸미기** (수집한 아이템 장착)

## 📊 현재 진행 상황

- ✅ 기본 UI 구조 및 픽셀 아트 스타일
- ✅ 데이터 모델 정의 (User, Walk, GachaItem 등)
- ✅ Firebase 설정 파일
- ✅ Riverpod Provider 구조
- ❌ 화면 간 네비게이션 (다음 작업)
- ❌ Firebase 실제 연동
- ❌ 핵심 기능 구현

## 🏃‍♂️ 빠른 시작 가이드

다음 단계를 따라 개발을 시작하세요:

### 1️⃣ 즉시 할 수 있는 작업 (15분)
```bash
# 네비게이션 패키지 추가
flutter pub add go_router

# 홈 화면 버튼들을 실제 화면으로 연결
# home_screen.dart의 TODO 주석들을 다음과 같이 변경:
onPressed: () => context.push('/walk-setup')
```

### 2️⃣ 이번 주 목표
- [ ] **네비게이션 시스템** 구축 (모든 화면 간 이동)
- [ ] **Firebase 인증** 설정 및 로그인 화면
- [ ] **기본 Firestore** 연동 (사용자 프로필 CRUD)

### 3️⃣ 다음 주 목표
- [ ] **산책 설정 화면** (거리/시간 슬라이더)
- [ ] **경로 생성 알고리즘** (TMap API 연동)
- [ ] **위치 추적 기능** (GPS 권한 및 실시간 추적)

## 📋 AI 협업 가이드

### 🤖 효과적인 AI 프롬프트 예시

**모델 생성 시:**
```
design.md 섹션 4.1의 Firestore 스키마를 기반으로, 
fromJson/toJson 메서드를 포함한 User 모델의 Dart 클래스를 생성해줘.
```

**UI 구현 시:**
```
IMPLEMENTATION_GUIDE.md의 산책 설정 화면 예시를 참고하여,
거리(0.5-10km)와 시간(10-120분) 슬라이더가 있는 Flutter 화면을 만들어줘.
```

**Firebase 연동 시:**
```
FIREBASE_SETUP_GUIDE.md의 Firestore 서비스 코드를 참고하여,
사용자 프로필을 생성/업데이트하는 FirestoreService 클래스를 만들어줘.
```

## 📊 주요 섹션별 참고 가이드

- **섹션 1**: 기술 스택 선택 이유 → Flutter, Riverpod, Firebase
- **섹션 2**: 경로 생성 & 추적 → TMap API, GPS 매칭 알고리즘
- **섹션 3**: 게임화 시스템 → 포인트, 가챠, 아바타 시스템
- **섹션 4**: 데이터 구조 → Firestore 스키마 설계
- **섹션 5**: 사용자 경험 → 화면 흐름, UI 설계
- **섹션 6**: AI 개발 전략 → Claude 활용 방법

## 🎯 MVP 완성까지의 경로

1. **Week 1-2**: 네비게이션 + Firebase 인증
2. **Week 3-4**: 경로 생성 + 위치 추적
3. **Week 5-6**: 산책 기록 + 포인트 시스템
4. **Week 7-8**: 가챠 시스템 + UI 개선
5. **Week 9-10**: 아바타 꾸미기 + 최종 테스트

---

*상세한 내용은 각각의 전용 가이드 문서를 참고하세요.*
The Walk: Fitness Game - Apps on Google Play, 9월 10, 2025에 액세스, https://play.google.com/store/apps/details?id=com.sixtostart.thewalk2
Can gamification increases consumers' engagement in fitness apps? The moderating role of commensurability of the game elements | Request PDF - ResearchGate, 9월 10, 2025에 액세스, https://www.researchgate.net/publication/343585958_Can_gamification_increases_consumers'_engagement_in_fitness_apps_The_moderating_role_of_commensurability_of_the_game_elements
How Gamification Affects Physical Activity: Large-scale Analysis of Walking Challenges in a Mobile Application, 9월 10, 2025에 액세스, https://pmc.ncbi.nlm.nih.gov/articles/PMC5627651/
7 Must-have Flutter Plugins for App Development in 2025 - Synergy Labs, 9월 10, 2025에 액세스, https://www.synergylabs.co/blog/7-must-have-flutter-plugins-for-app-development-in-2025
Why Flutter is the Best Framework for App Development in 2025 | by iRoid Solutions, 9월 10, 2025에 액세스, https://medium.com/@blog.iroidsolutions/why-flutter-is-the-best-framework-for-app-development-in-2025-e0931cc9e224
Flutter Development Tools That Power High-Performance Apps in 2025, 9월 10, 2025에 액세스, https://www.moweb.com/blog/flutter-development-tools
Comparing Flutter State Management Libraries: Provider, BLoC, Riverpod, and GetX, 9월 10, 2025에 액세스, https://vibe-studio.ai/insights/comparing-flutter-state-management-libraries-provider-bloc-riverpod-and-getx
Top Flutter State Management Packages in 2025 - DhiWise, 9월 10, 2025에 액세스, https://www.dhiwise.com/post/top-flutter-state-management-packages-2023
Flutter State Management: Provider vs Riverpod vs Bloc | by Punith S Uppar | Medium, 9월 10, 2025에 액세스, https://medium.com/@punithsuppar7795/flutter-state-management-provider-vs-riverpod-vs-bloc-557938a3d54e
Top Flutter State Management Packages of 2025 - iCoderz Solutions, 9월 10, 2025에 액세스, https://www.icoderzsolutions.com/blog/flutter-state-management-packages/
Flutter: Top 7 Packages for 2025 | by Fabrício Ferreira da Silva | Medium, 9월 10, 2025에 액세스, https://medium.com/@fabricio-ferreira/flutter-top-7-packages-for-2025-162fcdd5ca21
Top Open Source Packages Every Flutter Developer Should Know in 2025, 9월 10, 2025에 액세스, https://www.verygood.ventures/blog/top-open-source-packages-every-flutter-developer-should-know-in-2025
Choosing between Amazon Amplify and Firebase for Flutter Apps - Walturn, 9월 10, 2025에 액세스, https://www.walturn.com/insights/choosing-between-amazon-amplify-and-firebase-for-flutter-apps
Firebase vs. AWS Amplify: A Practical Comparison for Flutter Development | by Akshat Arora, 9월 10, 2025에 액세스, https://blog.aatechax.com/firebase-vs-aws-amplify-a-practical-comparison-for-flutter-development-5d25b384f5c8
AWS Amplify vs Firebase for Flutter app as an indie developer ? : r/FlutterDev - Reddit, 9월 10, 2025에 액세스, https://www.reddit.com/r/FlutterDev/comments/16cdm0k/aws_amplify_vs_firebase_for_flutter_app_as_an/
Amplify vs. Firebase: A Head-to-Head Comparison With My Real Product | by Titus Efferian, 9월 10, 2025에 액세스, https://betterprogramming.pub/amplify-vs-firebase-a-head-to-head-comparison-with-a-real-product-b6fd76058416
AWS Amplify vs Firebase: Which is Best Suited for Your App Project?, 9월 10, 2025에 액세스, https://www.expertappdevs.com/blog/aws-amplify-vs-firebase
Firebase vs. AWS Amplify: Choosing the Best Backend for Your Flutter App, 9월 10, 2025에 액세스, https://www.businesscompassllc.com/firebase-vs-aws-amplify-choosing-the-best-backend-for-your-flutter-app/
Firestore | Firebase - Google, 9월 10, 2025에 액세스, https://firebase.google.com/docs/firestore
Top Flutter Map, Geolocation, Google Map, Apple Map packages | Flutter Gems, 9월 10, 2025에 액세스, https://fluttergems.dev/geolocation-maps/
geolocator | Flutter package - Pub.dev, 9월 10, 2025에 액세스, https://pub.dev/packages/geolocator
Enhance Location Services in Your Flutter Apps with the Geolocator Plugin | by Flutter News Hub | Medium, 9월 10, 2025에 액세스, https://medium.com/@flutternewshub/enhance-location-services-in-your-flutter-apps-with-the-geolocator-plugin-4af12926e0c7
보행자 경로 안내 - SK open API, 9월 10, 2025에 액세스, https://openapi.sk.com/products/detail?linkMenuSeq=45
보행자 경로안내 - ReadMe, 9월 10, 2025에 액세스, https://tmap-skopenapi.readme.io/reference/%EB%B3%B4%ED%96%89%EC%9E%90-%EA%B2%BD%EB%A1%9C%EC%95%88%EB%82%B4
[네이버 길찾기 API] Direction 5 API with Kotlin, Retrofit2 - 싸커프로그래밍 - 티스토리, 9월 10, 2025에 액세스, https://soccer-programming.tistory.com/40
[API] 보행자 경로 구현 (Tmap API) - 철's - 티스토리, 9월 10, 2025에 액세스, https://devchul.tistory.com/5
Directions API (Legacy) overview | Google for Developers, 9월 10, 2025에 액세스, https://developers.google.com/maps/documentation/directions/overview
Google Maps Platform Documentation | Routes API - Google for Developers, 9월 10, 2025에 액세스, https://developers.google.com/maps/documentation/routes
Blog: Announcing Routes API: the new enhanced version of the Directions and Distance Matrix APIs - Google Maps Platform, 9월 10, 2025에 액세스, https://mapsplatform.google.com/resources/blog/announcing-routes-api-new-enhanced-version-directions-and-distance-matrix-apis/
Platform Pricing & API Costs - Google Maps Platform, 9월 10, 2025에 액세스, https://mapsplatform.google.com/pricing/
Quota | Kakao Developers Docs, 9월 10, 2025에 액세스, https://developers.kakao.com/docs/latest/en/getting-started/quota
[Sponsored Report] Naver improves map API prices to rival Google - Korea JoongAng Daily, 9월 10, 2025에 액세스, https://koreajoongangdaily.joins.com/2019/02/21/nationalGuestReports/Sponsored-Report-Naver-improves-map-API-prices-to-rival-Google/3059720.html
How much does Google Maps API Cost? All Prices and Plans Explained - Promatics, 9월 10, 2025에 액세스, https://www.promaticsindia.com/blog/google-maps-api-pricing-and-options
How to code your own procedural dungeon map generator using the Random Walk Algorithm - freeCodeCamp, 9월 10, 2025에 액세스, https://www.freecodecamp.org/news/how-to-make-your-own-procedural-dungeon-map-generator-using-the-random-walk-algorithm-e0085c8aa9a/
About background location and battery life | Sensors and location - Android Developers, 9월 10, 2025에 액세스, https://developer.android.com/develop/sensors-and-location/location/battery
Handling Background Location Tracking Responsibly in Flutter - Vibe Studio, 9월 10, 2025에 액세스, https://vibe-studio.ai/insights/handling-background-location-tracking-responsibly-in-flutter
Trajectory Segmentation Map-Matching Approach for Large-Scale, High-Resolution GPS Data - OSTI, 9월 10, 2025에 액세스, https://www.osti.gov/servlets/purl/1414899
Map matching - Wikipedia, 9월 10, 2025에 액세스, https://en.wikipedia.org/wiki/Map_matching
Map-matching poor-quality GPS data in urban environments: The pgMapMatch package - Adam Millard-Ball, 9월 10, 2025에 액세스, https://millardball.its.ucla.edu/wp-content/uploads/sites/22/2022/06/Millard-Ball_Hampshire_Weinberger_2019_Map-matching_preprint.pdf
Efficient algorithms to match GPS data on a map, 9월 10, 2025에 액세스, https://www.dii.uchile.cl/~fordon/docs/notfinal/IJOR-Map%20Matching-acceptedManus.pdf
Gamification Use and Design in Popular Health and Fitness Mobile Applications - PMC, 9월 10, 2025에 액세스, https://pmc.ncbi.nlm.nih.gov/articles/PMC6348030/
What is an in-game economy | Unity, 9월 10, 2025에 액세스, https://unity.com/how-to/what-game-economy-guide-part-1
Building an in-game economy | Unity Gaming Services, 9월 10, 2025에 액세스, https://unity.com/how-to/building-game-economy-guide-part-2
Gacha game - Wikipedia, 9월 10, 2025에 액세스, https://en.wikipedia.org/wiki/Gacha_game
Gacha System Diagram | Machinations Community, 9월 10, 2025에 액세스, https://machinations.io/community/fransuu/gacha-system-06b974a2b3463d7ca3b8ce0d85dbd3342
Gacha Game Questions : r/gamedev - Reddit, 9월 10, 2025에 액세스, https://www.reddit.com/r/gamedev/comments/oggl53/gacha_game_questions/
DB design for “Gacha” – Same Probability | Thousand Tech Blog, 9월 10, 2025에 액세스, https://thousand-tech.blog/en/database-en/example/db-design-for-gacha-same-probability/
Model your Cloud Firestore Database The Right Way: A Chat Application Case Study | by Henry Ifebunandu | Medium, 9월 10, 2025에 액세스, https://medium.com/@henryifebunandu/cloud-firestore-db-structure-for-your-chat-application-64ec77a9f9c0
Cloud Firestore Data model - Firebase, 9월 10, 2025에 액세스, https://firebase.google.com/docs/firestore/data-model
Choose a data structure | Firestore - Firebase - Google, 9월 10, 2025에 액세스, https://firebase.google.com/docs/firestore/manage-data/structure-data
Structure data | Firestore in Native mode - Google Cloud, 9월 10, 2025에 액세스, https://cloud.google.com/firestore/native/docs/concepts/structure-data
Firestore - Logical collection schema for setting data per user? - Stack Overflow, 9월 10, 2025에 액세스, https://stackoverflow.com/questions/49037832/firestore-logical-collection-schema-for-setting-data-per-user
Flutter Social oAuth Login for Web Windows and Mobile Without #Firebase - YouTube, 9월 10, 2025에 액세스, https://www.youtube.com/watch?v=V7-Cp6n4kjg
Nike Run Club App, 9월 10, 2025에 액세스, https://www.nike.com/nrc-app
Walkr - Fit with Fun Walking Game - sparkful, 9월 10, 2025에 액세스, https://sparkful.app/walkr
Walkr - Gamified Fitness Walk on the App Store, 9월 10, 2025에 액세스, https://apps.apple.com/us/app/walkr-gamified-fitness-walk/id834805518
How to Build a Dog Walking App That Users Love? - Seven Square, 9월 10, 2025에 액세스, https://www.sevensquaretech.com/how-to-build-dog-walking-app/
Top UX Best Practices for Dog Walking App Design - Uistudioz, 9월 10, 2025에 액세스, https://uistudioz.com/ux-best-practices-for-dog-walking-app/
Build Flutter Apps FASTER with Claude Code Opus 4, 9월 10, 2025에 액세스, https://codewithandrea.com/videos/build-flutter-apps-faster-claude-code-opus4/
FREE AI-Powered Flutter Code Generator | Boost Your Flutter Apps Instantly - Workik, 9월 10, 2025에 액세스, https://workik.com/ai-powered-flutter-code-generator
Top 10 Most Innovative Gamification in Fitness (2025) - Yu-kai Chou, 9월 10, 2025에 액세스, https://yukaichou.com/gamification-analysis/top-10-gamification-in-fitness/
