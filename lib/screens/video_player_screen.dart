import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:prudapp/components/playlist_component.dart';
import 'package:prudapp/models/video/video.dart';
import 'package:prudapp/providers/video_player_providers.dart'; 

class VideoPlayerScreen extends ConsumerWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the video player state
    final betterPlayerController = ref.watch(videoPlayerControllerNotifierProvider);
    final playlistState = ref.watch(playlistNotifierProvider);
    final playlistNotifier = ref.read(playlistNotifierProvider.notifier);
    final videoPlayerNotifier = ref.read(videoPlayerControllerNotifierProvider.notifier);
    final currentPlayingVideo = videoPlayerNotifier.currentPlayingVideo;

    // Determine if the device is in a landscape orientation
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: isLandscape
          ? null // Hide app bar in landscape for a more immersive video experience
          : AppBar(
              title: const Text('PrudApp Video Player'),
              centerTitle: true,
            ),
      body: SafeArea( // Use SafeArea to avoid notches and dynamic islands
        child: Column(
          children: [
            // Video Player Area - always takes full width, and adapts height
            if (betterPlayerController != null)
              AspectRatio(
                aspectRatio: betterPlayerController.betterPlayerConfiguration.aspectRatio ?? 16 / 9,
                child: BetterPlayer(controller: betterPlayerController),
              )
            else if (currentPlayingVideo != null)
              // Show a loading indicator while video is preparing or on error
              AspectRatio(
                aspectRatio: 16 / 9, // Standard aspect ratio for loading
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          'Loading video...',
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // Placeholder when no video is loaded
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: Text(
                      'No video loaded. Select one from the playlist below!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            // Playlist and Controls - arranged based on orientation
            Expanded(
              child: isLandscape
                  ? Row(
                      children: [
                        // Optional: smaller controls or information in landscape
                        Expanded(
                          flex: 1, // Adjust flex as needed
                          child: _buildControlsAndInfo(context, currentPlayingVideo, playlistNotifier, videoPlayerNotifier),
                        ),
                        // Main Playlist view
                        Expanded(
                          flex: 2, // Adjust flex as needed
                          child: Playlist(
                            playlistState: playlistState, 
                            currentPlayingVideo: currentPlayingVideo, 
                            playlistNotifier: playlistNotifier
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildControlsAndInfo(context, currentPlayingVideo, playlistNotifier, videoPlayerNotifier),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Playlist(
                            playlistState: playlistState, 
                            currentPlayingVideo: currentPlayingVideo, 
                            playlistNotifier: playlistNotifier
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build common controls and video info
  Widget _buildControlsAndInfo(BuildContext context, VideoPlaybackItem? currentPlayingVideo, PlaylistNotifier playlistNotifier, VideoPlayerControllerNotifier videoPlayerNotifier) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentPlayingVideo != null)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPlayingVideo.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Playing from: ${currentPlayingVideo.isCached ? 'Cached' : 'Network'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                    if (currentPlayingVideo.lastPlayPosition > Duration.zero)
                      Text(
                        'Last played: ${currentPlayingVideo.lastPlayPosition.inSeconds}s',
                        style: TextStyle(fontSize: 14, color: Colors.orange.shade700),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  playlistNotifier.playPrevious();
                },
                icon: const Icon(Icons.skip_previous_rounded),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  playlistNotifier.playNext();
                },
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
}