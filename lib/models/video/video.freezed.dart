// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoPlaybackItem {
  String get id;
  String get title;
  String get videoUrl;
  String? get thumbnailUrl;
  Duration get lastPlayPosition; // Stores last known position
  String? get localCachePath; // Path to cached file
  bool get isCached;

  /// Create a copy of VideoPlaybackItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VideoPlaybackItemCopyWith<VideoPlaybackItem> get copyWith =>
      _$VideoPlaybackItemCopyWithImpl<VideoPlaybackItem>(
          this as VideoPlaybackItem, _$identity);

  /// Serializes this VideoPlaybackItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VideoPlaybackItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.lastPlayPosition, lastPlayPosition) ||
                other.lastPlayPosition == lastPlayPosition) &&
            (identical(other.localCachePath, localCachePath) ||
                other.localCachePath == localCachePath) &&
            (identical(other.isCached, isCached) ||
                other.isCached == isCached));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, videoUrl,
      thumbnailUrl, lastPlayPosition, localCachePath, isCached);

  @override
  String toString() {
    return 'VideoPlaybackItem(id: $id, title: $title, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, lastPlayPosition: $lastPlayPosition, localCachePath: $localCachePath, isCached: $isCached)';
  }
}

/// @nodoc
abstract mixin class $VideoPlaybackItemCopyWith<$Res> {
  factory $VideoPlaybackItemCopyWith(
          VideoPlaybackItem value, $Res Function(VideoPlaybackItem) _then) =
      _$VideoPlaybackItemCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      String videoUrl,
      String? thumbnailUrl,
      Duration lastPlayPosition,
      String? localCachePath,
      bool isCached});
}

/// @nodoc
class _$VideoPlaybackItemCopyWithImpl<$Res>
    implements $VideoPlaybackItemCopyWith<$Res> {
  _$VideoPlaybackItemCopyWithImpl(this._self, this._then);

  final VideoPlaybackItem _self;
  final $Res Function(VideoPlaybackItem) _then;

  /// Create a copy of VideoPlaybackItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? videoUrl = null,
    Object? thumbnailUrl = freezed,
    Object? lastPlayPosition = null,
    Object? localCachePath = freezed,
    Object? isCached = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: null == videoUrl
          ? _self.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastPlayPosition: null == lastPlayPosition
          ? _self.lastPlayPosition
          : lastPlayPosition // ignore: cast_nullable_to_non_nullable
              as Duration,
      localCachePath: freezed == localCachePath
          ? _self.localCachePath
          : localCachePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isCached: null == isCached
          ? _self.isCached
          : isCached // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _VideoPlaybackItem implements VideoPlaybackItem {
  const _VideoPlaybackItem(
      {required this.id,
      required this.title,
      required this.videoUrl,
      this.thumbnailUrl,
      this.lastPlayPosition = Duration.zero,
      this.localCachePath,
      this.isCached = false});
  factory _VideoPlaybackItem.fromJson(Map<String, dynamic> json) =>
      _$VideoPlaybackItemFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String videoUrl;
  @override
  final String? thumbnailUrl;
  @override
  @JsonKey()
  final Duration lastPlayPosition;
// Stores last known position
  @override
  final String? localCachePath;
// Path to cached file
  @override
  @JsonKey()
  final bool isCached;

  /// Create a copy of VideoPlaybackItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VideoPlaybackItemCopyWith<_VideoPlaybackItem> get copyWith =>
      __$VideoPlaybackItemCopyWithImpl<_VideoPlaybackItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VideoPlaybackItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VideoPlaybackItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.lastPlayPosition, lastPlayPosition) ||
                other.lastPlayPosition == lastPlayPosition) &&
            (identical(other.localCachePath, localCachePath) ||
                other.localCachePath == localCachePath) &&
            (identical(other.isCached, isCached) ||
                other.isCached == isCached));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, videoUrl,
      thumbnailUrl, lastPlayPosition, localCachePath, isCached);

  @override
  String toString() {
    return 'VideoPlaybackItem(id: $id, title: $title, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, lastPlayPosition: $lastPlayPosition, localCachePath: $localCachePath, isCached: $isCached)';
  }
}

/// @nodoc
abstract mixin class _$VideoPlaybackItemCopyWith<$Res>
    implements $VideoPlaybackItemCopyWith<$Res> {
  factory _$VideoPlaybackItemCopyWith(
          _VideoPlaybackItem value, $Res Function(_VideoPlaybackItem) _then) =
      __$VideoPlaybackItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String videoUrl,
      String? thumbnailUrl,
      Duration lastPlayPosition,
      String? localCachePath,
      bool isCached});
}

/// @nodoc
class __$VideoPlaybackItemCopyWithImpl<$Res>
    implements _$VideoPlaybackItemCopyWith<$Res> {
  __$VideoPlaybackItemCopyWithImpl(this._self, this._then);

  final _VideoPlaybackItem _self;
  final $Res Function(_VideoPlaybackItem) _then;

  /// Create a copy of VideoPlaybackItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? videoUrl = null,
    Object? thumbnailUrl = freezed,
    Object? lastPlayPosition = null,
    Object? localCachePath = freezed,
    Object? isCached = null,
  }) {
    return _then(_VideoPlaybackItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: null == videoUrl
          ? _self.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastPlayPosition: null == lastPlayPosition
          ? _self.lastPlayPosition
          : lastPlayPosition // ignore: cast_nullable_to_non_nullable
              as Duration,
      localCachePath: freezed == localCachePath
          ? _self.localCachePath
          : localCachePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isCached: null == isCached
          ? _self.isCached
          : isCached // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
