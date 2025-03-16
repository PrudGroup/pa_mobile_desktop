import 'dart:io';

import 'package:currency_picker/currency_picker.dart';
import 'package:prudapp/models/backblaze.dart';
import 'package:prudapp/models/user.dart';
import 'package:prudapp/models/wallet.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../pages/prudVid/studio/studioTabs/new_channel.dart';
import '../singletons/tab_data.dart';

class Studio {
  String? id;
  String studioName;
  String ownedBy;
  User? affiliate;
  DateTime? createdOn;
  List<VidChannel>? channels;
  StudioWallet? wallet;
  List<VidStream>? streams;

  Studio({
    required this.ownedBy,
    required this.studioName,
    this.id,
    this.wallet,
    this.createdOn,
    this.affiliate,
    this.channels,
    this.streams,
  });

  Map<String, dynamic> toJson() {
    return {
      "studioName": studioName,
      "ownedBy": ownedBy,
      if (id != null) "id": id,
      if (wallet != null) "wallet": wallet!.toJson(),
      if (createdOn != null) "createdOn": createdOn.toString(),
      if (affiliate != null) "affiliate": affiliate!.toJson(),
      if (channels != null)
        "channels": channels!.map((VidChannel cha) => cha.toJson()).toList(),
      if (streams != null)
        "streams": streams!.map((VidStream stm) => stm.toJson()).toList(),
    };
  }

  factory Studio.fromJson(Map<String, dynamic> json) {
    return Studio(
      id: json["id"],
      ownedBy: json["ownedBy"],
      studioName: json["studioName"],
      wallet:
          json["wallet"] != null ? StudioWallet.fromJson(json["wallet"]) : null,
      createdOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      affiliate:
          json["affiliate"] != null ? User.fromJson(json["affiliate"]) : null,
      channels: json["channels"]
          ?.map<VidChannel>((cha) => VidChannel.fromJson(cha))
          .toList(),
      streams: json["streams"]
          ?.map<VidStream>((cha) => VidStream.fromJson(cha))
          .toList(),
    );
  }
}

class NewChannelData {
  CreateChannelSteps step;
  String? channelName;
  String? logoUrl;
  String? displayScreenImage;
  String? category; // Movie, Music, Learn, News, Cuisines, Comedy
  String? countryCode;
  SfRangeValues? ageTargets;
  double sharePerView;
  double memberCost;
  double membershipCostInEuro;
  double streamServiceCost;
  double streamServiceCostInEuro;
  double sharePerMember;
  Currency? selectedCurrency;
  String? description;
  String? studioId;

  NewChannelData({
    this.description = "",
    this.selectedCurrency,
    this.countryCode = "NG",
    this.memberCost = 0,
    this.ageTargets,
    this.category,
    this.channelName = '',
    this.displayScreenImage,
    this.logoUrl,
    this.membershipCostInEuro = 0,
    this.sharePerMember = 45.0,
    this.sharePerView = 45.0,
    this.step = CreateChannelSteps.policy,
    this.streamServiceCost = 0,
    this.streamServiceCostInEuro = 0,
    this.studioId
  });

  CreateChannelSteps convertStringToStep(String str) {
    switch (str.toLowerCase()) {
      case "policy":
        return CreateChannelSteps.policy;
      case "step1":
        return CreateChannelSteps.step1;
      case "step2":
        return CreateChannelSteps.step2;
      case "step3":
        return CreateChannelSteps.step3;
      case "step4":
        return CreateChannelSteps.step4;
      case "step5":
        return CreateChannelSteps.step5;
      case "step6":
        return CreateChannelSteps.step6;
      case "step7":
        return CreateChannelSteps.step7;
      case "step8":
        return CreateChannelSteps.step8;
      case "success":
        return CreateChannelSteps.success;
      default:
        return CreateChannelSteps.failed;
    }
  }

  String convertStepToString() {
    switch (step) {
      case CreateChannelSteps.policy:
        return "policy";
      case CreateChannelSteps.step1:
        return "step1";
      case CreateChannelSteps.step2:
        return "step2";
      case CreateChannelSteps.step3:
        return "step3";
      case CreateChannelSteps.step4:
        return "step4";
      case CreateChannelSteps.step5:
        return "step5";
      case CreateChannelSteps.step6:
        return "step6";
      case CreateChannelSteps.step7:
        return "step7";
      case CreateChannelSteps.step8:
        return "step8";
      case CreateChannelSteps.success:
        return "success";
      default:
        return "failed";
    }
  }

  SfRangeValues convertValuesToAge(String? values) {
    if (values == null || values.isNotEmpty) return SfRangeValues(16.0, 30.0);
    List<String> strs = values.split(",");
    return SfRangeValues(double.parse(strs[0]), double.parse(strs[1]));
  }

  List<double> convertAgesToValues() {
    if (ageTargets == null) return [16.0, 30.0];
    return [
      currencyMath.roundDouble(ageTargets!.start.toDouble(), 1),
      currencyMath.roundDouble(ageTargets!.end.toDouble(), 1),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      "step": convertStepToString(),
      "ageTargets": convertAgesToValues().join(","),
      if (description != null) "description": description,
      if (channelName != null) "channelName": channelName,
      if (logoUrl != null) "logoUrl": logoUrl,
      if (displayScreenImage != null) "displayScreenImage": displayScreenImage,
      if (category != null) "category": category,
      if (countryCode != null) "countryCode": countryCode,
      "sharePerView": sharePerView,
      "memberCost": memberCost,
      "membershipCostInEuro": membershipCostInEuro,
      "streamServiceCost": streamServiceCost,
      "streamServiceCostInEuro": streamServiceCostInEuro,
      "sharePerMember": sharePerMember,
      if (selectedCurrency != null) "selectedCurrency": selectedCurrency!.code,
      if (studioId != null) "studioId": studioId,
    };
  }

  factory NewChannelData.fromJson(Map<String, dynamic> json) {
    return NewChannelData(
        step: NewChannelData().convertStringToStep(json["step"]),
        channelName: json["channelName"],
        logoUrl: json["logoUrl"],
        displayScreenImage: json["displayScreenImage"],
        category: json["category"],
        countryCode: json["countryCode"],
        sharePerView: json["sharePerView"],
        memberCost: json["memberCost"],
        membershipCostInEuro: json["membershipCostInEuro"],
        streamServiceCost: json["streamServiceCost"],
        streamServiceCostInEuro: json["streamServiceCostInEuro"],
        sharePerMember: json["sharePerMember"],
        description: json["description"],
        studioId: json["studioId"],
        selectedCurrency: json["selectedCurrency"] != null
            ? tabData.getCurrency(json["selectedCurrency"])
            : null,
        ageTargets: NewChannelData().convertValuesToAge(json["ageTargets"]));
  }

  VidChannel? toVidChannel() {
    return VidChannel(
        channelName: channelName!,
        contentPercentageSharePerView: sharePerView,
        monthlyMembershipCost: memberCost,
        monthlyMembershipCostInEuro: membershipCostInEuro,
        monthlyStreamingCost: streamServiceCost,
        monthlyStreamingCostInEuro: streamServiceCostInEuro,
        membershipPercentageSharePerMonth: sharePerMember,
        description: description!,
        displayScreen: displayScreenImage!,
        studioId: studioId!,
        logo: logoUrl!,
        countryCode: countryCode!,
        maxTargetAge: ageTargets!.end.toInt(),
        miniTargetAge: ageTargets!.start.toInt(),
        category: category!);
  }
}

class VidChannel {
  String? id;
  String channelName;
  bool verified;
  bool promoted;
  String logo;
  String displayScreen;
  String category; // Movie, Music, Learn, News, Cuisines, Comedy
  String subCategory; // Drama
  String countryCode;
  int miniTargetAge;
  int maxTargetAge;
  String studioId;
  Studio? studio;
  String description;
  bool blocked;
  bool presentlySeekingCreators;
  DateTime? createdOn;
  DateTime? updatedOn;
  double contentPercentageSharePerView;
  double monthlyMembershipCost;
  double monthlyMembershipCostInEuro;
  double monthlyStreamingCost;
  double monthlyStreamingCostInEuro;
  double membershipPercentageSharePerMonth;
  String channelCurrency;
  int totalSubscribers;
  int totalMembers;
  int votes;
  int voters;
  List<ContentCreator>? creators;
  List<ChannelSubscriber>? subscriberLinks;
  List<ChannelMembership>? memberLinks;
  List<ChannelMembershipMatrix>? membershipMatrix;
  List<ChannelVideo>? videos;
  List<StudioWalletHistory>? paymentHistories;
  List<StreamChannel>? streamServices;
  List<ContentCreatorRequest>? creatorRequests;
  PromoteChannel? sponsored;

