import 'package:freezed_annotation/freezed_annotation.dart';

part 'advert.freezed.dart';
part 'advert.g.dart';

// Enum to define the type of media for the advert
enum AdvertMediaType {
  image,
  video,
  text, // For text-only adverts
}

// Enum to define how the advert is primarily billed/costed
enum AdvertCostingType {
  perClick,
  perImpression,
  perWatch,
}

// Enum to define the status of the advert
enum AdvertStatus {
  pending,
  active,
  paused,
  completed,
  rejected,
  deleted,
}

// AdvertCosting model (updated as per your request)
@freezed
abstract class AdvertCosting with _$AdvertCosting {
  const factory AdvertCosting({
    required String id,
    required AdvertCostingType costType,
    required double cost,
    required String currency,
  }) = _AdvertCosting;

  factory AdvertCosting.fromJson(Map<String, dynamic> json) => _$AdvertCostingFromJson(json);
}

@freezed
abstract class Advert with _$Advert {
  const factory Advert({
    String? id, // Unique ID for the advert
    required String title,
    String? description,
    required String advertiserId, // ID of the user creating the advert
    required AdvertMediaType mediaType,
    String? mediaUrl, // URL for image or video (remote URL, or local path for upload)
    String? thumbnailUrl, // For video ads
    String? linkUrl, // URL to navigate to when advert is clicked
    @Default(false) bool isInternalLink, // True if linkUrl points to content within the app (e.g., a specific video)
    String? internalVideoId, // If isInternalLink is true and mediaType is video
    required double budget, // Total budget for the advert campaign
    // Reintroduced: required AdvertCosting costing
    required AdvertCosting costing,
    @Default(0.0) double currentSpend,
    @Default(0) int impressions, // Count of times advert was displayed
    @Default(0) int clicks, // Count of times advert was clicked
    @Default(0) int watches, // Count of times video ads were "watched"
    @Default(0) int totalWatchMinutes, // Total watch minutes for video ads
    required DateTime startDate,
    DateTime? endDate, // Optional end date for campaign
    @Default(AdvertStatus.pending) AdvertStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Advert;

  factory Advert.fromJson(Map<String, dynamic> json) => _$AdvertFromJson(json);
}

