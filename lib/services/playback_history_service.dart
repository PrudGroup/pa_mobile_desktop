import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // For Duration

/// A service for managing video playback history using shared preferences.
class PlaybackHistoryService {
  static const String _prefix = 'video_last_play_time_';

  /// Saves the last play position for a given video.
  Future<void> saveLastPlayPosition(String videoId, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix$videoId', position.inMilliseconds);
    debugPrint('Saved last play position for $videoId: ${position.inSeconds}s');
  }

  /// Retrieves the last play position for a given video.
  /// Returns Duration.zero if no history is found.
  Future<Duration> getLastPlayPosition(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final milliseconds = prefs.getInt('$_prefix$videoId') ?? 0;
    debugPrint('Retrieved last play position for $videoId: ${Duration(milliseconds: milliseconds).inSeconds}s');
    return Duration(milliseconds: milliseconds);
  }
}