  VidChannel(
      {required this.channelName,
      required this.contentPercentageSharePerView,
      required this.monthlyMembershipCost,
      required this.monthlyMembershipCostInEuro,
      required this.monthlyStreamingCost,
      required this.monthlyStreamingCostInEuro,
      required this.membershipPercentageSharePerMonth,
      required this.description,
      required this.displayScreen,
      required this.studioId,
      required this.logo,
      required this.countryCode,
      required this.maxTargetAge,
      required this.miniTargetAge,
      required this.category,
      this.subCategory = "Any",
      this.verified = false,
      this.promoted = false,
      this.blocked = false,
      this.presentlySeekingCreators = false,
      this.channelCurrency = "EUR",
      this.totalSubscribers = 0,
      this.totalMembers = 0,
      this.votes = 0,
      this.voters = 0,
      this.id,
      this.creators,
      this.studio,
      this.subscriberLinks,
      this.memberLinks,
      this.membershipMatrix,
      this.videos,
      this.paymentHistories,
      this.streamServices,
      this.creatorRequests,
      this.sponsored,
      this.createdOn,
      this.updatedOn});

  double getRating() {
    if (voters > 0 && votes > 0) return votes / voters;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      "channelName": channelName,
      "contentPercentageSharePerView": contentPercentageSharePerView,
      "monthlyMembershipCost": monthlyMembershipCost,
      "monthlyMembershipCostInEuro": monthlyMembershipCostInEuro,
      "monthlyStreamingCost": monthlyStreamingCost,
      "monthlyStreamingCostInEuro": monthlyStreamingCostInEuro,
      "membershipPercentageSharePerMonth": membershipPercentageSharePerMonth,
      "description": description,
      "displayScreen": displayScreen,
      "studioId": studioId,
      "logo": logo,
      "category": category,
      "subCategory": subCategory,
      "countryCode": countryCode,
      "miniTargetAge": miniTargetAge,
      "maxTargetAge": maxTargetAge,
      "verified": verified,
      "promoted": promoted,
      "blocked": blocked,
      "channelCurrency": channelCurrency,
      "totalSubscribers": totalSubscribers,
      "totalMembers": totalMembers,
      "votes": votes,
      "voters": voters,
      if (createdOn != null) "createdOn": createdOn.toString(),
      if (updatedOn != null) "updatedOn": updatedOn.toString(),
      if (id != null) "id": id,
    };
  }

  factory VidChannel.fromJson(Map<String, dynamic> json) {
    return VidChannel(
      id: json["id"],
      channelName: json["channelName"],
      contentPercentageSharePerView: json["contentPercentageSharePerView"],
      monthlyMembershipCost: json["monthlyMembershipCost"],
      monthlyMembershipCostInEuro: json["monthlyMembershipCostInEuro"],
      monthlyStreamingCost: json["monthlyStreamingCost"],
      monthlyStreamingCostInEuro: json["monthlyStreamingCostInEuro"],
      membershipPercentageSharePerMonth:
          json["membershipPercentageSharePerMonth"],
      description: json["description"],
      displayScreen: json["displayScreen"],
      studioId: json["studioId"],
      logo: json["logo"],
      subCategory: json["subCategory"],
      countryCode: json["countryCode"],
      maxTargetAge: json["maxTargetAge"],
      miniTargetAge: json["miniTargetAge"],
      verified: json["verified"],
      promoted: json["promoted"],
      blocked: json["blocked"],
      channelCurrency: json["channelCurrency"],
      totalSubscribers: json["totalSubscribers"],
      totalMembers: json["totalMembers"],
      category: json["category"],
      votes: json["votes"],
      voters: json["voters"],
      createdOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      updatedOn:
          json["updatedOn"] != null ? DateTime.parse(json["updatedOn"]) : null,
      streamServices: json["streamServices"]
          ?.map<StreamChannel>((cha) => StreamChannel.fromJson(cha))
          .toList(),
      creatorRequests: json["creatorRequests"]
          ?.map<ContentCreatorRequest>(
              (cha) => ContentCreatorRequest.fromJson(cha))
          .toList(),
      paymentHistories: json["paymentHistories"]
          ?.map<StudioWalletHistory>((cha) => StudioWalletHistory.fromJson(cha))
          .toList(),
      videos: json["videos"]
          ?.map<ChannelVideo>((cha) => ChannelVideo.fromJson(cha))
          .toList(),
      membershipMatrix: json["membershipMatrix"]
          ?.map<ChannelMembershipMatrix>(
              (cha) => ChannelMembershipMatrix.fromJson(cha))
          .toList(),
      memberLinks: json["memberLinks"]
          ?.map<ChannelMembership>((cha) => ChannelMembership.fromJson(cha))
          .toList(),
      subscriberLinks: json["subscriberLinks"]
          ?.map<ChannelSubscriber>((cha) => ChannelSubscriber.fromJson(cha))
          .toList(),
      creators: json["creators"]
          ?.map<ContentCreator>((cha) => ContentCreator.fromJson(cha))
          .toList(),
      sponsored: json["sponsored"] != null
          ? PromoteChannel.fromJson(json["sponsored"])
          : null,
    );
  }
}

class StudioWallet extends Wallet {
  String studioId;
  Studio? studio;
  List<StudioWalletHistory>? histories;
  List<StudioWalletTransfer>? transfers;

  StudioWallet(
      {required this.studioId,
      required super.balance,
      required super.balanceAsAt,
      required super.id,
      required super.createdOn,
      this.studio,
      this.histories,
      this.transfers});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = super.toJson();
    res["studioId"] = studioId;
    return res;
  }

  factory StudioWallet.fromJson(Map<String, dynamic> json) {
    Wallet wallet = Wallet.fromJson(json);
    return StudioWallet(
      studioId: json["studioId"],
      balance: wallet.balance,
      balanceAsAt: wallet.balanceAsAt,
      createdOn: wallet.createdOn,
      id: wallet.id,
      studio: json["studio"] != null ? Studio.fromJson(json["studio"]) : null,
      histories: json["histories"]
          ?.map<StudioWalletHistory>((cha) => StudioWalletHistory.fromJson(cha))
          .toList(),
      transfers: json["transfers"]
          ?.map<StudioWalletTransfer>(
              (cha) => StudioWalletTransfer.fromJson(cha))
          .toList(),
    );
  }
}

class VidStream {
  String? id;
  String studioId;
  Studio? studio;
  String streamName;
  String description;
  bool? verified;
  String logo;
  String displayScreen;
  bool? blocked;
  DateTime? createdOn;
  DateTime? updatedOn;
  String countryCode;
  bool isGlobal;
  int miniTargetAge;
  int maxTargetAge;
  double monthlySubscriptionCost;
  double monthlySubscriptionCostInEuro;
  String currency;
  List<StreamChannel>? channels;

  VidStream({
    required this.currency,
    required this.studioId,
    required this.streamName,
    required this.miniTargetAge,
    required this.maxTargetAge,
    required this.countryCode,
    required this.logo,
    required this.displayScreen,
    required this.description,
    required this.isGlobal,
    required this.monthlySubscriptionCost,
    required this.monthlySubscriptionCostInEuro,
    this.id,
    this.createdOn,
    this.updatedOn,
    this.verified,
    this.blocked,
    this.channels,
    this.studio
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (verified != null) "verified": verified,
      if (blocked != null) "blocked": blocked,
      if (createdOn != null) "createdOn": createdOn!.toString(),
      if (updatedOn != null) "updatedOn": updatedOn!.toString(),
      "streamName": streamName,
      "studioId": studioId,
      "description": description,
      "logo": logo,
      "displayScreen": displayScreen,
      "countryCode": countryCode,
      "isGlobal": isGlobal,
      "miniTargetAge": miniTargetAge,
      "maxTargetAge": maxTargetAge,
      "monthlySubscriptionCostInEuro": monthlySubscriptionCostInEuro,
      "monthlySubscriptionCost": monthlySubscriptionCost,
      "currency": currency,
    };
  }

  factory VidStream.fromJson(Map<String, dynamic> json) {
    return VidStream(
      currency: json["currency"],
      studioId: json["studioId"],
      streamName: json["streamName"],
      miniTargetAge: json["miniTargetAge"],
      maxTargetAge: json["maxTargetAge"],
      countryCode: json["countryCode"],
      logo: json["logo"],
      displayScreen: json["displayScreen"],
      description: json["description"],
      isGlobal: json["isGlobal"],
      monthlySubscriptionCost: json["monthlySubscriptionCost"],
      monthlySubscriptionCostInEuro: json["monthlySubscriptionCostInEuro"],
      blocked: json["blocked"],
      verified: json["verified"],
      id: json["id"],
      createdOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      updatedOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      channels: json["channels"]
          ?.map<StreamChannel>((cha) => StreamChannel.fromJson(cha))
          .toList(),
      studio: json["studio"] != null ? Studio.fromJson(json["studio"]) : null,
    );
  }
}

class ContentCreator {
  String? id;
  String affId;
  User? affiliate;
  List<VidChannel>? channels;
  bool? active;
  DateTime? createdOn;
  DateTime? updatedOn;
  List<ChannelVideo>? videos;
  List<ContentCreatorRequest>? requests;

  ContentCreator(
      {required this.affId,
      this.id,
      this.active,
      this.createdOn,
      this.updatedOn,
      this.affiliate,
      this.videos,
      this.channels,
      this.requests});

  Map<String, dynamic> toJson() {
    return {
      "affId": affId,
      if (id != null) "id": id,
      if (active != null) "active": active,
      if (createdOn != null) "createdOn": createdOn!.toString(),
      if (updatedOn != null) "updatedOn": updatedOn!.toString(),
    };
  }

