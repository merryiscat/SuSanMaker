# Firebase 연동 상세 가이드

Flutter 프로젝트와 Firebase를 완전히 연동하기 위한 단계별 가이드입니다.

## 🔥 Firebase 프로젝트 설정

### 1. Firebase Console에서 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름: `ran-san-maker` 또는 원하는 이름
4. Google Analytics 사용 여부 선택 (권장: 사용)
5. 프로젝트 생성 완료

### 2. Flutter 앱 등록

#### Android 앱 등록
1. Firebase Console에서 Android 아이콘 클릭
2. Android 패키지 이름 입력: `com.example.ran_san_maker`
3. 앱 닉네임: `랜덤 산책로 메이커`
4. SHA-1 서명 인증서 지문 추가 (선택사항)
```bash
# 디버그 키스토어에서 SHA-1 가져오기
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### iOS 앱 등록
1. Firebase Console에서 iOS 아이콘 클릭
2. iOS 번들 ID 입력: `com.example.ranSanMaker`
3. 앱 닉네임: `랜덤 산책로 메이커`
4. App Store ID (선택사항)

---

## 🛠 개발 환경 설정

### 1. Firebase CLI 설치 및 설정

```bash
# Node.js가 설치되어 있어야 합니다
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 디렉토리에서 Firebase 초기화
cd /path/to/your/flutter/project
firebase init

# 선택할 기능들:
# - Firestore: Configure rules and indexes files for Firestore
# - Functions: Configure a Cloud Functions directory and its files
# - Storage: Configure a security rules file for Cloud Storage
```

### 2. FlutterFire CLI 설정

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Flutter 프로젝트와 Firebase 연결
flutterfire configure

# 프로젝트 선택 후 플랫폼 선택 (Android, iOS)
```

### 3. 필수 패키지 추가

```yaml
# pubspec.yaml
dependencies:
  # Firebase 핵심
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.5.0
  firebase_storage: ^12.4.0
  
  # 소셜 로그인
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.3
  
  # 상태 관리 (이미 있음)
  flutter_riverpod: ^2.6.1
```

```bash
flutter pub get
```

---

## 🔐 Authentication 설정

### 1. Firebase Console에서 인증 방법 활성화

1. Firebase Console → Authentication → Sign-in method
2. 활성화할 방법들:
   - **Google**: 사용 설정 → 프로젝트 지원 이메일 설정
   - **Apple**: 사용 설정 → Apple Developer 계정 정보 입력
   - **익명**: 사용 설정 (테스트용)

### 2. Google Sign-In 설정

#### Android 설정
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application>
    <!-- 기존 내용 -->
    
    <!-- Google Sign-In을 위한 메타데이터 -->
    <meta-data
        android:name="com.google.android.gms.version"
        android:value="@integer/google_play_services_version" />
</application>
```

#### iOS 설정
```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <!-- 기존 내용 -->
    
    <!-- Google Sign-In URL Scheme -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>REVERSED_CLIENT_ID</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>YOUR_REVERSED_CLIENT_ID</string>
            </array>
        </dict>
    </array>
