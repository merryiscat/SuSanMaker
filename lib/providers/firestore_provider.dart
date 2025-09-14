import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/firestore_service.dart';

part 'firestore_provider.g.dart';

/// FirestoreService 인스턴스를 제공하는 Provider
/// 설계 문서 섹션 1.2: Riverpod를 사용한 상태 관리
@riverpod
FirestoreService firestoreService(FirestoreServiceRef ref) {
  return FirestoreService();
}