  factory ContentCreator.fromJson(Map<String, dynamic> json) {
    return ContentCreator(
      affId: json["affId"],
      id: json["id"],
      active: json["active"],
      createdOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      updatedOn:
          json["updatedOn"] != null ? DateTime.parse(json["updatedOn"]) : null,
      affiliate:
          json["affiliate"] != null ? User.fromJson(json["affiliate"]) : null,
      videos: json["videos"]
          ?.map<ChannelVideo>((cha) => ChannelVideo.fromJson(cha))
          .toList(),
      channels: json["channels"]
          ?.map<VidChannel>((cha) => VidChannel.fromJson(cha))
          .toList(),
      requests: json["requests"]
          ?.map<ContentCreatorRequest>(
              (req) => ContentCreatorRequest.fromJson(req))
          .toList(),
    );
  }
}

class ChannelSubscriber {
  String channelId;
  String affId;
  DateTime? subscribedOn;
  VidChannel? channel;
  User? subscriber;

  ChannelSubscriber(
      {required this.affId,
      required this.channelId,
      this.subscribedOn,
      this.channel,
      this.subscriber});

  Map<String, dynamic> toJson() {
    return {
      "affId": affId,
      "channelId": channelId,
      if (subscribedOn != null) "subscribedOn": subscribedOn!.toString()
    };
  }

  factory ChannelSubscriber.fromJson(Map<String, dynamic> json) {
    return ChannelSubscriber(
      affId: json["affId"],
      channelId: json["channelId"],
      subscribedOn: json["subscribedOn"] != null
          ? DateTime.parse(json["subscribedOn"])
          : null,
      subscriber:
          json["subscriber"] != null ? User.fromJson(json["subscriber"]) : null,
      channel:
          json["channel"] != null ? VidChannel.fromJson(json["channel"]) : null,
    );
  }
}

class ChannelMembership {
  String channelId;
  String affId;
  String? channelReferral;
  String? appInstallReferral;
  DateTime? joinedOn;
  VidChannel? channel;
  User? member;

  ChannelMembership({
    required this.channelId,
    required this.affId,
    this.appInstallReferral,
    this.channelReferral,
    this.joinedOn,
    this.channel,
    this.member,
  });

  Map<String, dynamic> toJson() {
    return {
      "affId": affId,
      "channelId": channelId,
      if (joinedOn != null) "joinedOn": joinedOn!.toString(),
      if (appInstallReferral != null) "appInstallReferral": appInstallReferral,
      if (channelReferral != null) "channelReferral": channelReferral
    };
  }

  factory ChannelMembership.fromJson(Map<String, dynamic> json) {
    return ChannelMembership(
      affId: json["affId"],
      channelId: json["channelId"],
      appInstallReferral: json["appInstallReferral"],
      channelReferral: json["channelReferral"],
      joinedOn:
          json["joinedOn"] != null ? DateTime.parse(json["joinedOn"]) : null,
      member: json["member"] != null ? User.fromJson(json["member"]) : null,
      channel:
          json["channel"] != null ? VidChannel.fromJson(json["channel"]) : null,
    );
  }
}

class ChannelMembershipMatrix {
  String id;
  String channelId;
  VidChannel? channel;
  int month;
  int year;
  int totalMembersAsAtDate;
  int totalMemberCostPaid;
  double prudappCharges;
  double influencersGotFromCharges;
  double prudappProfit;
  double prudappProfitInEuro;
  String transactionCurrency;
  double channelIncome;
  double contentCreatorsGot;
  double channelProfit;
  DateTime createdOn;
  DateTime updatedOn;

  ChannelMembershipMatrix(
      {required this.id,
      required this.channelId,
      required this.updatedOn,
      required this.createdOn,
      required this.year,
      required this.month,
      required this.channelIncome,
      required this.channelProfit,
      required this.contentCreatorsGot,
      required this.influencersGotFromCharges,
      required this.prudappCharges,
      required this.prudappProfit,
      required this.prudappProfitInEuro,
      required this.totalMemberCostPaid,
      required this.totalMembersAsAtDate,
      required this.transactionCurrency,
      this.channel});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "channelId": channelId,
      "month": month,
      "year": year,
      "totalMembersAsAtDate": totalMembersAsAtDate,
      "totalMemberCostPaid": totalMemberCostPaid,
      "prudappCharges": prudappCharges,
      "influencersGotFromCharges": influencersGotFromCharges,
      "prudappProfit": prudappProfit,
      "prudappProfitInEuro": prudappProfitInEuro,
      "transactionCurrency": transactionCurrency,
      "channelIncome": channelIncome,
      "contentCreatorsGot": contentCreatorsGot,
      "channelProfit": channelProfit,
      "createdOn": createdOn.toString(),
      "updatedOn": updatedOn.toString(),
    };
  }

  factory ChannelMembershipMatrix.fromJson(Map<String, dynamic> json) {
    return ChannelMembershipMatrix(
      id: json["id"],
      channelId: json["channelId"],
      updatedOn: DateTime.parse(json["updatedOn"]),
      createdOn: DateTime.parse(json["createdOn"]),
      year: json["year"],
      month: json["month"],
      channelIncome: json["channelIncome"],
      channelProfit: json["channelProfit"],
      contentCreatorsGot: json["contentCreatorsGot"],
      influencersGotFromCharges: json["influencersGotFromCharges"],
      prudappCharges: json["prudappCharges"],
      prudappProfit: json["prudappProfit"],
      prudappProfitInEuro: json["prudappProfitInEuro"],
      totalMemberCostPaid: json["totalMemberCostPaid"],
      totalMembersAsAtDate: json["totalMembersAsAtDate"],
      transactionCurrency: json["transactionCurrency"],
      channel:
          json["channel"] != null ? VidChannel.fromJson(json["channel"]) : null,
    );
  }
}

class ChannelVideo {
  String? id;
  String channelId;
  VidChannel? channel;
  bool promoted;
  String targetAudience; //  Adult, Youth, Teenage, Kids, General
  String status; // active, suspended, blocked
  DateTime statusDate;
  String statusDescription;
  String description;
  List<String>? tags;
  String videoThumbnail;
  String title;
  String uploadedBy; // content_creator_id
  ContentCreator? creator;
  String videoUrl;
  String videoType; // movie, music, news, learn, cuisines
  bool isLive;
  DateTime? liveStartsOn;
  DateTime? liveEndedOn;
  DateTime uploadedAt;
  DateTime? updatedAt;
  DateTime? scheduledFor;
  String timezone;
  int memberViews;
  int nonMemberViews;
  double costPerNonMemberView;
  int likes;
  int dislikes;
  int impressions;
  int watchMinutes;
  int downloads;
  bool iDeclared;
  int votes;
  int voters;
  Map<String, dynamic> videoDuration;
  List<ChannelVideoViewMatrix>? viewMatrix;
  List<StudioWalletHistory>? paymentHistories;
  List<VideoClaimReport>? claims;
  List<VideoSnippet>? snippets;
  List<VideoWatch>? watches;
  VideoThriller? thriller;
  String? movieDetailId;
  String? musicDetailId;
  VideoMovieDetail? movieDetail;
  VideoMusicDetail? musicDetail;
  List<VideoComment>? comments;
  PromoteVideo? sponsored;

  ChannelVideo({
    required this.channelId,
    required this.targetAudience,
    required this.status,
    required this.statusDate,
    required this.description,
    required this.videoThumbnail,
    required this.title,
    required this.uploadedBy,
    required this.videoUrl,
    required this.videoType,
    required this.uploadedAt,
    required this.timezone,
    required this.costPerNonMemberView,
    required this.iDeclared,
    required this.videoDuration,
    this.promoted = false,
    this.statusDescription = "just created",
    this.dislikes = 0,
    this.downloads = 0,
    this.watchMinutes = 0,
    this.impressions = 0,
    this.likes = 0,
    this.nonMemberViews = 0,
    this.memberViews = 0,
    this.votes = 0,
    this.voters = 0,
    this.isLive = false,
    this.tags,
    this.channel,
    this.claims,
    this.creator,
    this.id,
    this.paymentHistories,
    this.updatedAt,
    this.liveEndedOn,
    this.liveStartsOn,
    this.movieDetailId,
    this.musicDetailId,
    this.movieDetail,
    this.musicDetail,
    this.scheduledFor,
    this.viewMatrix,
    this.watches,
    this.thriller,
    this.snippets,
    this.comments,
    this.sponsored,
  });

