// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firestoreServiceHash() => r'0f8fc3ed9acdb2d77cdfb4f0d713961c9a50352e';

/// FirestoreService 인스턴스를 제공하는 Provider
/// 설계 문서 섹션 1.2: Riverpod를 사용한 상태 관리
///
/// Copied from [firestoreService].
@ProviderFor(firestoreService)
final firestoreServiceProvider = AutoDisposeProvider<FirestoreService>.internal(
  firestoreService,
  name: r'firestoreServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firestoreServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreServiceRef = AutoDisposeProviderRef<FirestoreService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
