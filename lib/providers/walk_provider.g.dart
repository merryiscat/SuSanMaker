// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$locationServiceHash() => r'3b3077729fc0ea286d891106ad873cff531a8bd5';

/// LocationService 인스턴스를 제공하는 Provider
///
/// Copied from [locationService].
@ProviderFor(locationService)
final locationServiceProvider = AutoDisposeProvider<LocationService>.internal(
  locationService,
  name: r'locationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationServiceRef = AutoDisposeProviderRef<LocationService>;
String _$userWalksHash() => r'525b175cee310af5ee3613cbaab777098474b680';

/// 사용자의 산책 기록을 관리하는 Provider
/// 설계 문서 섹션 2.3: 산책 추적 및 기록
///
/// Copied from [userWalks].
@ProviderFor(userWalks)
final userWalksProvider = AutoDisposeStreamProvider<List<Walk>>.internal(
  userWalks,
  name: r'userWalksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userWalksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserWalksRef = AutoDisposeStreamProviderRef<List<Walk>>;
String _$walkStatsHash() => r'2f07fa6544317bee57ae96de25d2b5934d2d6486';

/// 실시간 산책 통계를 제공하는 StreamProvider
///
/// Copied from [walkStats].
@ProviderFor(walkStats)
final walkStatsProvider =
    AutoDisposeStreamProvider<Map<String, dynamic>>.internal(
  walkStats,
  name: r'walkStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$walkStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalkStatsRef = AutoDisposeStreamProviderRef<Map<String, dynamic>>;
String _$currentLocationHash() => r'235dd09543cb8d00754295b8c97c872ed536a5a0';

/// 현재 위치 스트림을 제공하는 StreamProvider
///
/// Copied from [currentLocation].
@ProviderFor(currentLocation)
final currentLocationProvider = AutoDisposeStreamProvider<RoutePoint>.internal(
  currentLocation,
  name: r'currentLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentLocationRef = AutoDisposeStreamProviderRef<RoutePoint>;
String _$activeWalkHash() => r'73b52b7e73b50316a804510ac2baead5118cb9fe';

/// 현재 진행 중인 산책 상태를 관리하는 NotifierProvider
///
/// Copied from [ActiveWalk].
@ProviderFor(ActiveWalk)
final activeWalkProvider =
    AutoDisposeNotifierProvider<ActiveWalk, AsyncValue<Walk?>>.internal(
  ActiveWalk.new,
  name: r'activeWalkProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeWalkHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveWalk = AutoDisposeNotifier<AsyncValue<Walk?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
