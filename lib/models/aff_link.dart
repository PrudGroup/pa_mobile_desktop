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
  String? id;
  String code;
  String affId;
  User? affiliate;
  int totalInstalls;
  DateTime? createdOn;
  DateTime? updatedOn;
  List<AffInstallReferralMetric>? metrics;

  AffInstallReferral({
    required this.affId,
    required this.code,
    this.totalInstalls = 0,
    this.affiliate,
    this.createdOn,
    this.id,
    this.updatedOn,
    this.metrics
  });

  Map<String, dynamic> toJson(){
    return {
      if(createdOn != null) "createdOn": createdOn!.toIso8601String(),
      if(updatedOn != null) "updatedOn": updatedOn!.toIso8601String(),
      if(id != null) "id": id,
      "affId": affId,
      "code": code,
      "totalInstalls": totalInstalls,
    };
  }

  factory AffInstallReferral.fromJson(Map<String, dynamic> json){
    return AffInstallReferral(
      totalInstalls: json["totalInstalls"],
      id: json["id"],
      code: json["code"],
      affId: json["affId"],
      affiliate: json["affiliate"] != null? User.fromJson(json["affiliate"]) : null,
      createdOn: json["createdOn"] != null? DateTime.parse(json["createdOn"]) : null,
      updatedOn: json["updatedOn"] != null? DateTime.parse(json["updatedOn"]) : null,
      metrics: json["metrics"]?.map<AffInstallReferralMetric>((itm) => AffInstallReferralMetric.fromJson(itm))
    );
  }
}


class AffInstallReferralMetric{
  String id;
  String referralId;
  AffInstallReferral? referral;
  int day;
  int month;
  int year;
  double incomeInEuro;
  bool paid;
  DateTime? paidOn;
  DateTime? createdOn;
  DateTime? lastUpdatedOn;

  AffInstallReferralMetric({
    required this.id,
    required this.day,
    required this.month,
    required this.year,
    required this.paid,
    required this.referralId,
    required this.incomeInEuro,
    this.referral,
    this.createdOn,
    this.lastUpdatedOn,
    this.paidOn
  });

  Map<String, dynamic> toJson(){
    return {
      if(lastUpdatedOn != null) "lastUpdatedOn": lastUpdatedOn!.toIso8601String(),
      if(createdOn != null) "createdOn": createdOn!.toIso8601String(),
      if(paidOn != null) "paidOn": paidOn!.toIso8601String(),
      "incomeInEuro": incomeInEuro,
      "referralId": referralId,
      "paid": paid,
      "month": month,
      "year": year,
      "day": day,
      "id": id,
    };
  }

  factory AffInstallReferralMetric.fromJson(Map<String, dynamic> json){
    return AffInstallReferralMetric(
      id: json["id"], 
      day: json["day"], 
      month: json["month"], 
      year: json["year"],
      paid: json["paid"],
      referralId: json["referralId"],
      incomeInEuro: json["incomeInEuro"],
      referral: json["referral"] != null? AffInstallReferral.fromJson(json["referral"]) : null,
      createdOn: json["createdOn"] != null? DateTime.parse(json["createdOn"]) : null,
      lastUpdatedOn: json["lastUpdatedOn"] != null? DateTime.parse(json["lastUpdatedOn"]) : null,
      paidOn: json["paidOn"] != null? DateTime.parse(json["paidOn"]) : null,
    );
  }
}