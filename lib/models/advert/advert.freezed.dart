// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'advert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdvertCosting {
  String get id;
  AdvertCostingType get costType;
  double get cost;
  String get currency;

  /// Create a copy of AdvertCosting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AdvertCostingCopyWith<AdvertCosting> get copyWith =>
      _$AdvertCostingCopyWithImpl<AdvertCosting>(
          this as AdvertCosting, _$identity);

  /// Serializes this AdvertCosting to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AdvertCosting &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.costType, costType) ||
                other.costType == costType) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, costType, cost, currency);

  @override
  String toString() {
    return 'AdvertCosting(id: $id, costType: $costType, cost: $cost, currency: $currency)';
  }
}

/// @nodoc
abstract mixin class $AdvertCostingCopyWith<$Res> {
  factory $AdvertCostingCopyWith(
          AdvertCosting value, $Res Function(AdvertCosting) _then) =
      _$AdvertCostingCopyWithImpl;
  @useResult
  $Res call(
      {String id, AdvertCostingType costType, double cost, String currency});
}

/// @nodoc
class _$AdvertCostingCopyWithImpl<$Res>
    implements $AdvertCostingCopyWith<$Res> {
  _$AdvertCostingCopyWithImpl(this._self, this._then);

  final AdvertCosting _self;
  final $Res Function(AdvertCosting) _then;

  /// Create a copy of AdvertCosting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? costType = null,
    Object? cost = null,
    Object? currency = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      costType: null == costType
          ? _self.costType
          : costType // ignore: cast_nullable_to_non_nullable
              as AdvertCostingType,
      cost: null == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AdvertCosting implements AdvertCosting {
  const _AdvertCosting(
      {required this.id,
      required this.costType,
      required this.cost,
      required this.currency});
  factory _AdvertCosting.fromJson(Map<String, dynamic> json) =>
      _$AdvertCostingFromJson(json);

  @override
  final String id;
  @override
  final AdvertCostingType costType;
  @override
  final double cost;
  @override
  final String currency;

  /// Create a copy of AdvertCosting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AdvertCostingCopyWith<_AdvertCosting> get copyWith =>
      __$AdvertCostingCopyWithImpl<_AdvertCosting>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AdvertCostingToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AdvertCosting &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.costType, costType) ||
                other.costType == costType) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, costType, cost, currency);

  @override
  String toString() {
    return 'AdvertCosting(id: $id, costType: $costType, cost: $cost, currency: $currency)';
  }
}

/// @nodoc
abstract mixin class _$AdvertCostingCopyWith<$Res>
    implements $AdvertCostingCopyWith<$Res> {
  factory _$AdvertCostingCopyWith(
          _AdvertCosting value, $Res Function(_AdvertCosting) _then) =
      __$AdvertCostingCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id, AdvertCostingType costType, double cost, String currency});
}

