import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prudapp/models/video/video.dart';
import 'package:prudapp/providers/video_player_providers.dart';

class Playlist extends StatelessWidget {
  final AsyncValue<List<VideoPlaybackItem>> playlistState;
  final VideoPlaybackItem? currentPlayingVideo;
  final PlaylistNotifier playlistNotifier;

  const Playlist({
    super.key, required this.playlistState, 
    this.currentPlayingVideo, required this.playlistNotifier
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Playlist:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800),
        ),
        const SizedBox(height: 10),
        playlistState.when(
          data: (videos) {
            if (videos.isEmpty) {
              return const Center(child: Text('No videos in playlist.'));
            }
            return Expanded(
              child: ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final isCurrent = video.id == (currentPlayingVideo?.id ?? '');
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    color: isCurrent ? Colors.blue.shade100 : Colors.white,
                    elevation: isCurrent ? 4 : 2,
                    child: ListTile(
                      leading: video.thumbnailUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                video.thumbnailUrl!,
                                width: 60,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 60,
                                  height: 40,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                                ),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.video_collection, size: 28, color: Colors.grey),
                            ),
                      title: Text(
                        video.title,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? Colors.blue.shade800 : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${video.id}',
                            style: TextStyle(fontSize: 12, color: const Color.fromRGBO(117, 117, 117, 1)),
                          ),
                          if (video.isCached)
                            Text(
                              'Status: Cached',
                              style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                            ),
                          if (video.lastPlayPosition > Duration.zero)
                            Text(
                              'Last played: ${video.lastPlayPosition.inSeconds}s',
                              style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                            ),
                        ],
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.play_arrow, color: Colors.blue)
                          : null,
                      onTap: () {
                        playlistNotifier.playAtIndex(index);
                      },
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error loading playlist: $e')),
        ),
      ],
    );
  }
}