  double getRating() {
    if (voters > 0 && votes > 0) return votes / voters;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (tags != null) "tags": tags,
      if (scheduledFor != null) "scheduledFor": scheduledFor!.toString(),
      if (updatedAt != null) "updatedAt": updatedAt!.toString(),
      if (liveStartsOn != null) "liveStartsOn": liveStartsOn!.toString(),
      if (liveEndedOn != null) "liveEndedOn": liveEndedOn!.toString(),
      if(snippets != null) "snippets": snippets!.map((snip) => snip.toJson()).toList(),
      if(thriller != null) "thriller": thriller!.toJson(),
      if(sponsored != null) "sponsored":	sponsored!.toJson(),
      "targetAudience": targetAudience,
      "channelId": channelId,
      "promoted": promoted,
      "status": status,
      "statusDate": statusDate.toString(),
      "statusDescription": statusDescription,
      "description": description,
      "videoThumbnail": videoThumbnail,
      "title": title,
      "uploadedBy": uploadedBy,
      "videoUrl": videoUrl,
      "videoType": videoType,
      "isLive": isLive,
      "uploadedAt": uploadedAt.toString(),
      "timezone": timezone,
      "memberViews": memberViews,
      "nonMemberViews": nonMemberViews,
      "costPerNonMemberView": costPerNonMemberView,
      "likes": likes,
      "dislikes": dislikes,
      "impressions": impressions,
      "voters": voters,
      "votes": votes,
      "watchMinutes": watchMinutes,
      "downloads": downloads,
      "iDeclared": iDeclared,
      "videoDuration": videoDuration,
      "movieDetailId": movieDetailId,
      "musicDetailId": musicDetailId,
    };
  }

  factory ChannelVideo.fromJson(Map<String, dynamic> json) {
    return ChannelVideo(
      channelId: json["channelId"],
      targetAudience: json["targetAudience"],
      status: json["status"],
      statusDate: DateTime.parse(json["statusDate"]),
      description: json["description"],
      videoThumbnail: json["videoThumbnail"],
      title: json["title"],
      uploadedBy: json["uploadedBy"],
      videoUrl: json["videoUrl"],
      promoted: json["promoted"],
      videoType: json["videoType"],
      uploadedAt: DateTime.parse(json["uploadedAt"]),
      timezone: json["timezone"],
      costPerNonMemberView: json["costPerNonMemberView"],
      iDeclared: json["iDeclared"],
      videoDuration: json["videoDuration"],
      movieDetailId: json["movieDetailId"],
      musicDetailId: json["musicDetailId"],
      votes: json["votes"],
      voters: json["voters"],
      id: json["id"],
      channel:
          json["channel"] != null ? VidChannel.fromJson(json["channel"]) : null,
      tags: json["tags"],
      creator: json["creator"] != null
          ? ContentCreator.fromJson(json["creator"])
          : null,
      liveStartsOn: json["liveStartsOn"] != null
          ? DateTime.parse(json["liveStartsOn"])
          : null,
      liveEndedOn: json["liveEndedOn"] != null
          ? DateTime.parse(json["liveEndedOn"])
          : null,
      updatedAt:
          json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
      scheduledFor: json["scheduledFor"] != null
          ? DateTime.parse(json["scheduledFor"])
          : null,
      viewMatrix: json["viewMatrix"]
          ?.map((itm) => ChannelVideoViewMatrix.fromJson(itm))
          .toList(),
      paymentHistories: json["paymentHistories"]
          ?.map((itm) => StudioWalletHistory.fromJson(itm))
          .toList(),
      claims:
          json["claims"]?.map((itm) => VideoClaimReport.fromJson(itm)).toList(),
      snippets:
          json["snippets"]?.map((itm) => VideoSnippet.fromJson(itm)).toList(),
      watches: json["watches"]?.map((itm) => VideoWatch.fromJson(itm)).toList(),
      thriller: json["thriller"] != null
          ? VideoThriller.fromJson(json["thriller"])
          : null,
      movieDetail: json["movieDetail"] != null
          ? VideoMovieDetail.fromJson(json["movieDetail"])
          : null,
      musicDetail: json["musicDetail"] != null
          ? VideoMusicDetail.fromJson(json["musicDetail"])
          : null,
      memberViews: json["memberViews"] as int,
      nonMemberViews: json["nonMemberViews"],
      likes: json["likes"],
      dislikes: json["dislikes"],
      impressions: json["impressions"],
      watchMinutes: json["watchMinutes"],
      downloads: json["downloads"],
      isLive: json["isLive"],
      sponsored: json["sponsored"] != null
          ? PromoteVideo.fromJson(json["sponsored"])
          : null,
      statusDescription: json["statusDescription"],
      comments:
          json["comments"]?.map((itm) => VideoComment.fromJson(itm)).toList(),
    );
  }
}

class StudioWalletHistory {
  String id;
  bool isCredit;
  String walletId;
  StudioWallet? wallet;
  String? transId;
  double amount;
  String videoId;
  ChannelVideo? video;
  String channelId;
  VidChannel? channel;
  String viaChannel;
  DateTime dated;
  String currency;
  String selectedCurrency;
  double amtInSelectedCurrency;
  int month;
  int year;

  StudioWalletHistory({
    required this.id,
    required this.currency,
    required this.walletId,
    required this.amount,
    required this.selectedCurrency,
    required this.amtInSelectedCurrency,
    required this.viaChannel,
    required this.videoId,
    required this.isCredit,
    required this.channelId,
    required this.dated,
    required this.month,
    required this.year,
    this.transId,
    this.wallet,
    this.channel,
    this.video
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "month": month,
      "year": year,
      "amtInSelectedCurrency": amtInSelectedCurrency,
      "selectedCurrency": selectedCurrency,
      "currency": currency,
      "dated": dated.toString(),
      "viaChannel": viaChannel,
      "channelId": channelId,
      "videoId": videoId,
      "amount": amount,
      "walletId": walletId,
      "isCredit": isCredit,
      if (transId != null) "transId": transId
    };
  }

  factory StudioWalletHistory.fromJson(Map<String, dynamic> json) {
    return StudioWalletHistory(
      id: json["id"],
      currency: json["currency"],
      walletId: json["walletId"],
      amount: json["amount"],
      selectedCurrency: json["selectedCurrency"],
      amtInSelectedCurrency: json["amtInSelectedCurrency"],
      viaChannel: json["viaChannel"],
      videoId: json["videoId"],
      isCredit: json["isCredit"],
      channelId: json["channelId"],
      dated: DateTime.parse(json["dated"]),
      month: json["month"],
      year: json["year"],
      transId: json["transId"],
      wallet:
          json["wallet"] != null ? StudioWallet.fromJson(json["wallet"]) : null,
      video:
          json["video"] != null ? ChannelVideo.fromJson(json["video"]) : null,
      channel:
          json["channel"] != null ? VidChannel.fromJson(json["channel"]) : null,
    );
  }
}

class StudioWalletTransfer {
  String? id;
  String walletId;
  StudioWallet? wallet;
  String affWalletId;
  InfluencerWallet? affWallet;
  double amountInEuro;
  double amountInSelectedCurrency;
  String selectedCurrency;
  DateTime? createdOn;

  StudioWalletTransfer(
      {required this.selectedCurrency,
      required this.walletId,
      required this.affWalletId,
      required this.amountInEuro,
      required this.amountInSelectedCurrency,
      this.wallet,
      this.id,
      this.createdOn,
      this.affWallet});

  Map<String, dynamic> toJson() {
    return {
      "walletId": walletId,
      "affWalletId": affWalletId,
      "amountInEuro": amountInEuro,
      "amountInSelectedCurrency": amountInSelectedCurrency,
      "selectedCurrency": selectedCurrency,
      if (id != null) "id": id,
      if (createdOn != null) "createdOn": createdOn!.toString(),
    };
  }

  factory StudioWalletTransfer.fromJson(Map<String, dynamic> json) {
    return StudioWalletTransfer(
      selectedCurrency: json["selectedCurrency"],
      walletId: json["walletId"],
      affWalletId: json["affWalletId"],
      amountInEuro: json["amountInEuro"],
      amountInSelectedCurrency: json["amountInSelectedCurrency"],
      id: json["id"],
      createdOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      wallet:
          json["wallet"] != null ? StudioWallet.fromJson(json["wallet"]) : null,
      affWallet: json["affWallet"] != null
          ? InfluencerWallet.fromJson(json["affWallet"])
          : null,
    );
  }
}

class StreamChannel {
  String? id;
  String streamId;
  VidStream? stream;
  String channelId;
  VidChannel? channel;
  bool active;
  String categoryId;

  StreamChannel(
      {required this.channelId,
      required this.streamId,
      required this.categoryId,
      this.active = true,
      this.id,
      this.channel,
      this.stream});

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      "channelId": channelId,
      "categoryId": categoryId,
      "streamId": streamId,
      "active": active
    };
  }

  factory StreamChannel.fromJson(Map<String, dynamic> json) {
    return StreamChannel(
      id: json["id"],
      channelId: json["channelId"],
      streamId: json["streamId"],
      categoryId: json["categoryId"],
      active: json["active"],
      channel:
          json["channel"] != null ? VidChannel.fromJson(json["channel"]) : null,
      stream:
          json["stream"] != null ? VidStream.fromJson(json["stream"]) : null,
    );
  }
}

class ChannelVideoViewMatrix {
  String id;
  String videoId;
  ChannelVideo? video;
  int day;
  int month;
  int year;
  int nonMemberViews;
  double costPerView;
  double totalViewCosts;
  double prudappCharges; // charged to totalViewCosts
  double influencersGotFromCharges;
  double prudappProfit;
  double prudappProfitInEuro;
  double totalStudioIncomeAfterCharges;
  double contentCreatorGotFromStudioIncome;
  double currency;
  bool paid;
  DateTime? paidOn;
  DateTime createdAt;
  DateTime updatedAt;

