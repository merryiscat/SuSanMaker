// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bonus_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userBonusStatsHash() => r'4335cb5fd55531311bf0c82d060b88c2723ba048';

/// 사용자의 보너스 통계를 제공하는 Provider
///
/// Copied from [userBonusStats].
@ProviderFor(userBonusStats)
final userBonusStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  userBonusStats,
  name: r'userBonusStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userBonusStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserBonusStatsRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$bonusSystemHash() => r'97562f8e8c0787c3c40120b04fb8e06da986bfbc';

/// 보너스 시스템을 관리하는 Provider
/// 설계 문서 섹션 3.1: 일일 첫 산책 보너스, 연속 산책 보너스
///
/// Copied from [BonusSystem].
@ProviderFor(BonusSystem)
final bonusSystemProvider =
    AutoDisposeNotifierProvider<BonusSystem, Map<String, dynamic>>.internal(
  BonusSystem.new,
  name: r'bonusSystemProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bonusSystemHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonusSystem = AutoDisposeNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
