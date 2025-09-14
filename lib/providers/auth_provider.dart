import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as app_user;
import '../services/firestore_service.dart';

part 'auth_provider.g.dart';

/// Firebase Authentication 상태를 관리하는 Provider
/// 설계 문서 섹션 1.2: Riverpod를 사용한 상태 관리
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

/// 현재 인증된 사용자 정보를 가져오는 Provider
/// Firestore에서 사용자 상세 정보를 가져옵니다
@riverpod
Stream<app_user.User?> currentUser(CurrentUserRef ref) async* {
  final authState = ref.watch(authStateProvider);

  await for (final firebaseUser in authState) {
    if (firebaseUser == null) {
      yield null;
    } else {
      // Firestore에서 사용자 정보 가져오기
      final firestoreService = ref.read(firestoreServiceProvider);
      yield* firestoreService.getUserStream(firebaseUser.uid);
    }
  }
}

/// 인증 관련 작업을 수행하는 NotifierProvider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<void> build() async {
    // 초기화 로직
  }

  /// Google 로그인 수행
  Future<void> signInWithGoogle() async {
    try {
      // Google 로그인 구현 (나중에 google_sign_in 패키지 추가 후 구현)
      // 현재는 익명 로그인으로 대체
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      throw Exception('로그인 실패: $e');
    }
  }

  /// 로그아웃 수행
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw Exception('로그아웃 실패: $e');
    }
  }

  /// 익명 로그인 (테스트용)
  Future<void> signInAnonymously() async {
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();

      // 새 사용자인 경우 Firestore에 사용자 문서 생성
      if (credential.user != null) {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.createUserIfNotExists(
          credential.user!.uid,
          'Anonymous User',
          '',
        );
      }
    } catch (e) {
      throw Exception('익명 로그인 실패: $e');
    }
  }
}