  ChannelVideoViewMatrix(
      {required this.id,
      required this.videoId,
      required this.day,
      required this.month,
      required this.year,
      required this.nonMemberViews,
      required this.contentCreatorGotFromStudioIncome,
      required this.currency,
      required this.createdAt,
      required this.updatedAt,
      required this.prudappProfitInEuro,
      required this.prudappProfit,
      required this.prudappCharges,
      required this.influencersGotFromCharges,
      required this.totalStudioIncomeAfterCharges,
      required this.totalViewCosts,
      required this.paid,
      required this.costPerView,
      this.video,
      this.paidOn});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "videoId": videoId,
      "day": day,
      "month": month,
      "year": year,
      "nonMemberViews": nonMemberViews,
      "costPerView": costPerView,
      "totalViewCosts": totalViewCosts,
      "prudappCharges": prudappCharges,
      "influencersGotFromCharges": influencersGotFromCharges,
      "prudappProfit": prudappProfit,
      "prudappProfitInEuro": prudappProfitInEuro,
      "totalStudioIncomeAfterCharges": totalStudioIncomeAfterCharges,
      "contentCreatorGotFromStudioIncome": contentCreatorGotFromStudioIncome,
      "currency": currency,
      "paid": paid,
      if (paidOn != null) "paidOn": paidOn.toString(),
      "createdAt": createdAt.toString(),
      "updatedAt": updatedAt.toString(),
    };
  }

  factory ChannelVideoViewMatrix.fromJson(Map<String, dynamic> json) {
    return ChannelVideoViewMatrix(
      id: json["id"],
      videoId: json["videoId"],
      day: json["day"],
      month: json["month"],
      year: json["year"],
      nonMemberViews: json["nonMemberViews"],
      contentCreatorGotFromStudioIncome:
          json["contentCreatorGotFromStudioIncome"],
      currency: json["currency"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      prudappProfitInEuro: json["prudappProfitInEuro"],
      prudappProfit: json["prudappProfit"],
      prudappCharges: json["prudappCharges"],
      influencersGotFromCharges: json["influencersGotFromCharges"],
      totalStudioIncomeAfterCharges: json["totalStudioIncomeAfterCharges"],
      totalViewCosts: json["totalViewCosts"],
      paid: json["paid"],
      costPerView: json["costPerView"],
      paidOn: json["paidOn"] != null ? DateTime.parse(json["paidOn"]) : null,
      video:
          json["video"] != null ? ChannelVideo.fromJson(json["video"]) : null,
    );
  }
}

class VideoClaimReport {
  String? id;
  String videoId;
  ChannelVideo? video;
  String reportedBy;
  User? affiliate;
  String claim;
  String description;
  bool treated;
  String? findingsMade;
  String? actionTaken;
  DateTime? createdOn;
  DateTime? updatedOn;

  VideoClaimReport(
      {required this.videoId,
      required this.description,
      required this.reportedBy,
      required this.claim,
      this.treated = false,
      this.id,
      this.actionTaken,
      this.findingsMade,
      this.video,
      this.createdOn,
      this.updatedOn,
      this.affiliate});

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (createdOn != null) "createdOn": createdOn!.toString(),
      if (updatedOn != null) "updatedOn": updatedOn!.toString(),
      if (actionTaken != null) "actionTaken": actionTaken,
      if (findingsMade != null) "findingsMade": findingsMade,
      "treated": treated,
      "description": description,
      "claim": claim,
      "reportedBy": reportedBy,
      "videoId": videoId,
    };
  }

  factory VideoClaimReport.fromJson(Map<String, dynamic> json) {
    return VideoClaimReport(
      videoId: json["videoId"],
      description: json["description"],
      reportedBy: json["reportedBy"],
      claim: json["claim"],
      id: json["id"],
      treated: json["treated"],
      findingsMade: json["findingsMade"],
      actionTaken: json["actionTaken"],
      createdOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      updatedOn:
          json["updatedOn"] != null ? DateTime.parse(json["updatedOn"]) : null,
      video:
          json["video"] != null ? ChannelVideo.fromJson(json["video"]) : null,
      affiliate:
          json["affiliate"] != null ? User.fromJson(json["affiliate"]) : null,
    );
  }
}

class VideoSnippet {
  String? id;
  String videoId;
  ChannelVideo? video;
  String startAt;
  String endAt;
  String title;
  String description;

  VideoSnippet({
    required this.videoId,
    required this.description,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.video,
    this.id
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      "videoId": videoId,
      "startAt": startAt,
      "endAt": endAt,
      "title": title,
      "description": description,
    };
  }

  factory VideoSnippet.fromJson(Map<String, dynamic> json) {
    return VideoSnippet(
      videoId: json["videoId"],
      description: json["description"],
      title: json["title"],
      startAt: json["startAt"],
      endAt: json["endAt"],
      id: json["id"],
      video:
          json["video"] != null ? ChannelVideo.fromJson(json["video"]) : null,
    );
  }
}

class VideoWatch {
  String? id;
  String videoId;
  ChannelVideo? video;
  String affId;
  User? affiliate;
  DateTime lastWatch;
  DateTime startedWatchingOn;
  DateTime? finishedOn;
  DateTime lastUpdate;
  int lastStopHours;
  int lastStopMinutes;
  int lastStopSeconds;

  VideoWatch(
      {required this.videoId,
      required this.affId,
      required this.lastStopHours,
      required this.lastStopMinutes,
      required this.lastStopSeconds,
      required this.lastUpdate,
      required this.lastWatch,
      required this.startedWatchingOn,
      this.finishedOn,
      this.id,
      this.video,
      this.affiliate});

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (finishedOn != null) "finishedOn": finishedOn!.toString(),
      "lastUpdate": lastUpdate.toString(),
      "startedWatchingOn": startedWatchingOn.toString(),
      "lastWatch": lastWatch.toString(),
      "videoId": videoId,
      "affId": affId,
      "lastStopHours": lastStopHours,
      "lastStopMinutes": lastStopMinutes,
      "lastStopSeconds": lastStopSeconds,
    };
  }

  factory VideoWatch.fromJson(Map<String, dynamic> json) {
    return VideoWatch(
      videoId: json["videoId"],
      affId: json["affId"],
      lastStopHours: json["lastStopHours"],
      lastStopMinutes: json["lastStopMinutes"],
      lastStopSeconds: json["lastStopSeconds"],
      lastUpdate: DateTime.parse(json["lastUpdate"]),
      lastWatch: DateTime.parse(json["lastWatch"]),
      startedWatchingOn: DateTime.parse(json["startedWatchingOn"]),
      finishedOn: json["finishedOn"] != null
          ? DateTime.parse(json["finishedOn"])
          : null,
      id: json["id"],
      video:
          json["video"] != null ? ChannelVideo.fromJson(json["video"]) : null,
      affiliate:
          json["affiliate"] != null ? User.fromJson(json["affiliate"]) : null,
    );
  }
}

class VideoThriller {
  String? id;
  String videoId;
  ChannelVideo? video;
  int? durationInMinutes;
  int? durationInSeconds;
  String videoUrl;
  List<String>? tags;
  int likes;
  int dislikes;
  int impressions;
  int shared;
  List<VideoThrillerComment>? comments;

  VideoThriller({
    required this.videoId,
    required this.videoUrl,
    this.likes = 0,
    this.impressions = 0,
    this.dislikes = 0,
    this.shared = 0,
    this.durationInMinutes,
    this.id,
    this.video,
    this.tags,
    this.comments,
    this.durationInSeconds
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (durationInSeconds != null) "durationInSeconds": durationInSeconds,
      if (durationInMinutes != null) "durationInMinutes": durationInMinutes,
      if (tags != null) "tags": tags,
      "likes": likes,
      "dislikes": dislikes,
      "impressions": impressions,
      "shared": shared,
      "videoId": videoId,
      "videoUrl": videoUrl,
    };
  }

  factory VideoThriller.fromJson(Map<String, dynamic> json) {
    return VideoThriller(
      videoId: json["videoId"],
      videoUrl: json["videoUrl"],
      shared: json["shared"],
      likes: json["likes"],
      dislikes: json["dislikes"],
      impressions: json["impressions"],
      tags: json["tags"],
      id: json["id"],
      durationInMinutes: json["durationInMinutes"],
      durationInSeconds: json["durationInSeconds"],
      video:
          json["video"] != null ? ChannelVideo.fromJson(json["video"]) : null,
      comments: json["comments"]
          ?.map<VideoThrillerComment>(
              (cha) => VideoThrillerComment.fromJson(cha))
          .toList(),
    );
  }
}

class VideoThrillerComment {
  String? id;
  String thrillerId;
  VideoThriller? thriller;
  String comment;
  bool isInnerComment;
  String? innerCommentId;
  String madeBy;
  User? affiliate;
  int likes;
  int dislikes;
  DateTime? createdOn;
  DateTime? updatedOn;

