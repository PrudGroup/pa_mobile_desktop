// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$playbackHistoryServiceHash() =>
    r'0a48db1481c637a0d3a855cd6c6edbdba0cc2c66';

/// Provider for PlaybackHistoryService
///
/// Copied from [playbackHistoryService].
@ProviderFor(playbackHistoryService)
final playbackHistoryServiceProvider =
    Provider<PlaybackHistoryService>.internal(
  playbackHistoryService,
  name: r'playbackHistoryServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playbackHistoryServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlaybackHistoryServiceRef = ProviderRef<PlaybackHistoryService>;
String _$initialPlaylistHash() => r'efefe7859ac86f719514010182b95719464f9653';

/// A provider that loads the initial list of videos and converts them to VideoPlaybackItem.
///
/// Copied from [initialPlaylist].
@ProviderFor(initialPlaylist)
final initialPlaylistProvider =
    FutureProvider<List<VideoPlaybackItem>>.internal(
  initialPlaylist,
  name: r'initialPlaylistProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialPlaylistHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitialPlaylistRef = FutureProviderRef<List<VideoPlaybackItem>>;
String _$playlistNotifierHash() => r'8e29ff4df840bdcddbac3cf9156665d832a1ec98';

/// Manages the playlist state and current video index.
///
/// Copied from [PlaylistNotifier].
@ProviderFor(PlaylistNotifier)
final playlistNotifierProvider =
    AsyncNotifierProvider<PlaylistNotifier, List<VideoPlaybackItem>>.internal(
  PlaylistNotifier.new,
  name: r'playlistNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playlistNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PlaylistNotifier = AsyncNotifier<List<VideoPlaybackItem>>;
String _$videoPlayerControllerNotifierHash() =>
    r'7d85bbed26545cd08c495dd4d5dd0645ecaad200';

/// Manages the BetterPlayerController lifecycle and state.
///
/// Copied from [VideoPlayerControllerNotifier].
@ProviderFor(VideoPlayerControllerNotifier)
final videoPlayerControllerNotifierProvider = NotifierProvider<
    VideoPlayerControllerNotifier, BetterPlayerController?>.internal(
  VideoPlayerControllerNotifier.new,
  name: r'videoPlayerControllerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoPlayerControllerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VideoPlayerControllerNotifier = Notifier<BetterPlayerController?>;
String _$playbackHistoryNotifierHash() =>
    r'06049ef00709953d0ed0987fb1ef415cc72cc66a';

/// Provider for playback history, making it consumable by UI.
///
/// Copied from [PlaybackHistoryNotifier].
@ProviderFor(PlaybackHistoryNotifier)
final playbackHistoryNotifierProvider = AsyncNotifierProvider<
    PlaybackHistoryNotifier, Map<String, Duration>>.internal(
  PlaybackHistoryNotifier.new,
  name: r'playbackHistoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playbackHistoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PlaybackHistoryNotifier = AsyncNotifier<Map<String, Duration>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