/// @nodoc
class __$AdvertCostingCopyWithImpl<$Res>
    implements _$AdvertCostingCopyWith<$Res> {
  __$AdvertCostingCopyWithImpl(this._self, this._then);

  final _AdvertCosting _self;
  final $Res Function(_AdvertCosting) _then;

  /// Create a copy of AdvertCosting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? costType = null,
    Object? cost = null,
    Object? currency = null,
  }) {
    return _then(_AdvertCosting(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      costType: null == costType
          ? _self.costType
          : costType // ignore: cast_nullable_to_non_nullable
              as AdvertCostingType,
      cost: null == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Advert {
  String? get id; // Unique ID for the advert
  String get title;
  String? get description;
  String get advertiserId; // ID of the user creating the advert
  AdvertMediaType get mediaType;
  String?
      get mediaUrl; // URL for image or video (remote URL, or local path for upload)
  String? get thumbnailUrl; // For video ads
  String? get linkUrl; // URL to navigate to when advert is clicked
  bool
      get isInternalLink; // True if linkUrl points to content within the app (e.g., a specific video)
  String?
      get internalVideoId; // If isInternalLink is true and mediaType is video
  double get budget; // Total budget for the advert campaign
// Reintroduced: required AdvertCosting costing
  AdvertCosting get costing;
  double get currentSpend;
  int get impressions; // Count of times advert was displayed
  int get clicks; // Count of times advert was clicked
  int get watches; // Count of times video ads were "watched"
  int get totalWatchMinutes; // Total watch minutes for video ads
  DateTime get startDate;
  DateTime? get endDate; // Optional end date for campaign
  AdvertStatus get status;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of Advert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AdvertCopyWith<Advert> get copyWith =>
      _$AdvertCopyWithImpl<Advert>(this as Advert, _$identity);

  /// Serializes this Advert to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Advert &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.advertiserId, advertiserId) ||
                other.advertiserId == advertiserId) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl) &&
            (identical(other.isInternalLink, isInternalLink) ||
                other.isInternalLink == isInternalLink) &&
            (identical(other.internalVideoId, internalVideoId) ||
                other.internalVideoId == internalVideoId) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.costing, costing) || other.costing == costing) &&
            (identical(other.currentSpend, currentSpend) ||
                other.currentSpend == currentSpend) &&
            (identical(other.impressions, impressions) ||
                other.impressions == impressions) &&
            (identical(other.clicks, clicks) || other.clicks == clicks) &&
            (identical(other.watches, watches) || other.watches == watches) &&
            (identical(other.totalWatchMinutes, totalWatchMinutes) ||
                other.totalWatchMinutes == totalWatchMinutes) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        advertiserId,
        mediaType,
        mediaUrl,
        thumbnailUrl,
        linkUrl,
        isInternalLink,
        internalVideoId,
        budget,
        costing,
        currentSpend,
        impressions,
        clicks,
        watches,
        totalWatchMinutes,
        startDate,
        endDate,
        status,
        createdAt,
        updatedAt
      ]);

  @override
  String toString() {
    return 'Advert(id: $id, title: $title, description: $description, advertiserId: $advertiserId, mediaType: $mediaType, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, linkUrl: $linkUrl, isInternalLink: $isInternalLink, internalVideoId: $internalVideoId, budget: $budget, costing: $costing, currentSpend: $currentSpend, impressions: $impressions, clicks: $clicks, watches: $watches, totalWatchMinutes: $totalWatchMinutes, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $AdvertCopyWith<$Res> {
  factory $AdvertCopyWith(Advert value, $Res Function(Advert) _then) =
      _$AdvertCopyWithImpl;
  @useResult
  $Res call(
      {String? id,
      String title,
      String? description,
      String advertiserId,
      AdvertMediaType mediaType,
      String? mediaUrl,
      String? thumbnailUrl,
      String? linkUrl,
      bool isInternalLink,
      String? internalVideoId,
      double budget,
      AdvertCosting costing,
      double currentSpend,
      int impressions,
      int clicks,
      int watches,
      int totalWatchMinutes,
      DateTime startDate,
      DateTime? endDate,
      AdvertStatus status,
      DateTime? createdAt,
      DateTime? updatedAt});

  $AdvertCostingCopyWith<$Res> get costing;
}

/// @nodoc
class _$AdvertCopyWithImpl<$Res> implements $AdvertCopyWith<$Res> {
  _$AdvertCopyWithImpl(this._self, this._then);

  final Advert _self;
  final $Res Function(Advert) _then;