  VideoThrillerComment({
    required this.thrillerId,
    required this.madeBy,
    required this.comment,
    this.likes = 0,
    this.dislikes = 0,
    this.isInnerComment = false,
    this.id,
    this.updatedOn,
    this.createdOn,
    this.affiliate,
    this.thriller,
    this.innerCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (innerCommentId != null) "innerCommentId": innerCommentId,
      if (createdOn != null) "createdOn": createdOn!.toString(),
      if (updatedOn != null) "updatedOn": updatedOn!.toString(),
      "thrillerId": thrillerId,
      "madeBy": madeBy,
      "likes": likes,
      "dislikes": dislikes,
      "comment": comment,
      "isInnerComment": isInnerComment,
    };
  }

  factory VideoThrillerComment.fromJson(Map<String, dynamic> json) {
    return VideoThrillerComment(
      thrillerId: json["thrillerId"],
      madeBy: json["madeBy"],
      comment: json["comment"],
      id: json["id"],
      innerCommentId: json["innerCommentId"],
      isInnerComment: json["isInnerComment"],
      likes: json["likes"],
      dislikes: json["dislikes"],
      createdOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      updatedOn:
          json["updatedOn"] != null ? DateTime.parse(json["updatedOn"]) : null,
      thriller: json["thriller"] != null
          ? VideoThriller.fromJson(json["thriller"])
          : null,
      affiliate:
          json["affiliate"] != null ? User.fromJson(json["affiliate"]) : null,
    );
  }
}

class VideoComment {
  String? id;
  String videoId;
  ChannelVideo? video;
  String comment;
  bool isInnerComment;
  String? innerCommentId;
  String madeBy;
  User? affiliate;
  int likes;
  int dislikes;
  DateTime? createdOn;
  DateTime? updatedOn;

  VideoComment({
    required this.videoId,
    required this.madeBy,
    required this.comment,
    this.likes = 0,
    this.dislikes = 0,
    this.isInnerComment = false,
    this.id,
    this.updatedOn,
    this.createdOn,
    this.affiliate,
    this.video,
    this.innerCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (innerCommentId != null) "innerCommentId": innerCommentId,
      if (createdOn != null) "createdOn": createdOn!.toString(),
      if (updatedOn != null) "updatedOn": updatedOn!.toString(),
      "videoId": videoId,
      "madeBy": madeBy,
      "likes": likes,
      "dislikes": dislikes,
      "comment": comment,
      "isInnerComment": isInnerComment,
    };
  }

  factory VideoComment.fromJson(Map<String, dynamic> json) {
    return VideoComment(
      videoId: json["videoId"],
      madeBy: json["madeBy"],
      comment: json["comment"],
      id: json["id"],
      innerCommentId: json["innerCommentId"],
      isInnerComment: json["isInnerComment"],
      likes: json["likes"],
      dislikes: json["dislikes"],
      createdOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      updatedOn:
          json["updatedOn"] != null ? DateTime.parse(json["updatedOn"]) : null,
      video: json["video"] != null
          ? ChannelVideo.fromJson(json["thriller"])
          : null,
      affiliate:
          json["affiliate"] != null ? User.fromJson(json["affiliate"]) : null,
    );
  }
}

class VideoMovieDetail {
  String? id;
  ChannelVideo? video;
  String executiveProducerName;
  int productionYear;
  int productionMonth;
  String parentalGuard;
  String movieTitle;
  String movieSubtitle;
  bool isSeries;
  int? season;
  int? episode;
  List<String> productionCompanyNames;
  List<String>? tags;
  String? morePlot;
  int totalCast;
  String movieType;
  String movieSubType;
  double totalCostOfProduction;
  List<VideoMovieCast>? casts;

  VideoMovieDetail({
    required this.parentalGuard,
    required this.executiveProducerName,
    required this.productionCompanyNames,
    required this.totalCast,
    required this.totalCostOfProduction,
    required this.movieSubtitle,
    required this.movieTitle,
    required this.productionMonth,
    required this.productionYear,
    required this.movieType,
    required this.movieSubType,
    this.isSeries = false,
    this.tags,
    this.id,
    this.episode,
    this.morePlot,
    this.season,
    this.casts,
    this.video,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if(casts != null && casts!.isNotEmpty) "casts": casts!.map((cast) => cast.toJson()).toList(),
      if (season != null) "season": season,
      if(video != null) "video": video!.toJson(),
      if (episode != null) "episode": episode,
      if (tags != null) "tags": tags,
      if (morePlot != null) "morePlot": morePlot,
      "executiveProducerName": executiveProducerName,
      "productionYear": productionYear,
      "productionMonth": productionMonth,
      "parentalGuard": parentalGuard,
      "movieTitle": movieTitle,
      "movieSubtitle": movieSubtitle,
      "movieSubType": movieSubType,
      "movieType": movieType,
      "isSeries": isSeries,
      "productionCompanyNames": productionCompanyNames,
      "totalCast": totalCast,
      "totalCostOfProduction": totalCostOfProduction,
    };
  }

  factory VideoMovieDetail.fromJson(Map<String, dynamic> json) {
    return VideoMovieDetail(
      parentalGuard: json["parentalGuard"],
      executiveProducerName: json["executiveProducerName"],
      productionCompanyNames: json["productionCompanyNames"],
      totalCast: json["totalCast"],
      totalCostOfProduction: json["totalCostOfProduction"],
      movieSubtitle: json["movieSubtitle"],
      movieTitle: json["movieTitle"],
      productionMonth: json["productionMonth"],
      productionYear: json["productionYear"],
      tags: json["tags"],
      morePlot: json["morePlot"],
      movieSubType: json["movieSubType"],
      movieType: json["movieType"],
      episode: json["episode"],
      season: json["season"],
      isSeries: json["isSeries"],
      id: json["id"],
      video: json["video"] != null ? ChannelVideo.fromJson(json["video"]) : null,
      casts: json["casts"]?.map<VideoMovieCast>((cha) => VideoMovieCast.fromJson(cha)).toList(),
    );
  }
}

class VideoMusicDetail {
  String? id;
  ChannelVideo? video;
  String executiveProducerName;
  int? productionYear;
  int? productionMonth;
  String albumTitle;
  String parentalGuard; // Adult All 16+ 18+ 13+ 8+ Infants
  String trackTitle;
  String musicLabel;
  List<String>? tags;
  double? totalCostOfProduction;

  VideoMusicDetail({
    required this.parentalGuard,
    required this.albumTitle,
    required this.musicLabel,
    required this.executiveProducerName,
    required this.trackTitle,
    this.productionYear,
    this.productionMonth,
    this.tags,
    this.id,
    this.totalCostOfProduction,
    this.video
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (productionYear != null) "productionYear": productionYear,
      if (productionMonth != null) "productionMonth": productionMonth,
      if (tags != null) "tags": tags,
      if (totalCostOfProduction != null)
        "totalCostOfProduction": totalCostOfProduction,
      "executiveProducerName": executiveProducerName,
      "albumTitle": albumTitle,
      "parentalGuard": parentalGuard,
      "trackTitle": trackTitle,
      "musicLabel": musicLabel,
    };
  }

  factory VideoMusicDetail.fromJson(Map<String, dynamic> json) {
    return VideoMusicDetail(
      parentalGuard: json["parentalGuard"],
      albumTitle: json["albumTitle"],
      musicLabel: json["musicLabel"],
      executiveProducerName: json["executiveProducerName"],
      trackTitle: json["trackTitle"],
      id: json["id"],
      tags: json["tags"],
      productionMonth: json["productionMonth"],
      productionYear: json["productionYear"],
      totalCostOfProduction: json["totalCostOfProduction"],
      video:
          json["video"] != null ? ChannelVideo.fromJson(json["video"]) : null,
    );
  }
}

class VideoMovieCast {
  String? id;
  String detailId;
  VideoMovieDetail? movieDetail;
  String fullname;
  String roleName;
  String? castPhotoUrl;
  String? rolePlot;
  int votes;
  int voters;

  VideoMovieCast({
    required this.detailId,
    required this.fullname,
    required this.roleName,
    this.voters = 0,
    this.votes = 0,
    this.id,
    this.castPhotoUrl,
    this.rolePlot,
    this.movieDetail
  });

  double getRating() {
    if (voters > 0 && votes > 0) return votes / voters;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (castPhotoUrl != null) "castPhotoUrl": castPhotoUrl,
      if (rolePlot != null) "rolePlot": rolePlot,
      "detailId": detailId,
      "fullname": fullname,
      "roleName": roleName,
      "votes": votes,
      "voters": voters,
    };
  }

  factory VideoMovieCast.fromJson(Map<String, dynamic> json) {
    return VideoMovieCast(
      detailId: json["detailId"],
      fullname: json["fullname"],
      roleName: json["roleName"],
      votes: json["votes"],
      voters: json["voters"],
      rolePlot: json["rolePlot"],
      castPhotoUrl: json["castPhotoUrl"],
      id: json["id"],
      movieDetail: json["movieDetail"] != null
          ? VideoMovieDetail.fromJson(json["movieDetail"])
          : null,
    );
  }
}

