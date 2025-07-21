// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advert_socket_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$advertSocketServiceHash() =>
    r'ec9591338e9431f0374066eeaf5dc39760c44e99';

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

abstract class _$AdvertSocketService
    extends BuildlessNotifier<AdvertSocketService> {
  late final String? advertId;

  AdvertSocketService build(
    String? advertId,
  );
}

/// See also [AdvertSocketService].
@ProviderFor(AdvertSocketService)
const advertSocketServiceProvider = AdvertSocketServiceFamily();

/// See also [AdvertSocketService].
class AdvertSocketServiceFamily extends Family<AdvertSocketService> {
  /// See also [AdvertSocketService].
  const AdvertSocketServiceFamily();

  /// See also [AdvertSocketService].
  AdvertSocketServiceProvider call(
    String? advertId,
  ) {
    return AdvertSocketServiceProvider(
      advertId,
    );
  }

  @override
  AdvertSocketServiceProvider getProviderOverride(
    covariant AdvertSocketServiceProvider provider,
  ) {
    return call(
      provider.advertId,
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
  String? get name => r'advertSocketServiceProvider';
}

/// See also [AdvertSocketService].
class AdvertSocketServiceProvider
    extends NotifierProviderImpl<AdvertSocketService, AdvertSocketService> {
  /// See also [AdvertSocketService].
  AdvertSocketServiceProvider(
    String? advertId,
  ) : this._internal(
          () => AdvertSocketService()..advertId = advertId,
          from: advertSocketServiceProvider,
          name: r'advertSocketServiceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$advertSocketServiceHash,
          dependencies: AdvertSocketServiceFamily._dependencies,
          allTransitiveDependencies:
              AdvertSocketServiceFamily._allTransitiveDependencies,
          advertId: advertId,
        );

  AdvertSocketServiceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.advertId,
  }) : super.internal();

  final String? advertId;

  @override
  AdvertSocketService runNotifierBuild(
    covariant AdvertSocketService notifier,
  ) {
    return notifier.build(
      advertId,
    );
  }

  @override
  Override overrideWith(AdvertSocketService Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdvertSocketServiceProvider._internal(
        () => create()..advertId = advertId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        advertId: advertId,
      ),
    );
  }

  @override
  NotifierProviderElement<AdvertSocketService, AdvertSocketService>
      createElement() {
    return _AdvertSocketServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdvertSocketServiceProvider && other.advertId == advertId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, advertId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdvertSocketServiceRef on NotifierProviderRef<AdvertSocketService> {
  /// The parameter `advertId` of this provider.
  String? get advertId;
}

class _AdvertSocketServiceProviderElement
    extends NotifierProviderElement<AdvertSocketService, AdvertSocketService>
    with AdvertSocketServiceRef {
  _AdvertSocketServiceProviderElement(super.provider);

  @override
  String? get advertId => (origin as AdvertSocketServiceProvider).advertId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
