// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdvertCosting _$AdvertCostingFromJson(Map<String, dynamic> json) =>
    _AdvertCosting(
      id: json['id'] as String,
      costType: $enumDecode(_$AdvertCostingTypeEnumMap, json['costType']),
      cost: (json['cost'] as num).toDouble(),
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$AdvertCostingToJson(_AdvertCosting instance) =>
    <String, dynamic>{
      'id': instance.id,
      'costType': _$AdvertCostingTypeEnumMap[instance.costType]!,
      'cost': instance.cost,
      'currency': instance.currency,
    };

const _$AdvertCostingTypeEnumMap = {
  AdvertCostingType.perClick: 'perClick',
  AdvertCostingType.perImpression: 'perImpression',
  AdvertCostingType.perWatch: 'perWatch',
};

_Advert _$AdvertFromJson(Map<String, dynamic> json) => _Advert(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      advertiserId: json['advertiserId'] as String,
      mediaType: $enumDecode(_$AdvertMediaTypeEnumMap, json['mediaType']),
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      linkUrl: json['linkUrl'] as String?,
      isInternalLink: json['isInternalLink'] as bool? ?? false,
      internalVideoId: json['internalVideoId'] as String?,
      budget: (json['budget'] as num).toDouble(),
      costing: AdvertCosting.fromJson(json['costing'] as Map<String, dynamic>),
      currentSpend: (json['currentSpend'] as num?)?.toDouble() ?? 0.0,
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      watches: (json['watches'] as num?)?.toInt() ?? 0,
      totalWatchMinutes: (json['totalWatchMinutes'] as num?)?.toInt() ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: $enumDecodeNullable(_$AdvertStatusEnumMap, json['status']) ??
          AdvertStatus.pending,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AdvertToJson(_Advert instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'advertiserId': instance.advertiserId,
      'mediaType': _$AdvertMediaTypeEnumMap[instance.mediaType]!,
      'mediaUrl': instance.mediaUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'linkUrl': instance.linkUrl,
      'isInternalLink': instance.isInternalLink,
      'internalVideoId': instance.internalVideoId,
      'budget': instance.budget,
      'costing': instance.costing,
      'currentSpend': instance.currentSpend,
      'impressions': instance.impressions,
      'clicks': instance.clicks,
      'watches': instance.watches,
      'totalWatchMinutes': instance.totalWatchMinutes,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': _$AdvertStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AdvertMediaTypeEnumMap = {
  AdvertMediaType.image: 'image',
  AdvertMediaType.video: 'video',
  AdvertMediaType.text: 'text',
};

const _$AdvertStatusEnumMap = {
  AdvertStatus.pending: 'pending',
  AdvertStatus.active: 'active',
  AdvertStatus.paused: 'paused',
  AdvertStatus.completed: 'completed',
  AdvertStatus.rejected: 'rejected',
  AdvertStatus.deleted: 'deleted',
};