class ContentCreatorRequest {
  String? id;
  String creatorId;
  ContentCreator? creator;
  String channelId;
  VidChannel? channel;
  String status;
  String requestMessage;
  DateTime? requestedOn;
  DateTime? updatedOn;
  String? meetingLink;

  ContentCreatorRequest({
    required this.channelId,
    required this.creatorId,
    required this.requestMessage,
    this.id,
    this.status = "PENDING",
    this.meetingLink,
    this.requestedOn,
    this.updatedOn,
    this.channel,
    this.creator,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      "status": status,
      if (meetingLink != null) "meetingLink": meetingLink,
      if (requestedOn != null) "requestedOn": requestedOn.toString(),
      if (updatedOn != null) "updatedOn": updatedOn.toString(),
      "channelId": channelId,
      "creatorId": creatorId,
      "requestMessage": requestMessage,
    };
  }

  factory ContentCreatorRequest.fromJson(Map<String, dynamic> json) {
    return ContentCreatorRequest(
      channelId: json["channelId"],
      creatorId: json["creatorId"],
      requestMessage: json["requestMessage"],
      updatedOn:
          json["updatedOn"] != null ? DateTime.parse(json["updatedOn"]) : null,
      requestedOn: json["requestedOn"] != null
          ? DateTime.parse(json["requestedOn"])
          : null,
      meetingLink: json["meetingLink"],
      id: json["id"],
      status: json["status"],
      creator: json["creator"] != null
          ? ContentCreator.fromJson(json["creator"])
          : null,
      channel:
          json["channel"] != null ? VidChannel.fromJson(json["channel"]) : null,
    );
  }
}

class CreatorDetail {
  ContentCreator creator;
  User detail;

  CreatorDetail({required this.creator, required this.detail});

  Map<String, dynamic> toJson() {
    return {
      "creator": creator.toJson(),
      "detail": detail.toJson(),
    };
  }

  factory CreatorDetail.fromJson(Map<String, dynamic> json) {
    return CreatorDetail(
        creator: ContentCreator.fromJson(json["creator"]),
        detail: User.fromJson(json["detail"]));
  }
}

class CachedChannelCreator {
  VidChannel channel;
  List<CreatorDetail> creators;

  CachedChannelCreator({
    required this.channel,
    required this.creators,
  });

  Map<String, dynamic> toJson() {
    return {
      "channel": channel.toJson(),
      "creators": creators.map((ctr) => ctr.toJson()).toList(),
    };
  }

  factory CachedChannelCreator.fromJson(Map<String, dynamic> json) {
    return CachedChannelCreator(
      channel: VidChannel.fromJson(json["channel"]),
      creators: json["creators"]
          .map<CreatorDetail>((cha) => CreatorDetail.fromJson(cha))
          .toList(),
    );
  }
}

class PromoteChannel {
  String? id;
  String channelId;
  VidChannel? channel;
  String mediaType;
  String mediaUrl;
  DateTime? createdOn;
  DateTime? updatedOn;
  List<PromoteChannelMetric>? metrics;

  PromoteChannel({
    required this.channelId,
    required this.mediaType,
    required this.mediaUrl,
    this.id,
    this.channel,
    this.createdOn,
    this.updatedOn,
    this.metrics,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (createdOn != null) "createdOn": createdOn!.toString(),
      if (updatedOn != null) "updatedOn": updatedOn!.toString(),
      "channelId": channelId,
      "mediaType": mediaType,
      "mediaUrl": mediaUrl,
    };
  }

  factory PromoteChannel.fromJson(Map<String, dynamic> json) {
    return PromoteChannel(
      channelId: json["channelId"],
      mediaType: json["mediaType"],
      mediaUrl: json["mediaUrl"],
      id: json["id"],
      createdOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      updatedOn:
          json["updatedOn"] != null ? DateTime.parse(json["updatedOn"]) : null,
      channel:
          json["channel"] != null ? VidChannel.fromJson(json["channel"]) : null,
      metrics: json["metrics"]
          .map<PromoteChannelMetric>(
              (pcm) => PromoteChannelMetric.fromJson(pcm))
          .toList(),
    );
  }
}

class PromoteVideo {
  String? id;
  String videoId;
  ChannelVideo? video;
  DateTime? createdOn;
  DateTime? updatedOn;
  List<PromoteVideoMetric>? metrics;

  PromoteVideo({
    required this.videoId,
    this.id,
    this.video,
    this.createdOn,
    this.updatedOn,
    this.metrics,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (createdOn != null) "createdOn": createdOn!.toString(),
      if (updatedOn != null) "updatedOn": updatedOn!.toString(),
      "videoId": videoId,
    };
  }

  factory PromoteVideo.fromJson(Map<String, dynamic> json) {
    return PromoteVideo(
      videoId: json["videoId"],
      id: json["id"],
      createdOn:
          json["createdOn"] != null ? DateTime.parse(json["createdOn"]) : null,
      updatedOn:
          json["updatedOn"] != null ? DateTime.parse(json["updatedOn"]) : null,
      video:
          json["video"] != null ? ChannelVideo.fromJson(json["video"]) : null,
      metrics: json["metrics"]
          .map<PromoteVideoMetric>((pvm) => PromoteVideoMetric.fromJson(pvm))
          .toList(),
    );
  }
}

class PromoteVideoMetric {
  String id;
  String proId;
  PromoteVideo? pro;
  int month;
  int year;
  int impressions;
  int clicks;
  DateTime createdOn;
  DateTime updatedOn;

  PromoteVideoMetric({
    required this.id,
    required this.proId,
    required this.clicks,
    required this.month,
    required this.year,
    required this.impressions,
    required this.createdOn,
    required this.updatedOn,
    this.pro,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "proId": proId,
      "clicks": clicks,
      "month": month,
      "year": year,
      "impressions": impressions,
      "createdOn": createdOn.toString(),
      "updatedOn": updatedOn
    };
  }

  factory PromoteVideoMetric.fromJson(Map<String, dynamic> json) {
    return PromoteVideoMetric(
      id: json["id"],
      proId: json["proId"],
      clicks: json["clicks"],
      month: json["month"],
      year: json["year"],
      impressions: json["impressions"],
      createdOn: DateTime.parse(json["createdOn"]),
      updatedOn: DateTime.parse(json["updatedOn"]),
    );
  }
}

class PromoteChannelMetric {
  String id;
  String proId;
  PromoteChannel? pro;
  int month;
  int year;
  int impressions;
  int clicks;
  DateTime createdOn;
  DateTime updatedOn;

  PromoteChannelMetric({
    required this.id,
    required this.proId,
    required this.clicks,
    required this.month,
    required this.year,
    required this.impressions,
    required this.createdOn,
    required this.updatedOn,
    this.pro,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "proId": proId,
      "clicks": clicks,
      "month": month,
      "year": year,
      "impressions": impressions,
      "createdOn": createdOn.toString(),
      "updatedOn": updatedOn
    };
  }

  factory PromoteChannelMetric.fromJson(Map<String, dynamic> json) {
    return PromoteChannelMetric(
      id: json["id"],
      proId: json["proId"],
      clicks: json["clicks"],
      month: json["month"],
      year: json["year"],
      impressions: json["impressions"],
      createdOn: DateTime.parse(json["createdOn"]),
      updatedOn: DateTime.parse(json["updatedOn"]),
      pro: json["pro"] != null ? PromoteChannel.fromJson(json["pro"]) : null,
    );
  }
}

class RatedChannel {
  String id;
  int vote;
  int monthRated;
  int yearRated;

  RatedChannel({
    required this.id,
    required this.vote,
    required this.monthRated,
    required this.yearRated,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "vote": vote,
      "monthRated": monthRated,
      "yearRated": yearRated,
    };
  }

  Map<String, dynamic> toRateSchema(int current) {
    return {
      "hasRated": true,
      "lastRate": vote,
      "currentRate": current,
    };
  }

  void updateRating(int current) {
    vote = current;
    monthRated = DateTime.now().month;
    yearRated = DateTime.now().year;
  }

  factory RatedChannel.fromJson(Map<String, dynamic> json) {
    return RatedChannel(
      id: json["id"],
      vote: json["vote"],
      monthRated: json["monthRated"],
      yearRated: json["yearRated"],
    );
  }
}

class RatingSearchResult {
  int index;
  RatedChannel? ratedChannel;
  bool canVote;

  RatingSearchResult({
    required this.index,
    this.ratedChannel,
    this.canVote = false,
  });
}

class ChannelRefferal {
  String channelId;
  String referrerId;

  ChannelRefferal({
    required this.channelId,
    required this.referrerId,
  });

  Map<String, dynamic> toJson() {
    return {
      "channelId": channelId,
      "referrerId": referrerId,
    };
  }

  factory ChannelRefferal.fromJson(Map<String, dynamic> json) {
    return ChannelRefferal(
      channelId: json["channelId"],
      referrerId: json["referrerId"],
    );
  }
}

class ChannelStreamServiceFigure{
  int total;
  int active;

  ChannelStreamServiceFigure({
    required this.total,
    required this.active,
  });

  Map<String, dynamic> toJson() {
    return {
      "total": total,
      "active": active,
    };
  }

