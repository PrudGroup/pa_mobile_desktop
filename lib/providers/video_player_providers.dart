import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prudapp/models/video/video.dart';
import 'package:prudapp/services/cache_service.dart';
import 'package:prudapp/services/playback_history_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:better_player_plus/better_player_plus.dart'; 

part 'video_player_providers.g.dart';



/// Provider for PlaybackHistoryService
@Riverpod(keepAlive: true)
PlaybackHistoryService playbackHistoryService(Ref ref) {
  return PlaybackHistoryService();
}


/// A provider that loads the initial list of videos and converts them to VideoPlaybackItem.
@Riverpod(keepAlive: true)
Future<List<VideoPlaybackItem>> initialPlaylist(Ref ref) async {
  final historyService = ref.read(playbackHistoryServiceProvider);
  final cacheService = ref.read(cacheServiceProvider);
  // TODO get videos from socket
  final videos = [];

  // Convert ChannelVideo to VideoPlaybackItem and load last play position
  List<VideoPlaybackItem> playlist = [];
  for (var video in videos) {
    final lastPos = await historyService.getLastPlayPosition(video.id!);
    final cachedPath = await cacheService.getCachedVideoPath(video.videoUrl);
    playlist.add(
      VideoPlaybackItem.fromChannelVideo(video).copyWith(
        lastPlayPosition: lastPos,
        isCached: cachedPath != null,
        localCachePath: cachedPath,
      ),
    );
  }
  return playlist;
}

/// Manages the playlist state and current video index.
@Riverpod(keepAlive: true)
class PlaylistNotifier extends _$PlaylistNotifier {
  @override
  Future<List<VideoPlaybackItem>> build() async {
    return ref.watch(initialPlaylistProvider.future);
  }

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  VideoPlaybackItem? get currentVideo {
    return state.when(
      data: (videos) => videos.isNotEmpty && _currentIndex >= 0 && _currentIndex < videos.length
          ? videos[_currentIndex]
          : null,
      loading: () => null,
      error: (e, st) => null,
    );
  }

  void playNext() {
    state.whenData((videos) {
      if (videos.isNotEmpty) {
        _currentIndex = ((_currentIndex + 1) % videos.length).toInt();
        ref.read(videoPlayerControllerNotifierProvider.notifier).playVideo(videos[_currentIndex]);
      }
    });
  }

  void playPrevious() {
    state.whenData((videos) {
      if (videos.isNotEmpty) {
        _currentIndex = (_currentIndex - 1 + videos.length) % videos.length;
        ref.read(videoPlayerControllerNotifierProvider.notifier).playVideo(videos[_currentIndex]);
      }
    });
  }

  void playAtIndex(int index) {
    state.whenData((videos) {
      if (index >= 0 && index < videos.length) {
        _currentIndex = index;
        ref.read(videoPlayerControllerNotifierProvider.notifier).playVideo(videos[_currentIndex]);
      }
    });
  }

  /// Updates a video item in the playlist (e.g., after caching or saving progress).
  void updateVideoItem(VideoPlaybackItem updatedVideo) {
    state = AsyncValue.data(
      state.when(
        data: (videos) {
          final index = videos.indexWhere((v) => v.id == updatedVideo.id);
          if (index != -1) {
            final newVideos = List<VideoPlaybackItem>.from(videos);
            newVideos[index] = updatedVideo;
            return newVideos;
          }
          return videos;
        },
        loading: () => [],
        error: (e, st) => [],
      ),
    );
  }
}

/// Manages the BetterPlayerController lifecycle and state.
@Riverpod(keepAlive: true)
class VideoPlayerControllerNotifier extends _$VideoPlayerControllerNotifier {
  BetterPlayerController? _betterPlayerController;
  VideoPlaybackItem? _currentPlayingVideo; // Track the current video object

  @override
  BetterPlayerController? build() {
    ref.onDispose(() {
      _betterPlayerController?.dispose();
    });
    return null; // Initial state
  }

  VideoPlaybackItem? get currentPlayingVideo => _currentPlayingVideo;

