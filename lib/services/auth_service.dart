import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase 인증 서비스
/// Google 로그인, 익명 로그인, 로그아웃 등의 인증 기능을 제공
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 현재 로그인된 사용자
  User? get currentUser => _auth.currentUser;

  /// 로그인 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 사용자 로그인 여부 확인
  bool get isLoggedIn => currentUser != null;

  /// 사용자 ID 반환 (로그인하지 않은 경우 null)
  String? get userId => currentUser?.uid;

  /// 사용자 이메일 반환
  String? get userEmail => currentUser?.email;

  /// 사용자 표시 이름 반환
  String? get displayName => currentUser?.displayName ?? '익명 사용자';

  /// 사용자 프로필 사진 URL
  String? get photoURL => currentUser?.photoURL;

  /// Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // 웹에서의 Google 로그인
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // 모바일에서의 Google 로그인 (google_sign_in 패키지 필요)
        debugPrint('Google 로그인 - 모바일 구현 필요 (google_sign_in 패키지)');

        // 임시로 익명 로그인으로 대체
        return await signInAnonymously();
      }
    } catch (e) {
      debugPrint('Google 로그인 실패: $e');
      return null;
    }
  }

  /// 익명 로그인
  Future<UserCredential?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      debugPrint('익명 로그인 성공: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      debugPrint('익명 로그인 실패: $e');
      return null;
    }
  }

  /// 이메일/비밀번호로 회원가입
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('회원가입 성공: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('회원가입 실패: $e');
      return null;
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('로그인 성공: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('로그인 실패: $e');
      return null;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('로그아웃 성공');
    } catch (e) {
      debugPrint('로그아웃 실패: $e');
    }
  }

  /// 회원 탈퇴
  Future<bool> deleteAccount() async {
    try {
      await currentUser?.delete();
      debugPrint('회원 탈퇴 성공');
      return true;
    } catch (e) {
      debugPrint('회원 탈퇴 실패: $e');
      return false;
    }
  }

  /// 비밀번호 재설정 이메일 발송
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('비밀번호 재설정 이메일 발송 성공');
      return true;
    } catch (e) {
      debugPrint('비밀번호 재설정 이메일 발송 실패: $e');
      return false;
    }
  }

  /// 사용자 프로필 업데이트
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.updatePhotoURL(photoURL);
      await currentUser?.reload();
      debugPrint('사용자 프로필 업데이트 성공');
      return true;
    } catch (e) {
      debugPrint('사용자 프로필 업데이트 실패: $e');
      return false;
    }
  }
}

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// 현재 사용자 Provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

/// 로그인 상태 Provider
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user != null;
});

/// 사용자 ID Provider
final userIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user?.uid;
});

/// 사용자 정보 Provider (UI 표시용)
final userInfoProvider = Provider<Map<String, String?>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return {
    'uid': user?.uid,
    'email': user?.email,
    'displayName': user?.displayName ?? '익명 사용자',
    'photoURL': user?.photoURL,
  };
});