  factory ChannelStreamServiceFigure.fromJson(Map<String, dynamic> json) {
    return ChannelStreamServiceFigure(
      total: json["total"],
      active: json["active"],
    );
  }
}


class ChannelUpdate{
  String? description;
  bool? blocked;
  double? contentPercentageSharePerView;
  double? monthlyMembershipCost;
  double? monthlyMembershipCostInEuro;
  double? monthlyStreamingCost;
  double? monthlyStreamingCostInEuro;
  double? membershipPercentageSharePerMonth;
  DateTime? updatedOn;

  ChannelUpdate({
    this.description,
    this.blocked,
    this.contentPercentageSharePerView,
    this.monthlyMembershipCost,
    this.monthlyMembershipCostInEuro,
    this.monthlyStreamingCost,
    this.monthlyStreamingCostInEuro,
    this.membershipPercentageSharePerMonth,
    this.updatedOn,
  });


  Map<String, dynamic> toJson() {
    return {
      if (description!= null) "description": description,
      if (blocked!= null) "blocked": blocked,
      if (contentPercentageSharePerView!= null) "contentPercentageSharePerView": contentPercentageSharePerView,
      if (monthlyMembershipCost!= null) "monthlyMembershipCost": monthlyMembershipCost,
      if (monthlyMembershipCostInEuro!= null) "monthlyMembershipCostInEuro": monthlyMembershipCostInEuro,
      if (monthlyStreamingCost!= null) "monthlyStreamingCost": monthlyStreamingCost,
      if (monthlyStreamingCostInEuro!= null) "monthlyStreamingCostInEuro": monthlyStreamingCostInEuro,
      if (membershipPercentageSharePerMonth!= null) "membershipPercentageSharePerMonth": membershipPercentageSharePerMonth,
      if (updatedOn!= null) "updatedOn": updatedOn!.toString(),
    };
  }
}


enum AddVideoStep {
  policy,
  declaration, // iDeclared
  category, // select either Live or prepared (isLive)
  live, // liveStartsOn
  uploads, // videoUrl, thrillerVideoUrl, videoThumbnail
  titles, // title, description,
  target, // targetAudience, tags,
  publishType, // select either scheduled or published_now
  scheduled, // scheduledFor, timezone, 
  snippets,
  movie,
  music,
  cost,
  result // promote
}


class PendingNewVideo {
  AddVideoStep lastStep;
  String? channelId;
  bool? promoted;
  String? targetAudience; //  Adult, Youth, Teenage, Kids, General
  String? description;
  List<String>? tags;
  String? videoThumbnail;
  String? title;
  SaveVideoResponse? saveVideoProgress;
  SaveVideoResponse? saveThrillerProgress;
  String? videoUrl;
  String? videoType; // movies, music, news, learn, cuisines
  bool isLive;
  DateTime? liveStartsOn;
  DateTime? scheduledFor;
  String? timezone;
  double? costPerNonMemberView;
  bool? iDeclared;
  PrudVidDuration? videoDuration;
  List<VideoSnippet>? snippets;
  VideoThriller? thriller;
  String? movieDetailId;
  String? musicDetailId;
  VideoMovieDetail? movieDetail;
  VideoMusicDetail? musicDetail;
  PromoteVideo? sponsored;
  bool hasSavedVideo;
  ChannelVideo? savedVideo;
  bool hasSavedSnippets;
  bool hasSavedMovieDetails;
  bool hasSavedMusicDetails;
  bool hasSaveThriller;
  bool hasSavedSponsored;
  File? videoLocalFile;
  

  PendingNewVideo({
    this.channelId,
    this.targetAudience,
    this.description,
    this.videoThumbnail,
    this.title,
    this.videoUrl,
    this.videoType,
    this.timezone,
    this.costPerNonMemberView,
    this.iDeclared,
    this.videoDuration,
    this.movieDetailId,
    this.musicDetailId,
    this.movieDetail,
    this.musicDetail,
    this.scheduledFor,
    this.thriller,
    this.snippets,
    this.sponsored,
    this.savedVideo,
    this.hasSaveThriller = false,
    this.hasSavedMovieDetails = false,
    this.hasSavedMusicDetails = false,
    this.hasSavedSnippets = false,
    this.hasSavedSponsored = false,
    this.hasSavedVideo = false,
    this.isLive = false,
    this.lastStep = AddVideoStep.policy,
    this.liveStartsOn,
    this.promoted,
    this.tags,
    this.saveVideoProgress,
    this.saveThrillerProgress,
    this.videoLocalFile,
  });

  Map<String, dynamic> toJson() {
    return {
      "lastStep": lastStep.index,
      "tags": tags,
      "scheduledFor": scheduledFor?.toString(),
      "liveStartsOn": liveStartsOn?.toString(),
      "targetAudience": targetAudience,
      "channelId": channelId,
      "promoted": promoted,
      "description": description,
      "videoThumbnail": videoThumbnail,
      "title": title,
      "videoUrl": videoUrl,
      "videoType": videoType,
      "isLive": isLive,
      "timezone": timezone,
      "costPerNonMemberView": costPerNonMemberView,
      "iDeclared": iDeclared,
      "videoDuration": videoDuration?.toJson(),
      "movieDetailId": movieDetailId,
      "musicDetailId": musicDetailId,
      "snippets": snippets?.map((snap) => snap.toJson()).toList(),
      "thriller": thriller?.toJson(),
      "movieDetail": movieDetail?.toJson(),
      "musicDetail": musicDetail?.toJson(),
      "saveVideoProgress": saveVideoProgress?.toJson(),
      "saveThrillerProgress": saveThrillerProgress?.toJson(),
      "sponsored": sponsored?.toJson(),
      "hasSavedVideo": hasSavedVideo,
      "savedVideo": savedVideo?.toJson(),
      "hasSavedSnippets": hasSavedSnippets,
      "hasSavedMovieDetails": hasSavedMovieDetails,
      "hasSavedMusicDetails": hasSavedMusicDetails,
      "hasSaveThriller": hasSaveThriller,
      "hasSavedSponsored": hasSavedSponsored,
      if(videoLocalFile != null) "videoLocalFile": videoLocalFile!.path,
    };
  }

  factory PendingNewVideo.fromJson(Map<String, dynamic> json) {
    return PendingNewVideo(
      lastStep: AddVideoStep.values.elementAt(json["lastStep"]),
      channelId: json["channelId"],
      targetAudience: json["targetAudience"],
      description: json["description"],
      videoThumbnail: json["videoThumbnail"],
      title: json["title"],
      videoUrl: json["videoUrl"],
      liveStartsOn: json["liveStartsOn"] != null? DateTime.parse(json["liveStartsOn"]) : null,
      promoted: json["promoted"],
      videoType: json["videoType"],
      timezone: json["timezone"],
      costPerNonMemberView: json["costPerNonMemberView"],
      iDeclared: json["iDeclared"],
      videoDuration: json["videoDuration"] != null? PrudVidDuration.fromJson(json["videoDuration"]) : null,
      movieDetailId: json["movieDetailId"],
      musicDetailId: json["musicDetailId"],
      saveVideoProgress: json["saveVideoProgress"] != null? SaveVideoResponse.fromJson(json["saveVideoProgress"]) : null,
      saveThrillerProgress: json["saveThrillerProgress"] != null? SaveVideoResponse.fromJson(json["saveThrillerProgress"]) : null,
      tags: json["tags"],
      scheduledFor: json["scheduledFor"] != null? DateTime.parse(json["scheduledFor"]) : null,
      snippets: json["snippets"]?.map((itm) => VideoSnippet.fromJson(itm)).toList(),
      thriller: json["thriller"] != null? VideoThriller.fromJson(json["thriller"]) : null,
      movieDetail: json["movieDetail"] != null? VideoMovieDetail.fromJson(json["movieDetail"]) : null,
      musicDetail: json["musicDetail"] != null? VideoMusicDetail.fromJson(json["musicDetail"]) : null,
      isLive: json["isLive"],
      sponsored: json["sponsored"] != null? PromoteVideo.fromJson(json["sponsored"]) : null,
      hasSavedVideo: json["hasSavedVideo"],
      savedVideo: json["savedVideo"] != null? ChannelVideo.fromJson(json["savedVideo"]) : null,
      hasSavedSnippets: json["hasSavedSnippets"],
      hasSavedMovieDetails: json["hasSavedMovieDetails"],
      hasSavedMusicDetails: json["hasSavedMusicDetails"],
      hasSaveThriller: json["hasSaveThriller"],
      hasSavedSponsored: json["hasSavedSponsored"],
      videoLocalFile: json["videoLocalFile"] != null? File(json["videoLocalFile"]) : null,
    );
  }
}

class PrudVidDuration{
  String hours;
  String minutes;
  String seconds;

  PrudVidDuration({
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  Map<String, dynamic> toJson() {
    return {
      "hours": hours,
      "minutes": minutes,
      "seconds": seconds,
    };
  }

  factory PrudVidDuration.fromJson(Map<String, dynamic> json) {
    return PrudVidDuration(
      hours: json["hours"],
      minutes: json["minutes"],
      seconds: json["seconds"],
    );
  }
}