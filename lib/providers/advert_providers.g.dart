// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advert_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'c0f2e625c44495e0e54f2f1fb07e08501e77e247';

/// Provider for Dio instance (for Retrofit)
///
/// Copied from [dio].
@ProviderFor(dio)
final dioProvider = Provider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = ProviderRef<Dio>;
String _$advertApiClientHash() => r'9fd0b4b9608a3fcc42436fa5f462c4ebd64ad8e1';

/// Provider for AdvertApiClient (Retrofit)
///
/// Copied from [advertApiClient].
@ProviderFor(advertApiClient)
final advertApiClientProvider = Provider<AdvertApiClient>.internal(
  advertApiClient,
  name: r'advertApiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$advertApiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdvertApiClientRef = ProviderRef<AdvertApiClient>;
String _$advertRepositoryHash() => r'439fc473e8520908fced791e3fc0eb19f0965bf3';

/// Provider for AdvertRepository
///
/// Copied from [advertRepository].
@ProviderFor(advertRepository)
final advertRepositoryProvider = Provider<AdvertRepository>.internal(
  advertRepository,
  name: r'advertRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$advertRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdvertRepositoryRef = ProviderRef<AdvertRepository>;
String _$advertSocketServiceHash() =>
    r'4f48203f56fd6e45596176593ccf223fc29afab1';

/// Provider for AdvertSocketService
///
/// Copied from [advertSocketService].
@ProviderFor(advertSocketService)
final advertSocketServiceProvider = Provider<AdvertSocketService>.internal(
  advertSocketService,
  name: r'advertSocketServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$advertSocketServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdvertSocketServiceRef = ProviderRef<AdvertSocketService>;
String _$advertCostingsHash() => r'9161b1ad7810e9603a16070f6731149a88573391';

/// Provider to fetch and manage a list of available AdvertCosting options.
///
/// Copied from [advertCostings].
@ProviderFor(advertCostings)
final advertCostingsProvider = FutureProvider<List<AdvertCosting>>.internal(
  advertCostings,
  name: r'advertCostingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$advertCostingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdvertCostingsRef = FutureProviderRef<List<AdvertCosting>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
