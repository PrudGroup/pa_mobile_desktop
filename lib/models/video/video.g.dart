// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoPlaybackItem _$VideoPlaybackItemFromJson(Map<String, dynamic> json) =>
    _VideoPlaybackItem(
      id: json['id'] as String,
      title: json['title'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      lastPlayPosition: json['lastPlayPosition'] == null
          ? Duration.zero
          : Duration(microseconds: (json['lastPlayPosition'] as num).toInt()),
      localCachePath: json['localCachePath'] as String?,
      isCached: json['isCached'] as bool? ?? false,
    );

Map<String, dynamic> _$VideoPlaybackItemToJson(_VideoPlaybackItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'lastPlayPosition': instance.lastPlayPosition.inMicroseconds,
      'localCachePath': instance.localCachePath,
      'isCached': instance.isCached,
    };