</dict>
```

### 3. Authentication 서비스 구현

```dart
// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 현재 사용자 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 현재 사용자
  User? get currentUser => _auth.currentUser;

  // Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google 로그인 에러: $e');
      return null;
    }
  }

  // Apple 로그인 (iOS만)
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      print('Apple 로그인 에러: $e');
      return null;
    }
  }

  // 익명 로그인
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('익명 로그인 에러: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
```

### 4. Authentication Provider (Riverpod)

```dart
// lib/providers/auth_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  return ref.watch(authStateProvider).value;
}
```

---

## 🗃 Firestore 설정

### 1. Firestore 데이터베이스 생성

1. Firebase Console → Firestore Database
2. "데이터베이스 만들기" 클릭
3. 보안 규칙: "테스트 모드에서 시작" (나중에 변경)
4. 위치: `asia-northeast3 (Seoul)` 선택

### 2. 보안 규칙 설정

```javascript
// firestore.rules
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자는 자신의 문서만 읽기/쓰기 가능
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // 사용자 인벤토리 하위 컬렉션
      match /inventory/{inventoryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // 산책 기록은 작성자만 접근 가능
    match /walks/{walkId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
    
    // 아이템 마스터 데이터는 인증된 사용자 모두 읽기 가능
    match /items/{itemId} {
      allow read: if request.auth != null;
      allow write: if false; // 관리자만 수정 가능
    }
    
    // 가챠 설정은 읽기만 가능
    match /gacha_config/{configId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

### 3. Firestore 인덱스 설정

```javascript
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "walks",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "completedAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "inventory",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "acquiredAt",
          "order": "DESCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

### 4. Firestore 서비스 구현

```dart
// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/walk.dart';
import '../models/gacha_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자 프로필 관련
  Future<void> createUserProfile(String uid, String email, String displayName) async {
    final userRef = _firestore.collection('users').doc(uid);
    
    final userData = UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      pointsBalance: 500, // 시작 포인트
      stats: {
        'totalDistance': 0.0,
        'totalWalks': 0,
        'currentStreak': 0,
      },
      equippedItems: {},
    );
    
    await userRef.set(userData.toJson());
  }

  Stream<UserProfile?> getUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromJson(doc.data()!) : null);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // 포인트 관련
  Future<void> addPoints(String uid, int points) async {
    final userRef = _firestore.collection('users').doc(uid);
    
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (userDoc.exists) {
        final currentPoints = userDoc.data()?['pointsBalance'] ?? 0;
        transaction.update(userRef, {'pointsBalance': currentPoints + points});
      }
    });
  }

  Future<bool> deductPoints(String uid, int points) async {
    final userRef = _firestore.collection('users').doc(uid);
    
    return await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (userDoc.exists) {
        final currentPoints = userDoc.data()?['pointsBalance'] ?? 0;
        if (currentPoints >= points) {
          transaction.update(userRef, {'pointsBalance': currentPoints - points});
          return true;
        }
      }
      return false;
    });
  }

  // 산책 기록 관련
  Future<void> saveWalk(Walk walkData) async {
    await _firestore.collection('walks').add(walkData.toJson());
    
    // 사용자 통계 업데이트
    final userRef = _firestore.collection('users').doc(walkData.userId);
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (userDoc.exists) {
        final stats = Map<String, dynamic>.from(userDoc.data()?['stats'] ?? {});
        stats['totalDistance'] = (stats['totalDistance'] ?? 0.0) + walkData.actualDistance;
        stats['totalWalks'] = (stats['totalWalks'] ?? 0) + 1;
        
        transaction.update(userRef, {'stats': stats});
      }
    });
  }

  Stream<List<Walk>> getUserWalks(String uid, {int limit = 20}) {
    return _firestore
        .collection('walks')
        .where('userId', isEqualTo: uid)
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Walk.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // 인벤토리 관련
  Future<void> addItemToInventory(String uid, String itemId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .add({
      'itemId': itemId,
      'acquiredAt': FieldValue.serverTimestamp(),
      'isNew': true,
    });
  }

  Stream<List<GachaItem>> getUserInventory(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .orderBy('acquiredAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final items = <GachaItem>[];
      
      for (final doc in snapshot.docs) {
        final inventoryData = doc.data();
        final itemDoc = await _firestore
            .collection('items')
            .doc(inventoryData['itemId'])
            .get();
            
        if (itemDoc.exists) {
          final item = GachaItem.fromJson({
            ...itemDoc.data()!,
            'id': itemDoc.id,
          });
          items.add(item);
        }
      }
      
      return items;
    });
  }

  // 장착 아이템 업데이트
  Future<void> updateEquippedItem(String uid, String slot, String? itemId) async {
    final equippedItems = <String, dynamic>{};
    if (itemId != null) {
      equippedItems[slot] = itemId;
    } else {
      equippedItems[slot] = FieldValue.delete();
    }
    
    await _firestore.collection('users').doc(uid).update({
      'equippedItems.$slot': itemId,
    });
  }

  // 아이템 마스터 데이터
  Stream<List<GachaItem>> getAllItems() {
    return _firestore
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GachaItem.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
```

### 5. Firestore Provider (Riverpod)

```dart
// lib/providers/firestore_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/firestore_service.dart';
import '../models/user.dart';
import 'auth_provider.dart';

part 'firestore_provider.g.dart';

@riverpod
FirestoreService firestoreService(FirestoreServiceRef ref) {
  return FirestoreService();
}

@riverpod
Stream<UserProfile?> userProfile(UserProfileRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  
  return ref.watch(firestoreServiceProvider).getUserProfile(user.uid);
}

@riverpod
Stream<List<Walk>> userWalks(UserWalksRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  
  return ref.watch(firestoreServiceProvider).getUserWalks(user.uid);
}

@riverpod
Stream<List<GachaItem>> userInventory(UserInventoryRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  
  return ref.watch(firestoreServiceProvider).getUserInventory(user.uid);
}
```

---

## 📦 Storage 설정

### 1. Firebase Storage 규칙

```javascript
// storage.rules
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // 아이템 이미지는 인증된 사용자 모두 읽기 가능
    match /items/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if false; // 관리자만 업로드
    }
    
    // 사용자 프로필 이미지
    match /users/{userId}/profile/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🧪 초기 데이터 설정

