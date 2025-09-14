// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routeServiceHash() => r'02adca26e7006e2747c7a80a37aad3cbba33e827';

/// RouteService 인스턴스를 제공하는 Provider
///
/// Copied from [routeService].
@ProviderFor(routeService)
final routeServiceProvider = AutoDisposeProvider<RouteService>.internal(
  routeService,
  name: r'routeServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routeServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RouteServiceRef = AutoDisposeProviderRef<RouteService>;
String _$currentPositionHash() => r'7be35b62b8e2285692953788418dee2145f31b5b';

/// 현재 위치를 관리하는 Provider
///
/// Copied from [currentPosition].
@ProviderFor(currentPosition)
final currentPositionProvider = AutoDisposeFutureProvider<Position>.internal(
  currentPosition,
  name: r'currentPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPositionRef = AutoDisposeFutureProviderRef<Position>;
String _$locationPermissionHash() =>
    r'9fdb8d50462357a2dede6e62f3c4a15ac5142a8b';

/// 위치 권한 상태를 관리하는 Provider
///
/// Copied from [locationPermission].
@ProviderFor(locationPermission)
final locationPermissionProvider =
    AutoDisposeFutureProvider<LocationPermission>.internal(
  locationPermission,
  name: r'locationPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationPermissionRef
    = AutoDisposeFutureProviderRef<LocationPermission>;
String _$locationServiceEnabledHash() =>
    r'2256621c62a61b18abe8b13b5980efcee9c6db3f';

/// 위치 서비스 활성화 상태를 확인하는 Provider
///
/// Copied from [locationServiceEnabled].
@ProviderFor(locationServiceEnabled)
final locationServiceEnabledProvider = AutoDisposeFutureProvider<bool>.internal(
  locationServiceEnabled,
  name: r'locationServiceEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationServiceEnabledRef = AutoDisposeFutureProviderRef<bool>;
String _$positionStreamHash() => r'0b2be74c315abb4e488c53427a90a8c879e72577';

/// 실시간 위치 스트림 Provider (산책 중 사용)
///
/// Copied from [positionStream].
@ProviderFor(positionStream)
final positionStreamProvider = AutoDisposeStreamProvider<Position>.internal(
  positionStream,
  name: r'positionStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$positionStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PositionStreamRef = AutoDisposeStreamProviderRef<Position>;
String _$calculateDistanceHash() => r'0d49294279576ce647a34bb7d802a64f6aad844a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 두 지점 간의 거리를 계산하는 유틸리티 Provider
///
/// Copied from [calculateDistance].
@ProviderFor(calculateDistance)
const calculateDistanceProvider = CalculateDistanceFamily();

/// 두 지점 간의 거리를 계산하는 유틸리티 Provider
///
/// Copied from [calculateDistance].
class CalculateDistanceFamily extends Family<double> {
  /// 두 지점 간의 거리를 계산하는 유틸리티 Provider
  ///
  /// Copied from [calculateDistance].
  const CalculateDistanceFamily();

  /// 두 지점 간의 거리를 계산하는 유틸리티 Provider
  ///
  /// Copied from [calculateDistance].
  CalculateDistanceProvider call(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return CalculateDistanceProvider(
      lat1,
      lng1,
      lat2,
      lng2,
    );
  }

  @override
  CalculateDistanceProvider getProviderOverride(
    covariant CalculateDistanceProvider provider,
  ) {
    return call(
      provider.lat1,
      provider.lng1,
      provider.lat2,
      provider.lng2,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'calculateDistanceProvider';
}

/// 두 지점 간의 거리를 계산하는 유틸리티 Provider
///
/// Copied from [calculateDistance].
class CalculateDistanceProvider extends AutoDisposeProvider<double> {
  /// 두 지점 간의 거리를 계산하는 유틸리티 Provider
  ///
  /// Copied from [calculateDistance].
  CalculateDistanceProvider(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) : this._internal(
          (ref) => calculateDistance(
            ref as CalculateDistanceRef,
            lat1,
            lng1,
            lat2,
            lng2,
          ),
          from: calculateDistanceProvider,
          name: r'calculateDistanceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$calculateDistanceHash,
          dependencies: CalculateDistanceFamily._dependencies,
          allTransitiveDependencies:
              CalculateDistanceFamily._allTransitiveDependencies,
          lat1: lat1,
          lng1: lng1,
          lat2: lat2,
          lng2: lng2,
        );

  CalculateDistanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lat1,
    required this.lng1,
    required this.lat2,
    required this.lng2,
  }) : super.internal();

  final double lat1;
  final double lng1;
  final double lat2;
  final double lng2;

  @override
  Override overrideWith(
    double Function(CalculateDistanceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalculateDistanceProvider._internal(
        (ref) => create(ref as CalculateDistanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lat1: lat1,
        lng1: lng1,
        lat2: lat2,
        lng2: lng2,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _CalculateDistanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalculateDistanceProvider &&
        other.lat1 == lat1 &&
        other.lng1 == lng1 &&
        other.lat2 == lat2 &&
        other.lng2 == lng2;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lat1.hashCode);
    hash = _SystemHash.combine(hash, lng1.hashCode);
    hash = _SystemHash.combine(hash, lat2.hashCode);
    hash = _SystemHash.combine(hash, lng2.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalculateDistanceRef on AutoDisposeProviderRef<double> {
  /// The parameter `lat1` of this provider.
  double get lat1;

  /// The parameter `lng1` of this provider.
  double get lng1;

  /// The parameter `lat2` of this provider.
  double get lat2;

  /// The parameter `lng2` of this provider.
  double get lng2;
}

class _CalculateDistanceProviderElement
    extends AutoDisposeProviderElement<double> with CalculateDistanceRef {
  _CalculateDistanceProviderElement(super.provider);

  @override
  double get lat1 => (origin as CalculateDistanceProvider).lat1;
  @override
  double get lng1 => (origin as CalculateDistanceProvider).lng1;
  @override
  double get lat2 => (origin as CalculateDistanceProvider).lat2;
  @override
  double get lng2 => (origin as CalculateDistanceProvider).lng2;
}

String _$routeGeneratorHash() => r'18c61b3aa85bb758088aec05989f885fd396861e';

/// 경로 생성을 관리하는 NotifierProvider
///
/// Copied from [RouteGenerator].
@ProviderFor(RouteGenerator)
final routeGeneratorProvider = AutoDisposeNotifierProvider<RouteGenerator,
    AsyncValue<GeneratedRoute?>>.internal(
  RouteGenerator.new,
  name: r'routeGeneratorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$routeGeneratorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RouteGenerator = AutoDisposeNotifier<AsyncValue<GeneratedRoute?>>;
String _$routeHistoryHash() => r'cc4bb21240daca7eb7ae97686b7a62db57f0ffb8';

/// 경로 생성 히스토리를 관리하는 Provider
///
/// Copied from [RouteHistory].
@ProviderFor(RouteHistory)
final routeHistoryProvider =
    AutoDisposeNotifierProvider<RouteHistory, List<GeneratedRoute>>.internal(
  RouteHistory.new,
  name: r'routeHistoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routeHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RouteHistory = AutoDisposeNotifier<List<GeneratedRoute>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