  Future<void> playVideo(VideoPlaybackItem video) async {
    // Dispose previous controller if it exists
    _betterPlayerController?.dispose();
    _betterPlayerController = null;
    _currentPlayingVideo = null; // Clear current playing video

    final cacheService = ref.read(cacheServiceProvider);
    final historyService = ref.read(playbackHistoryServiceProvider);

    BetterPlayerDataSource betterPlayerDataSource;

    // 1. Try playing from local cache first
    String? cachedPath = await cacheService.getCachedVideoPath(video.videoUrl);
    if (cachedPath != null) {
      debugPrint('Playing ${video.title} from cache: $cachedPath');
      betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        cachedPath,
      );
      // Update the playlist item to reflect it's cached
      ref.read(playlistNotifierProvider.notifier).updateVideoItem(video.copyWith(isCached: true, localCachePath: cachedPath));
    } else if (video.videoUrl.startsWith('local_bytes_video_placeholder')) {
      // 2. Simulate playing from Uint8List (needs actual bytes) using an isolate
      debugPrint('Attempting to play ${video.title} from Uint8List (simulated) using isolate');
      // For a real scenario, you'd load actual bytes here. For this example, we'll use dummy bytes.
      // You would replace this with actual logic to get the Uint8List for playback.
      final Uint8List dummyBytes = Uint8List.fromList([
        // This is a placeholder. You'd load actual video bytes here.
        // For demonstration, you might load a very small, valid MP4 header
        // or a completely dummy array. Real video files are large.
        // For now, it will likely fallback to the network URL.
      ]);
      final String? tempFilePath = await cacheService.playVideoFromUint8List(dummyBytes, video.id);
      if (tempFilePath != null) {
        betterPlayerDataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.file, tempFilePath);
      } else {
        debugPrint('Failed to play Uint8List from isolate, falling back to network if available');
        betterPlayerDataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.network, 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
      }
    } else {
      // 3. Play from remote URL and try to cache in background
      debugPrint('Playing ${video.title} from network: ${video.videoUrl}');
      betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        video.videoUrl,
      );
      // Trigger caching in background, but don't await it to avoid blocking playback
      cacheService.cacheVideo(video.videoUrl).then((path) {
        if (path != null) {
          debugPrint('Video ${video.title} cached successfully at $path');
          ref.read(playlistNotifierProvider.notifier).updateVideoItem(video.copyWith(isCached: true, localCachePath: path));
        }
      });
    }

    try {
      _betterPlayerController = BetterPlayerController(
        const BetterPlayerConfiguration(
          aspectRatio: 16 / 9,
          autoPlay: true,
          looping: false,
          fit: BoxFit.contain,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableFullscreen: true,
            enableMute: true,
            enablePlayPause: true,
            enableProgressBar: true,
            enableSkips: true,
            enableSubtitles: false,
            enablePlaybackSpeed: true,
            enablePip: true, // Enable Picture-in-Picture
            enableQualities: true,
            showControls: true,
            showControlsOnInitialize: true,
            playerTheme: BetterPlayerTheme.material,
            iconsColor: Colors.white,
            progressBarPlayedColor: Colors.blueAccent,
            progressBarHandleColor: Colors.blueAccent,
          ),
          eventListener: _betterPlayerEventCallback,
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );

      // Event listener for playback progress and completion
      _betterPlayerController!.addEventsListener((BetterPlayerEvent event) {
        if (event.betterPlayerEventType == BetterPlayerEventType.play) {
          _betterPlayerController?.videoPlayerController?.position.then((position) async {
             if (position != null && position != Duration.zero && position < (_betterPlayerController?.videoPlayerController?.value.duration ?? Duration.zero)) {
                await _betterPlayerController?.seekTo(position);
                debugPrint('Resuming ${video.title} from $position');
             } else if(video.lastPlayPosition != Duration.zero && video.lastPlayPosition < (_betterPlayerController?.videoPlayerController?.value.duration ?? Duration.zero)){
                await _betterPlayerController?.seekTo(video.lastPlayPosition);
                debugPrint('Resuming ${video.title} from ${video.lastPlayPosition}');
             }
          });
        }
        if (_betterPlayerController != null && _betterPlayerController!.videoPlayerController!.value.isPlaying && _betterPlayerController!.videoPlayerController!.value.position != _betterPlayerController!.videoPlayerController!.value.duration) {
          // Update the current playing video's last play position in the provider
          _currentPlayingVideo = video.copyWith(lastPlayPosition: _betterPlayerController!.videoPlayerController!.value.position);
          // Save to persistent storage (can be debounced in a real app)
          historyService.saveLastPlayPosition(video.id, _betterPlayerController!.videoPlayerController!.value.position);
          ref.read(playlistNotifierProvider.notifier).updateVideoItem(_currentPlayingVideo!);
        } else if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          debugPrint('${video.title} finished playing.');
          ref.read(playlistNotifierProvider.notifier).playNext();
        }
      });


      _currentPlayingVideo = video;
      state = _betterPlayerController;
    } catch (e, st) {
      debugPrint('Error initializing video player for ${video.title}: $e \n$st');
      state = null; // Reset state on error
      _currentPlayingVideo = null;
      // Optionally show a user-friendly error message
    }
  }

  // Placeholder for BetterPlayer event listener, can be expanded
  static void _betterPlayerEventCallback(BetterPlayerEvent event) {
    debugPrint("BetterPlayerEventType: ${event.betterPlayerEventType}");
  }

  /// Pause the current video.
  void pause() {
    _betterPlayerController?.pause();
  }

  /// Resume the current video.
  void resume() {
    _betterPlayerController?.play();
  }

  /// Seek to a specific position.
  void seek(Duration position) {
    _betterPlayerController?.seekTo(position);
  }
}

/// Provider for playback history, making it consumable by UI.
@Riverpod(keepAlive: true)
class PlaybackHistoryNotifier extends _$PlaybackHistoryNotifier {
  @override
  Future<Map<String, Duration>> build() async {
    // This notifier will update whenever a video's lastPlayPosition is saved.
    // For simplicity, we'll just read from the service directly.
    return {}; // Initial empty map
  }

  // You might add methods here to expose specific history details if needed
  // Or simply let other providers or widgets read directly from PlaybackHistoryService
}