  /// Create a copy of Advert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? advertiserId = null,
    Object? mediaType = null,
    Object? mediaUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? linkUrl = freezed,
    Object? isInternalLink = null,
    Object? internalVideoId = freezed,
    Object? budget = null,
    Object? costing = null,
    Object? currentSpend = null,
    Object? impressions = null,
    Object? clicks = null,
    Object? watches = null,
    Object? totalWatchMinutes = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      advertiserId: null == advertiserId
          ? _self.advertiserId
          : advertiserId // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _self.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as AdvertMediaType,
      mediaUrl: freezed == mediaUrl
          ? _self.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      linkUrl: freezed == linkUrl
          ? _self.linkUrl
          : linkUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isInternalLink: null == isInternalLink
          ? _self.isInternalLink
          : isInternalLink // ignore: cast_nullable_to_non_nullable
              as bool,
      internalVideoId: freezed == internalVideoId
          ? _self.internalVideoId
          : internalVideoId // ignore: cast_nullable_to_non_nullable
              as String?,
      budget: null == budget
          ? _self.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double,
      costing: null == costing
          ? _self.costing
          : costing // ignore: cast_nullable_to_non_nullable
              as AdvertCosting,
      currentSpend: null == currentSpend
          ? _self.currentSpend
          : currentSpend // ignore: cast_nullable_to_non_nullable
              as double,
      impressions: null == impressions
          ? _self.impressions
          : impressions // ignore: cast_nullable_to_non_nullable
              as int,
      clicks: null == clicks
          ? _self.clicks
          : clicks // ignore: cast_nullable_to_non_nullable
              as int,
      watches: null == watches
          ? _self.watches
          : watches // ignore: cast_nullable_to_non_nullable
              as int,
      totalWatchMinutes: null == totalWatchMinutes
          ? _self.totalWatchMinutes
          : totalWatchMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as AdvertStatus,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of Advert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AdvertCostingCopyWith<$Res> get costing {
    return $AdvertCostingCopyWith<$Res>(_self.costing, (value) {
      return _then(_self.copyWith(costing: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _Advert implements Advert {
  const _Advert(
      {this.id,
      required this.title,
      this.description,
      required this.advertiserId,
      required this.mediaType,
      this.mediaUrl,
      this.thumbnailUrl,
      this.linkUrl,
      this.isInternalLink = false,
      this.internalVideoId,
      required this.budget,
      required this.costing,
      this.currentSpend = 0.0,
      this.impressions = 0,
      this.clicks = 0,
      this.watches = 0,
      this.totalWatchMinutes = 0,
      required this.startDate,
      this.endDate,
      this.status = AdvertStatus.pending,
      this.createdAt,
      this.updatedAt});
  factory _Advert.fromJson(Map<String, dynamic> json) => _$AdvertFromJson(json);

  @override
  final String? id;
// Unique ID for the advert
  @override
  final String title;
  @override
  final String? description;
  @override
  final String advertiserId;
// ID of the user creating the advert
  @override
  final AdvertMediaType mediaType;
  @override
  final String? mediaUrl;
// URL for image or video (remote URL, or local path for upload)
  @override
  final String? thumbnailUrl;
// For video ads
  @override
  final String? linkUrl;
// URL to navigate to when advert is clicked
  @override
  @JsonKey()
  final bool isInternalLink;
// True if linkUrl points to content within the app (e.g., a specific video)
  @override
  final String? internalVideoId;
// If isInternalLink is true and mediaType is video
  @override
  final double budget;
// Total budget for the advert campaign
// Reintroduced: required AdvertCosting costing
  @override
  final AdvertCosting costing;
  @override
  @JsonKey()
  final double currentSpend;
  @override
  @JsonKey()
  final int impressions;
// Count of times advert was displayed
  @override
  @JsonKey()
  final int clicks;
// Count of times advert was clicked
  @override
  @JsonKey()
  final int watches;
// Count of times video ads were "watched"
  @override
  @JsonKey()
  final int totalWatchMinutes;
// Total watch minutes for video ads
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
// Optional end date for campaign
  @override
  @JsonKey()
  final AdvertStatus status;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of Advert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AdvertCopyWith<_Advert> get copyWith =>
      __$AdvertCopyWithImpl<_Advert>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AdvertToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Advert &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.advertiserId, advertiserId) ||
                other.advertiserId == advertiserId) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl) &&
            (identical(other.isInternalLink, isInternalLink) ||
                other.isInternalLink == isInternalLink) &&
            (identical(other.internalVideoId, internalVideoId) ||
                other.internalVideoId == internalVideoId) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.costing, costing) || other.costing == costing) &&
            (identical(other.currentSpend, currentSpend) ||
                other.currentSpend == currentSpend) &&
            (identical(other.impressions, impressions) ||
                other.impressions == impressions) &&
            (identical(other.clicks, clicks) || other.clicks == clicks) &&
            (identical(other.watches, watches) || other.watches == watches) &&
            (identical(other.totalWatchMinutes, totalWatchMinutes) ||
                other.totalWatchMinutes == totalWatchMinutes) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        advertiserId,
        mediaType,
        mediaUrl,
        thumbnailUrl,
        linkUrl,
        isInternalLink,
        internalVideoId,
        budget,
        costing,
        currentSpend,
        impressions,
        clicks,
        watches,
        totalWatchMinutes,
        startDate,
        endDate,
        status,
        createdAt,
        updatedAt
      ]);

  @override
  String toString() {
    return 'Advert(id: $id, title: $title, description: $description, advertiserId: $advertiserId, mediaType: $mediaType, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, linkUrl: $linkUrl, isInternalLink: $isInternalLink, internalVideoId: $internalVideoId, budget: $budget, costing: $costing, currentSpend: $currentSpend, impressions: $impressions, clicks: $clicks, watches: $watches, totalWatchMinutes: $totalWatchMinutes, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$AdvertCopyWith<$Res> implements $AdvertCopyWith<$Res> {
  factory _$AdvertCopyWith(_Advert value, $Res Function(_Advert) _then) =
      __$AdvertCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String title,
      String? description,
      String advertiserId,
      AdvertMediaType mediaType,
      String? mediaUrl,
      String? thumbnailUrl,
      String? linkUrl,
      bool isInternalLink,
      String? internalVideoId,
      double budget,
      AdvertCosting costing,
      double currentSpend,
      int impressions,
      int clicks,
      int watches,
      int totalWatchMinutes,
      DateTime startDate,
      DateTime? endDate,
      AdvertStatus status,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $AdvertCostingCopyWith<$Res> get costing;
}

