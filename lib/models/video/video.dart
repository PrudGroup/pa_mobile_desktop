import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prudapp/models/prud_vid.dart'; 

part 'video.freezed.dart';
part 'video.g.dart';

// Represents a simplified video item for playback in our player
@freezed
abstract class VideoPlaybackItem with _$VideoPlaybackItem {
  const factory VideoPlaybackItem({
    required String id,
    required String title,
    required String videoUrl,
    String? thumbnailUrl,
    @Default(Duration.zero) Duration lastPlayPosition, // Stores last known position
    String? localCachePath, // Path to cached file
    @Default(false) bool isCached, // Flag to indicate if video is cached
  }) = _VideoPlaybackItem;

  factory VideoPlaybackItem.fromJson(Map<String, dynamic> json) => _$VideoPlaybackItemFromJson(json);

  // Helper to convert your existing ChannelVideo model to VideoPlaybackItem
  factory VideoPlaybackItem.fromChannelVideo(ChannelVideo video) {
    return VideoPlaybackItem(
      id: video.id!,
      title: video.title,
      videoUrl: video.videoUrl,
      thumbnailUrl: video.videoThumbnail,
      lastPlayPosition: Duration.zero, // Will be updated from storage
      isCached: false, // Will be updated by cache service
    );
  }
}


