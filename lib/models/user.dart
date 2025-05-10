import 'dart:core';

import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/shape/gf_avatar_shape.dart';
import 'package:namefully/namefully.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/models/wallet.dart';

import 'aff_link.dart';
import 'bus_models.dart';

class User {
  String? id;
  String? email;
  String? fullName;
  String? country;
  String? deviceRegToken;
  bool? emailVerified;
  String? phoneNo;
  String? password;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? state;
  String? city;
  String? town;
  String? status;
  String? currencyCode;
  String? referralCode;
  Studio? studio;
  ContentCreator? contentCreator;
  List<ChannelSubscriber>? channelLinks;
  List<ChannelMembership>? memberedChannelLinks;
  InfluencerWallet? wallet;
  List<VideoClaimReport>? claims;
  List<VideoWatch>? watches;
  AffInstallReferral? appInstall;
  List<AffLink>? links;
  AffMerchantReferral? merchantReferral;
  List<AffPoint>? points;
  BusBrand? busBrand;
  BusBrandOperator? isBusOperator;
  List<JourneyPassenger>? journeysTaken;
  List<VideoThrillerComment>? thrillerComments;
  List<StreamBroadcastComment>? streamBroadcastComments;
  List<ChannelBroadcastComment>? channelBroadcastComments;
  List<VideoViewPurchase>? videoViewPurchases;

  User({
    this.id,
    this.deviceRegToken,
    this.password,
    this.country,
    this.phoneNo,
    this.email,
    this.fullName,
    this.createdAt,
    this.updatedAt,
    this.city,
    this.state,
    this.town,
    this.emailVerified,
    this.status,
    this.currencyCode,
    this.referralCode,
    this.studio,
    this.claims,
    this.watches,
    this.wallet,
    this.busBrand,
    this.links,
    this.appInstall,
    this.channelLinks,
    this.contentCreator,
    this.isBusOperator,
    this.journeysTaken,
    this.memberedChannelLinks,
    this.merchantReferral,
    this.points,
    this.thrillerComments,
    this.channelBroadcastComments,
    this.streamBroadcastComments,
    this.videoViewPurchases
  });

  Color bgColor(){
    var hash = 0;
    for (var i = 0; i < fullName!.length; i++) {
      hash = fullName!.codeUnitAt(i)+ ((hash << 5) - hash);
    }
    final finalHash = hash.abs() % (256*256*256);
    final red = ((finalHash & 0xFF0000) >> 16);
    final blue = ((finalHash & 0xFF00) >> 8);
    final green = ((finalHash & 0xFF));
    final color = Color.fromRGBO(red, green, blue, 1);
    return color;
  }

  Color invert() {
    Color bColor = bgColor();
    final r = 255 - bColor.r.toInt();
    final g = 255 - bColor.g.toInt();
    final b = 255 - bColor.b.toInt();

    return Color.fromARGB((bColor.a * 255).round(), r, g, b);
  }

  Widget getAvatar({double? size, int? shape, double? radius}){
    Namefully name = Namefully(fullName!);
    String initials = name.initials(withMid: false).join("");
    double avaSize = size?? 25.0;
    Color fgC = invert();
    return GFAvatar(
      size: avaSize,
      shape: shape == null || shape == 0? GFAvatarShape.circle : GFAvatarShape.square,
      backgroundColor: bgColor(),
      radius: radius,
      foregroundColor: fgC,
      child: Text(
        initials.toUpperCase(),
        style: prudWidgetStyle.hintStyle.copyWith(
          fontSize: avaSize / 2,
          color: fgC,
          fontWeight: FontWeight.bold
        ),
        textAlign: TextAlign.center
      )
    );
  }

  Map<String, dynamic> toJson() => {
    if(id != null) 'id': id,
    if(deviceRegToken != null) 'devicePushToken': deviceRegToken,
    if(fullName != null) 'fullname': fullName,
    if(password != null) 'password': password,
    if(email != null) 'email': email,
    if(country != null) 'country': country,
    if(state != null) 'state': state,
    if(city != null) 'city': city,
    if(currencyCode != null) 'currencyCode': currencyCode,
    if(town != null) 'town': town,
    if(referralCode != null) 'referralCode': referralCode,
    if(phoneNo != null) 'phoneNo': phoneNo,
    if(createdAt != null) 'createdAt': createdAt?.toIso8601String(),
    if(updatedAt != null) 'updatedAt': updatedAt?.toIso8601String()
  };

  factory User.fromJson(dynamic json) {
    return User(
      id: json['id'] as String?,
      deviceRegToken: json['devicePushToken'] as String?,
      password: json['password'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      town: json['town'] as String?,
      city: json['city'] as String?,
      phoneNo: json['phoneNo'] as String?,
      email: json['email'] as String?,
      currencyCode: json['currencyCode'] as String?,
      fullName: json['fullname'] as String?,
      referralCode: json['fullname'] as String?,
      createdAt: json['createdAt'] != null? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null? DateTime.parse(json['updatedAt']) : null,
      studio: json["studio"] != null? Studio.fromJson(json["studio"]) : null,
      contentCreator: json["contentCreator"] != null? ContentCreator.fromJson(json["contentCreator"]) : null,
      wallet: json["wallet"] != null? InfluencerWallet.fromJson(json["wallet"]) : null,
      appInstall: json["appInstall"] != null? AffInstallReferral.fromJson(json["appInstall"]) : null,
      merchantReferral: json["merchantReferral"] != null? AffMerchantReferral.fromJson(json["merchantReferral"]) : null,
      busBrand: json["busBrand"] != null? BusBrand.fromJson(json["busBrand"]) : null,
      isBusOperator: json["isBusOperator"] != null? BusBrandOperator.fromJson(json["isBusOperator"]) : null,
      channelLinks: json["channelLinks"]?.map<ChannelSubscriber>((itm) => ChannelSubscriber.fromJson(itm)).toList(),
      memberedChannelLinks: json["memberedChannelLinks"]?.map<ChannelMembership>((itm) => ChannelMembership.fromJson(itm)).toList(),
      claims: json["claims"]?.map<VideoClaimReport>((itm) => VideoClaimReport.fromJson(itm)).toList(),
      watches: json["watches"]?.map<VideoWatch>((itm) => VideoWatch.fromJson(itm)).toList(),
      links: json["links"]?.map<AffLink>((itm) => AffLink.fromJson(itm)).toList(),
      points: json["points"]?.map<AffPoint>((itm) => AffPoint.fromJson(itm)).toList(),
      journeysTaken: json["journeysTaken"]?.map<JourneyPassenger>((itm) => JourneyPassenger.fromJson(itm)).toList(),
      thrillerComments: json["thrillerComments"]?.map<VideoThrillerComment>((itm) => VideoThrillerComment.fromJson(itm)).toList(),
      streamBroadcastComments: json["streamBroadcastComments"]?.map<StreamBroadcastComment>((itm) => StreamBroadcastComment.fromJson(itm)).toList(),
      channelBroadcastComments: json["channelBroadcastComments"]?.map<ChannelBroadcastComment>((itm) => ChannelBroadcastComment.fromJson(itm)).toList(),
      videoViewPurchases: json["videoViewPurchases"]?.map<VideoViewPurchase>((itm) => VideoViewPurchase.fromJson(itm)).toList(),
    );
  }
}