### 1. 아이템 마스터 데이터 생성

```dart
// scripts/init_firestore_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeItemData() async {
  final firestore = FirebaseFirestore.instance;
  
  final items = [
    {
      'name': '기본 모자',
      'description': '평범한 모자입니다',
      'rarity': 'Common',
      'type': 'head',
      'assetUrl': 'items/hats/basic_hat.png',
    },
    {
      'name': '멋진 선글라스',
      'description': '스타일리시한 선글라스',
      'rarity': 'Uncommon',
      'type': 'accessory',
      'assetUrl': 'items/accessories/sunglasses.png',
    },
    {
      'name': '네온 운동화',
      'description': '빛나는 운동화',
      'rarity': 'Rare',
      'type': 'feet',
      'assetUrl': 'items/shoes/neon_sneakers.png',
    },
    // ... 더 많은 아이템들
  ];
  
  final batch = firestore.batch();
  for (final item in items) {
    final docRef = firestore.collection('items').doc();
    batch.set(docRef, item);
  }
  
  await batch.commit();
}
```

### 2. 가챠 설정 데이터

```dart
Future<void> initializeGachaConfig() async {
  final firestore = FirebaseFirestore.instance;
  
  await firestore.collection('gacha_config').doc('default').set({
    'cost': 100,
    'probabilities': {
      'Common': 0.65,
      'Uncommon': 0.25,
      'Rare': 0.075,
      'Epic': 0.02,
      'Legendary': 0.005,
    },
    'pitySystem': {
      'rare': 30,
      'epic': 50,
      'legendary': 100,
    },
  });
}
```

---

## ✅ 설정 완료 체크리스트

### Firebase Console 설정
- [ ] Firebase 프로젝트 생성
- [ ] Android/iOS 앱 등록
- [ ] Authentication 활성화 (Google, Apple, 익명)
- [ ] Firestore 데이터베이스 생성
- [ ] Storage 버킷 생성
- [ ] 보안 규칙 배포

### Flutter 프로젝트 설정
- [ ] `firebase_options.dart` 파일 생성
- [ ] 필수 패키지 추가
- [ ] Android 권한 설정
- [ ] iOS 권한 설정
- [ ] 코드 생성 실행: `flutter packages pub run build_runner build`

### 테스트
- [ ] 앱 실행 시 Firebase 연결 확인
- [ ] 로그인/로그아웃 기능 테스트
- [ ] Firestore 읽기/쓰기 테스트
- [ ] 실제 기기에서 테스트

이 가이드를 따라하면 Firebase와 완전히 연동된 Flutter 앱을 구축할 수 있습니다!