/// @nodoc
class __$AdvertCopyWithImpl<$Res> implements _$AdvertCopyWith<$Res> {
  __$AdvertCopyWithImpl(this._self, this._then);

  final _Advert _self;
  final $Res Function(_Advert) _then;

  /// Create a copy of Advert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? advertiserId = null,
    Object? mediaType = null,
    Object? mediaUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? linkUrl = freezed,
    Object? isInternalLink = null,
    Object? internalVideoId = freezed,
    Object? budget = null,
    Object? costing = null,
    Object? currentSpend = null,
    Object? impressions = null,
    Object? clicks = null,
    Object? watches = null,
    Object? totalWatchMinutes = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_Advert(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      advertiserId: null == advertiserId
          ? _self.advertiserId
          : advertiserId // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _self.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as AdvertMediaType,
      mediaUrl: freezed == mediaUrl
          ? _self.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      linkUrl: freezed == linkUrl
          ? _self.linkUrl
          : linkUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isInternalLink: null == isInternalLink
          ? _self.isInternalLink
          : isInternalLink // ignore: cast_nullable_to_non_nullable
              as bool,
      internalVideoId: freezed == internalVideoId
          ? _self.internalVideoId
          : internalVideoId // ignore: cast_nullable_to_non_nullable
              as String?,
      budget: null == budget
          ? _self.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double,
      costing: null == costing
          ? _self.costing
          : costing // ignore: cast_nullable_to_non_nullable
              as AdvertCosting,
      currentSpend: null == currentSpend
          ? _self.currentSpend
          : currentSpend // ignore: cast_nullable_to_non_nullable
              as double,
      impressions: null == impressions
          ? _self.impressions
          : impressions // ignore: cast_nullable_to_non_nullable
              as int,
      clicks: null == clicks
          ? _self.clicks
          : clicks // ignore: cast_nullable_to_non_nullable
              as int,
      watches: null == watches
          ? _self.watches
          : watches // ignore: cast_nullable_to_non_nullable
              as int,
      totalWatchMinutes: null == totalWatchMinutes
          ? _self.totalWatchMinutes
          : totalWatchMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as AdvertStatus,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of Advert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AdvertCostingCopyWith<$Res> get costing {
    return $AdvertCostingCopyWith<$Res>(_self.costing, (value) {
      return _then(_self.copyWith(costing: value));
    });
  }
}

// dart format on
