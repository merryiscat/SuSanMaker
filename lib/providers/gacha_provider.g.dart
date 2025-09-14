// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gacha_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gachaItemsHash() => r'f02ddc2821d851f2f150c207d3853c7398e86e1b';

/// 가챠 아이템 마스터 데이터를 관리하는 Provider
/// 설계 문서 섹션 3.2: 가챠 시스템
///
/// Copied from [gachaItems].
@ProviderFor(gachaItems)
final gachaItemsProvider = AutoDisposeStreamProvider<List<GachaItem>>.internal(
  gachaItems,
  name: r'gachaItemsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gachaItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GachaItemsRef = AutoDisposeStreamProviderRef<List<GachaItem>>;
String _$userInventoryHash() => r'71343210638cafb1dedad25ad32d92363d68c1ea';

/// 사용자 인벤토리를 관리하는 Provider
///
/// Copied from [userInventory].
@ProviderFor(userInventory)
final userInventoryProvider =
    AutoDisposeStreamProvider<List<UserInventory>>.internal(
  userInventory,
  name: r'userInventoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userInventoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserInventoryRef = AutoDisposeStreamProviderRef<List<UserInventory>>;
String _$gachaSystemHash() => r'1bd691a950686c63884122bdf31afabd6c124c0a';

/// 가챠 시스템을 관리하는 NotifierProvider
///
/// Copied from [GachaSystem].
@ProviderFor(GachaSystem)
final gachaSystemProvider =
    AutoDisposeNotifierProvider<GachaSystem, Map<String, dynamic>>.internal(
  GachaSystem.new,
  name: r'gachaSystemProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gachaSystemHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GachaSystem = AutoDisposeNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
