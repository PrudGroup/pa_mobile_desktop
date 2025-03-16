import 'package:prudapp/models/user.dart';

class AffLink {

  String? id;
  String? affId;
  int? totalSparks;
  String? shortenerId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? fullShortUrl;
  String category;
  String categoryId;
  User? affiliate;
  double affDiscountPercentage;
  String target;
  Shortener? shortener;
  List<AffLinkMetric>? metrics;

  AffLink({
    required this.categoryId,
    required this.category,
    required this.target,
    required this.affDiscountPercentage,
    this.id,
    this.affId,
    this.totalSparks = 0,
    this.shortenerId,
    this.createdAt,
    this.updatedAt,
    this.fullShortUrl,
    this.affiliate,
    this.metrics,
    this.shortener,
  });

  Map<String, dynamic> toJson(){
    return {
      "category": category,
      "categoryId": categoryId,
      "affDiscountPercentage": affDiscountPercentage,
      "target": target,
      if(id != null) "id": id,
      if(affId != null) "affId": affId,
      if(totalSparks != null) "totalSparks": totalSparks,
      if(shortenerId != null) "shortenerId": shortenerId,
      if(createdAt != null) "createdAt": createdAt!.toIso8601String(),
      if(updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
      if(fullShortUrl != null) "fullShortUrl": fullShortUrl,
    };
  }

  factory AffLink.fromJson(dynamic json){
    return AffLink(
      id: json["id"] as String?,
      target: json["target"],
      categoryId: json["categoryId"],
      category: json["category"],
      affDiscountPercentage: json["affDiscountPercentage"],
      affId: json["affId"] as String?,
      totalSparks: json["totalSparks"] as int?,
      shortenerId: json["shortenerId"] as String?,
      createdAt: json["createdAt"] != null? DateTime.parse(json["createdAt"]) : null,
      updatedAt: json["updatedAt"] != null? DateTime.parse(json["updatedAt"]) : null,
      fullShortUrl: json["fullShortUrl"] as String?,
      affiliate: json["affiliate"] != null? User.fromJson(json["affiliate"]) : null,
      metrics: json["metrics"]?.map<AffLinkMetric>((itm) => AffLinkMetric.fromJson(itm)).toList(),
      shortener: json["shortener"] != null? Shortener.fromJson(json["shortener"]) : null,
    );
  }
}


class AffLinkMetric{

  AffLinkMetric();

  Map<String, dynamic> toJson(){
    return {};
  }

  factory AffLinkMetric.fromJson(Map<String, dynamic> json){
    return AffLinkMetric();
  }
}

class Shortener{

  Shortener();

  Map<String, dynamic> toJson(){
    return {};
  }

  factory Shortener.fromJson(Map<String, dynamic> json){
    return Shortener();
  }
}

class AffPoint{

  AffPoint();

  Map<String, dynamic> toJson(){
    return {};
  }

  factory AffPoint.fromJson(Map<String, dynamic> json){
    return AffPoint();
  }
}

class AffMerchantReferral{

  AffMerchantReferral();

  Map<String, dynamic> toJson(){
    return {};
  }

  factory AffMerchantReferral.fromJson(Map<String, dynamic> json){
    return AffMerchantReferral();
  }
}

class AffInstallReferral{

  AffInstallReferral();

  Map<String, dynamic> toJson(){
    return {};
  }

  factory AffInstallReferral.fromJson(Map<String, dynamic> json){
    return AffInstallReferral();
  }
}