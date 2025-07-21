import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:prudapp/isolates.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart'; 

part 'cache_service.g.dart';


/// A service responsible for caching video files.
@Riverpod(keepAlive: true)
class CacheService extends _$CacheService {
  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  // Cache for 2 days (48 hours)
  final Duration cacheDuration = const Duration(days: 2);

  @override
  CacheService build() {
    return this;
  }

  /// Caches a video from a given URL.
  /// Returns the local path of the cached file if successful, otherwise null.
  Future<String?> cacheVideo(String url) async {
    try {
      // Get file from cache, or download if not present/expired
      final file = await _cacheManager.getSingleFile(
        url,
        key: url, // Use URL as key for simplicity
        headers: {}, // Add any necessary headers
      );

      // Check if the file is fresh enough, otherwise re-download might be needed
      // DefaultCacheManager handles expiry internally based on Cache-Control headers
      // or its internal maxAge property. For a fixed 2-day cache, we'd ensure
      // it's fetched if older than 2 days. For getSingleFile, it re-downloads if expired.
      if (file.existsSync()) {
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error caching video $url: $e');
      return null;
    }
  }

  /// Checks if a video is currently cached and returns its path.
  Future<String?> getCachedVideoPath(String url) async {
    final fileInfo = await _cacheManager.getFileFromCache(url);
    if (fileInfo != null && fileInfo.file.existsSync()) {
      // Optionally, check age of the file to ensure it's within the 2-day limit
      // If fileInfo.validTill is in the past, it means the cache manager considers it expired.
      // But for getSingleFile, it re-downloads if expired, so this check might be redundant if always using getSingleFile.
      final fileAge = DateTime.now().difference(fileInfo.file.lastModifiedSync());
      if (fileAge < cacheDuration) {
        return fileInfo.file.path;
      } else {
        // File is too old, remove it and return null to force re-download
        await _cacheManager.removeFile(url);
        return null;
      }
    }
    return null;
  }

  /// Plays a video from Uint8List by writing it to a temporary file using an Isolate.
  /// Returns the path to the temporary file.
  Future<String?> playVideoFromUint8List(Uint8List bytes, String filename) async {
    try {
      // Use compute to run file writing in a separate isolate
      final filePath = await compute(writeBytesToFileInIsolate, [bytes, filename]);
      return filePath;
    } catch (e) {
      debugPrint('Error writing Uint8List to file using isolate: $e');
      return null;
    }
  }
}