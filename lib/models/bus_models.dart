import 'package:prudapp/models/user.dart';

class BusBrand{
  String? id;
  String brandName;
  String email;
  String country;
  String ownBy;
  String? slogan;
  String? status;
  String logo;
  String registrar;
  bool? emailVerified;
  String govRegistrationId;
  int votes;
  int voters;
  String? referralCode;
  DateTime? createdOn;
  DateTime? updatedAt;

  BusBrand({
    required this.email,
    required this.country,
    required this.brandName,
    required this.govRegistrationId,
    required this.logo,
    required this.ownBy,
    this.status,
    this.id,
    this.createdOn,
    this.updatedAt,
    this.referralCode,
    this.emailVerified,
    required this.registrar,
    this.slogan,
    this.voters = 0,
    this.votes = 0
  });

  double getRating(){
    if(voters > 0 && votes > 0) return votes/voters;
    return 0;
  }

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      "brandName": brandName,
      "email": email,
      "country": country,
      "ownBy": ownBy,
      if(slogan != null) "slogan": slogan!,
      if(status != null) "status": status,
      "logo": logo,
      "registrar": registrar,
      if(emailVerified != null) "emailVerified": emailVerified,
      "govRegistrationId": govRegistrationId,
      "votes": votes,
      "voters": voters,
      "referralCode": referralCode,
      if(createdOn != null) "createdOn": createdOn!.toIso8601String(),
      if(updatedAt != null) "updatedAt": updatedAt!.toIso8601String()
    };
  }

  factory BusBrand.fromJson(Map<String, dynamic> json){
    return BusBrand(
      email: json["email"],
      country: json["country"],
      brandName: json["brandName"],
      govRegistrationId: json["govRegistrationId"],
      logo: json["logo"],
      ownBy: json["ownBy"],
      registrar: json["registrar"],
      referralCode: json["referralCode"],
      slogan: json["slogan"],
      status: json["status"],
      createdOn: json["createdOn"] != null? DateTime.parse(json["createdOn"]) : null,
      updatedAt: json["updatedAt"] != null? DateTime.parse(json["updatedAt"]) : null,
      id: json["id"],
      voters: json["voters"],
      votes: json["votes"],
      emailVerified: json["emailVerified"],
    );
  }
}

class OperatorDetails{
  BusBrandOperator op;
  User detail;

  OperatorDetails({required this.op, required this.detail});

  Map<String, dynamic> toJson(){
    return {
      "op": op.toJson(),
      "detail": detail.toJson()
    };
  }

  factory OperatorDetails.fromJson(Map<String, dynamic> json) {
    return OperatorDetails(
      op: BusBrandOperator.fromJson(json["op"]),
      detail: User.fromJson(json["detail"])
    );
  }
}

class DriverDetails{
  BusBrandDriver dr;
  User detail;

  DriverDetails({required this.dr, required this.detail});

  Map<String, dynamic> toJson(){
    return {
      "dr": dr.toJson(),
      "detail": detail.toJson()
    };
  }

  factory DriverDetails.fromJson(Map<String, dynamic> json) {
    return DriverDetails(
      dr: BusBrandDriver.fromJson(json["dr"]),
      detail: User.fromJson(json["detail"])
    );
  }
}


class BusBrandOperator{
  String? id;
  String affId;
  String role; // SUPER, ADMIN
  String status; // PENDING, ACTIVE, BLOCKED
  String brandId;
  DateTime? createdOn;
  DateTime? updatedAt;

  BusBrandOperator({
    required this.affId,
    required this.status,
    required this.brandId,
    required this.role,
    this.updatedAt,
    this.createdOn,
    this.id
  });

  Map<String, dynamic> toJson(){
    return {
      if(createdOn != null) "createdOn": createdOn!.toIso8601String(),
      if(updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
      if(id != null) "id": id,
      "role": role,
      "brandId": brandId,
      "status": status,
      "affId": affId
    };
  }

  factory BusBrandOperator.fromJson(Map<String, dynamic> json){
    return BusBrandOperator(
      affId: json["affId"],
      status: json["status"],
      brandId: json["brandId"],
      role: json["role"],
      createdOn: json["createdOn"] != null? DateTime.parse(json["createdOn"]) : null,
      updatedAt: json["updatedAt"] != null? DateTime.parse(json["updatedAt"]) : null,
      id: json["id"],
    );
  }
}

class BusBrandDriver{
  String? id;
  bool active = true;
  DateTime joinedDate;
  String operatorId;
  int journeys;
  String addedBy;
  String rank;  // senior junior
  int votes;
  int voters;
  DateTime? createdAt;
  DateTime? updatedAt;

  BusBrandDriver({
    required this.operatorId,
    required this.joinedDate,
    required this.addedBy,
    required this.rank,
    required this.journeys,
    this.id,
    this.votes = 0,
    this.voters = 0,
    this.active = true,
    this.updatedAt,
    this.createdAt
  });

  double getRating(){
    if(voters > 0 && votes > 0) return votes/voters;
    return 0;
  }

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      "operatorId": operatorId,
      "joinedDate": joinedDate.toIso8601String(),
      "addedBy": addedBy,
      "rank": rank,
      "journeys": journeys,
      "active": active,
      "votes": votes,
      "voters": voters,
      if(createdAt != null) "createdAt": createdAt!.toIso8601String(),
      if(updatedAt != null) "updatedAt": updatedAt!.toIso8601String()
    };
  }

  factory BusBrandDriver.fromJson(Map<String, dynamic> json){
    return BusBrandDriver(
      operatorId: json["operatorId"],
      joinedDate: DateTime.parse(json["joinedDate"]),
      addedBy: json["addedBy"],
      rank: json["rank"],
      journeys: json["journeys"],
      active: json["active"],
      votes: json["votes"],
      voters: json["voters"],
      createdAt: json["createdAt"] != null? DateTime.parse(json["createdAt"]) : null,
      updatedAt: json["updatedAt"] != null? DateTime.parse(json["updatedAt"]) : null,
      id: json["id"],
    );
  }
}

class Bus{
  String? id;
  String brandId;
  String plateNo;
  String busType;
  String busNo;
  String busManufacturer;
  int manufacturedYear;
  DateTime boughtOn;
  bool active;
  int votes;
  int voters;
  int totalJourney;
  String createdBy;
  DateTime? createdOn;
  DateTime? updatedOn;

  Bus({
    required this.brandId,
    required this.boughtOn,
    required this.busManufacturer,
    required this.busNo,
    required this.busType,
    required this.createdBy,
    required this.manufacturedYear,
    required this.plateNo,
    required this.totalJourney,
    this.voters = 0,
    this.votes = 0,
    this.active = true,
    this.id,
    this.createdOn,
    this.updatedOn
  });

  double getRating(){
    if(voters > 0 && votes > 0) return votes/voters;
    return 0;
  }

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(createdOn != null) "createdOn": createdOn!.toIso8601String(),
      if(updatedOn != null) "updatedOn": updatedOn!.toIso8601String(),
      "busType": busType,
      "busNo": busNo,
      "busManufacturer": busManufacturer,
      "boughtOn": boughtOn.toIso8601String(),
      "brandId": brandId,
      "active": active,
      "createdBy": createdBy,
      "manufacturedYear": manufacturedYear,
      "votes": votes,
      "voters": voters,
      "plateNo": plateNo,
      "totalJourney": totalJourney
    };
  }

  factory Bus.fromJson(Map<String, dynamic> json){
    return Bus(
      brandId: json["brandId"],
      boughtOn: DateTime.parse(json["boughtOn"]),
      busManufacturer: json["busManufacturer"],
      busNo: json["busNo"],
      busType: json["busType"],
      createdBy: json["createdBy"],
      manufacturedYear: json["manufacturedYear"],
      plateNo: json["plateNo"],
      totalJourney: json["totalJourney"],
      createdOn: json["createdOn"] != null? DateTime.parse(json["createdOn"]) : null,
      updatedOn: json["updatedOn"] != null? DateTime.parse(json["updatedOn"]) : null,
      id: json["id"],
      active: json["active"],
      voters: json["voters"],
      votes: json["votes"],
    );
  }
}

class BusSeat{
  String? id;
  String busId;
  String seatNo;
  String seatType; // economy, executive, Business
  String position;
  String description;
  String status; // Excellent, Bad, Good,
  DateTime? statusDate;
  bool fixed;
  DateTime? fixedDate;
  int votes;
  int voters;
  String createdBy;
  DateTime? createdOn;
  DateTime? updatedOn;

  BusSeat({
    required this.createdBy,
    required this.description,
    required this.busId,
    required this.position,
    required this.seatNo,
    required this.seatType,
    required this.status,
    this.votes = 0,
    this.voters = 0,
    this.fixed = true,
    this.createdOn,
    this.updatedOn,
    this.id,
    this.fixedDate,
    this.statusDate
  });

  double getRating(){
    if(voters > 0 && votes > 0) return votes/voters;
    return 0;
  }

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(createdOn != null) "createdOn": createdOn!.toIso8601String(),
      if(updatedOn != null) "updatedOn": updatedOn!.toIso8601String(),
      "description": description,
      "busId": busId,
      "seatNo": seatNo,
      "position": position,
      "seatType": seatType,
      "status": status,
      "createdBy": createdBy,
      "fixed": fixed,
      "votes": votes,
      "voters": voters,
      if(fixedDate != null) "fixedDate": fixedDate!.toIso8601String(),
      if(statusDate != null) "statusDate": statusDate!.toIso8601String(),
    };
  }

  factory BusSeat.fromJson(Map<String, dynamic> json){
    return BusSeat(
      description: json["description"],
      busId: json["busId"],
      position: json["position"],
      seatNo: json["seatNo"],
      seatType: json["seatType"],
      createdBy: json["createdBy"],
      status: json["status"],
      fixed: json["fixed"],
      statusDate: json["statusDate"] != null? DateTime.parse(json["statusDate"]) : null,
      fixedDate: json["fixedDate"] != null? DateTime.parse(json["fixedDate"]) : null,
      createdOn: json["createdOn"] != null? DateTime.parse(json["createdOn"]) : null,
      updatedOn: json["updatedOn"] != null? DateTime.parse(json["updatedOn"]) : null,
      id: json["id"],
      voters: json["voters"],
      votes: json["votes"],
    );
  }
}


class BusFeature{
  String? id;
  String busId;
  String featureName;
  String subtitle;
  String description;
  String howTo;
  String status; // Excellent, Bad, Good,
  DateTime? statusDate;
  bool fixed;
  DateTime? fixedDate;
  int votes;
  int voters;
  String createdBy;
  DateTime? createdOn;
  DateTime? updatedOn;

  BusFeature({
    required this.createdBy,
    required this.description,
    required this.busId,
    required this.featureName,
    required this.subtitle,
    required this.howTo,
    required this.status,
    this.votes = 0,
    this.voters = 0,
    this.fixed = true,
    this.createdOn,
    this.updatedOn,
    this.id,
    this.fixedDate,
    this.statusDate
  });

  double getRating(){
    if(voters > 0 && votes > 0) return votes/voters;
    return 0;
  }

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(createdOn != null) "createdOn": createdOn!.toIso8601String(),
      if(updatedOn != null) "updatedOn": updatedOn!.toIso8601String(),
      "description": description,
      "busId": busId,
      "featureName": featureName,
      "subtitle": subtitle,
      "howTo": howTo,
      "status": status,
      "createdBy": createdBy,
      "fixed": fixed,
      "votes": votes,
      "voters": voters,
      if(fixedDate != null) "fixedDate": fixedDate!.toIso8601String(),
      if(statusDate != null) "statusDate": statusDate!.toIso8601String(),
    };
  }

  factory BusFeature.fromJson(Map<String, dynamic> json){
    return BusFeature(
      description: json["description"],
      busId: json["busId"],
      featureName: json["featureName"],
      subtitle: json["subtitle"],
      howTo: json["howTo"],
      createdBy: json["createdBy"],
      status: json["status"],
      fixed: json["fixed"],
      statusDate: json["statusDate"] != null? DateTime.parse(json["statusDate"]) : null,
      fixedDate: json["fixedDate"] != null? DateTime.parse(json["fixedDate"]) : null,
      createdOn: json["createdOn"] != null? DateTime.parse(json["createdOn"]) : null,
      updatedOn: json["updatedOn"] != null? DateTime.parse(json["updatedOn"]) : null,
      id: json["id"],
      voters: json["voters"],
      votes: json["votes"],
    );
  }
}


class BusImage{
  String? id;
  String busId;
  String imgUrl;
  String createdBy;
  DateTime? createdOn;
  DateTime? updatedOn;

  BusImage({
    required this.createdBy,
    required this.imgUrl,
    required this.busId,
    this.createdOn,
    this.updatedOn,
    this.id,
  });

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(createdOn != null) "createdOn": createdOn!.toIso8601String(),
      if(updatedOn != null) "updatedOn": updatedOn!.toIso8601String(),
      "busId": busId,
      "imgUrl": imgUrl,
      "createdBy": createdBy,
    };
  }

  factory BusImage.fromJson(Map<String, dynamic> json){
    return BusImage(
      busId: json["busId"],
      imgUrl: json["imgUrl"],
      createdBy: json["createdBy"],
      createdOn: json["createdOn"] != null? DateTime.parse(json["createdOn"]) : null,
      updatedOn: json["updatedOn"] != null? DateTime.parse(json["updatedOn"]) : null,
      id: json["id"],
    );
  }
}


class JourneyDuration{
  int hours;
  int minutes;

  JourneyDuration({required this.hours, required this.minutes});

  Map<String, dynamic> toJson(){
    return {
      "hours": hours,
      "minutes": minutes
    };
  }

  factory JourneyDuration.fromJson(Map<String, dynamic> json){
    return JourneyDuration(hours: json["hours"], minutes: json["minutes"]);
  }
}


class JourneyPoint{
  double latitude;
  double longitude;

  JourneyPoint({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson(){
    return {
      "latitude": latitude,
      "longitude": longitude
    };
  }

  factory JourneyPoint.fromJson(Map<String, dynamic> json){
    return JourneyPoint(latitude: json["latitude"], longitude: json["longitude"]);
  }
}


class Journey{
  String? id;
  String brandId;
  String busId;
  String driverId;
  String departureCity;
  double economySeatPrice;
  double executiveSeatPrice;
  double businessSeatPrice;
  String priceCurrencyCode;
  String departureCountry;
  DateTime departureDate;
  String destinationCity;
  String destinationCountry;
  DateTime destinationDate;
  DateTime? departedAt;
  DateTime? arrivedAt;
  String createdBy;
  JourneyPoint? depPoint;
  JourneyPoint? arrPoint;
  String depTerminal;
  String arrTerminal;
  String status; // Pending Boarding Active Completed Cancelled
  DateTime? statusDate;
  DateTime? createdOn;
  DateTime? updatedOn;
  int votes;
  int voters;
  double totalFromFare;
  double totalFromAddOn;
  double platformCharges;
  double grandTotal;
  bool trackable;
  JourneyDuration duration;
  int departure;

  Journey({
    required this.createdBy,
    required this.driverId,
    required this.busId,
    required this.departure,
    required this.departureCity,
    required this.depTerminal,
    required this.arrTerminal,
    required this.departureCountry,
    required this.departureDate,
    required this.destinationCity,
    required this.destinationCountry,
    required this.destinationDate,
    required this.duration,
    required this.brandId,
    required this.businessSeatPrice,
    required this.economySeatPrice,
    required this.executiveSeatPrice,
    required this.priceCurrencyCode,
    this.status = "PENDING",
    this.trackable = true,
    this.votes = 0,
    this.voters = 0,
    this.grandTotal = 0,
    this.platformCharges = 0,
    this.totalFromAddOn = 0,
    this.totalFromFare = 0,
    this.createdOn,
    this.updatedOn,
    this.id,
    this.statusDate,
    this.departedAt,
    this.arrivedAt,
    this.depPoint,
    this.arrPoint,
  });

  double getRating(){
    if(voters > 0 && votes > 0) return votes/voters;
    return 0;
  }

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(createdOn != null) "createdOn": createdOn!.toIso8601String(),
      if(updatedOn != null) "updatedOn": updatedOn!.toIso8601String(),
      "driverId": driverId,
      "busId": busId,
      "departureCity": departureCity,
      if(depPoint != null) "depPoint": depPoint!.toJson(),
      if(arrPoint != null) "arrPoint": arrPoint!.toJson(),
      "status": status,
      "arrTerminal": arrTerminal,
      "depTerminal": depTerminal,
      "createdBy": createdBy,
      "departureCountry": departureCountry,
      "votes": votes,
      "voters": voters,
      "departureDate": departureDate.toIso8601String(),
      "destinationCity": destinationCity,
      "destinationCountry": destinationCountry,
      "destinationDate": destinationDate.toIso8601String(),
      "duration": duration.toJson(),
      "brandId": brandId,
      "businessSeatPrice": businessSeatPrice,
      "economySeatPrice": economySeatPrice,
      "executiveSeatPrice": executiveSeatPrice,
      "priceCurrencyCode": priceCurrencyCode,
      "grandTotal": grandTotal,
      "platformCharges": platformCharges,
      "totalFromAddOn": totalFromAddOn,
      "totalFromFare": totalFromFare,
      "trackable": trackable,
      "departure": departure,
      if(departedAt != null) "departedAt": departedAt!.toIso8601String(),
      if(arrivedAt != null) "arrivedAt": arrivedAt!.toIso8601String(),
      if(statusDate != null) "statusDate": statusDate!.toIso8601String(),
    };
  }

  factory Journey.fromJson(Map<String, dynamic> json){
    return Journey(
      createdBy: json["createdBy"],
      driverId: json["driverId"],
      busId: json["busId"],
      departureCity: json["departureCity"],
      depPoint: json["depPoint"] != null? JourneyPoint.fromJson(json["depPoint"]) : null,
      arrPoint: json["arrPoint"] != null? JourneyPoint.fromJson(json["arrPoint"]) : null,
      departureCountry: json["departureCountry"],
      priceCurrencyCode: json["priceCurrencyCode"],
      status: json["status"],
      destinationCity: json["destinationCity"],
      destinationCountry: json["destinationCountry"],
      duration: JourneyDuration.fromJson(json["duration"]),
      brandId: json["brandId"],
      businessSeatPrice: json["businessSeatPrice"],
      economySeatPrice: json["economySeatPrice"],
      executiveSeatPrice: json["executiveSeatPrice"],
      statusDate: json["statusDate"] != null? DateTime.parse(json["statusDate"]) : null,
      departureDate: DateTime.parse(json["departureDate"]),
      destinationDate: DateTime.parse(json["destinationDate"]),
      createdOn: json["createdOn"] != null? DateTime.parse(json["createdOn"]) : null,
      updatedOn: json["updatedOn"] != null? DateTime.parse(json["updatedOn"]) : null,
      departedAt: json["departedAt"] != null? DateTime.parse(json["departedAt"]) : null,
      arrivedAt: json["arrivedAt"] != null? DateTime.parse(json["arrivedAt"]) : null,
      id: json["id"],
      voters: json["voters"],
      votes: json["votes"],
      trackable: json["trackable"],
      grandTotal: json["grandTotal"],
      platformCharges: json["platformCharges"],
      totalFromAddOn: json["totalFromAddOn"],
      totalFromFare: json["totalFromFare"],
      depTerminal: json["depTerminal"],
      arrTerminal: json["arrTerminal"],
      departure: json["departure"]
    );
  }

}


class JourneyMemories{
  String? id;
  String journeyId;
  String postedBy;
  String mediaType;
  String mediaUrl;
  DateTime postedAt;
  JourneyPoint takenAt;

  JourneyMemories({
    required this.journeyId,
    required this.postedAt,
    required this.mediaType,
    required this.mediaUrl,
    required this.postedBy,
    required this.takenAt,
    this.id
  });

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      "postedAt": postedAt.toIso8601String(),
      "journeyId": journeyId,
      "mediaType": mediaType,
      "mediaUrl": mediaUrl,
      "postedBy": postedBy,
      "takenAt": takenAt.toJson(),
    };
  }

  factory JourneyMemories.fromJson(Map<String, dynamic> json){
    return JourneyMemories(
      takenAt: JourneyPoint.fromJson(json["takenAt"]),
      postedBy: json["postedBy"],
      mediaType: json["mediaType"],
      mediaUrl: json["mediaUrl"],
      postedAt: DateTime.parse(json["postedAt"]),
      journeyId: json["journeyId"],
      id: json["id"],
    );
  }
}


class JourneyPassenger{
  String? id;
  String journeyId;
  String affId;
  String seatId;
  DateTime bookedAt;
  String status; // Active, Canceled, completed
  DateTime? statusDate;
  bool onBoard;
  DateTime? onBoardAt;
  String? alightedInCity;
  DateTime? alightedAt;
  JourneyPoint? alightedPoint;


  JourneyPassenger({
    required this.journeyId,
    required this.affId,
    required this.bookedAt,
    required this.seatId,
    this.status = "Active",
    this.onBoard = false,
    this.alightedAt,
    this.id,
    this.alightedInCity,
    this.alightedPoint,
    this.onBoardAt,
    this.statusDate
  });

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(onBoardAt != null) "onBoardAt": onBoardAt!.toIso8601String(),
      if(statusDate != null) "statusDate": statusDate!.toIso8601String(),
      if(alightedAt != null) "alightedAt": alightedAt!.toIso8601String(),
      if(alightedPoint != null) "alightedPoint": alightedPoint!.toJson(),
      if(alightedInCity != null) "alightedInCity": alightedInCity,
      "status": status,
      "onBoard": onBoard,
      "journeyId": journeyId,
      "affId": affId,
      "bookedAt": bookedAt,
      "seatId": seatId,
    };
  }

  factory JourneyPassenger.fromJson(Map<String, dynamic> json){
    return JourneyPassenger(
      journeyId: json["journeyId"],
      affId: json["affId"],
      seatId: json["seatId"],
      status: json["status"],
      alightedPoint: json["alightedPoint"] != null? JourneyPoint.fromJson(json["alightedPoint"]) : null,
      onBoard: json["onBoard"],
      alightedInCity: json["alightedInCity"],
      bookedAt: DateTime.parse(json["bookedAt"]),
      alightedAt: json["alightedAt"] != null? DateTime.parse(json["alightedAt"]) : null,
      statusDate: json["statusDate"] != null? DateTime.parse(json["statusDate"]) : null,
      onBoardAt: json["onBoardAt"] != null? DateTime.parse(json["onBoardAt"]) : null,
      id: json["id"],
    );
  }
}


class BusBrandAddOn{
  String? id;
  String brandId;
  String title;
  String description;
  double pricePerUnit;
  int votes;
  int voters;
  String createdBy;
  DateTime? createdOn;

  BusBrandAddOn({
    required this.brandId,
    required this.title,
    required this.description,
    required this.pricePerUnit,
    required this.createdBy,
    this.votes = 0,
    this.voters = 0,
    this.id,
    this.createdOn
  });

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(createdOn != null) "createdOn": createdOn!.toIso8601String(),
      "brandId": brandId,
      "title": title,
      "description": description,
      "pricePerUnit": pricePerUnit,
      "votes": votes,
      "voters": voters,
      "createdBy": createdBy
    };
  }

  factory BusBrandAddOn.fromJson(Map<String, dynamic> json){
    return BusBrandAddOn(
      brandId: json["brandId"],
      title: json["title"],
      description: json["description"],
      pricePerUnit: json["pricePerUnit"],
      createdBy: json["createdBy"],
      votes: json["votes"],
      voters: json["voters"],
      id: json["id"],
      createdOn: json["createdOn"] != null? DateTime.parse(json["createdOn"]) : null,
    );
  }
}


class JourneyAddOnUser{
  String? id;
  String addOnId;
  String journeyId;
  String passengerId;
  int quantity;
  double total;
  bool cancelled;
  String createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;

  JourneyAddOnUser({
    required this.addOnId,
    required this.journeyId,
    required this.passengerId,
    required this.quantity,
    required this.total,
    required this.createdBy,
    required this.cancelled,
    this.id,
    this.createdAt,
    this.updatedAt
  });

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(createdAt != null) "createdAt": createdAt!.toIso8601String(),
      if(updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
      "addOnId": addOnId,
      "journeyId": journeyId,
      "passengerId": passengerId,
      "quantity": quantity,
      "total": total,
      "cancelled": cancelled,
      "createdBy": createdBy,
      "createdAt": createdAt,
    };
  }

  factory JourneyAddOnUser.fromJson(Map<String, dynamic> json){
    return JourneyAddOnUser(
      addOnId: json["addOnId"],
      journeyId: json["journeyId"],
      passengerId: json["passengerId"],
      quantity: json["quantity"],
      createdBy: json["createdBy"],
      total: json["total"],
      cancelled: json["cancelled"],
      id: json["id"],
      createdAt: json["createdAt"] != null? DateTime.parse(json["createdAt"]) : null,
      updatedAt: json["updatedAt"] != null? DateTime.parse(json["updatedAt"]) : null,
    );
  }
}


class BusDetail{
  Bus bus;
  List<BusFeature> features;
  List<BusSeat> seats;
  List<BusImage> images;

  BusDetail({
    required this.bus,
    required this.features,
    required this.images,
    required this.seats,
  });

  Map<String, dynamic> toJson(){
    return {
      "bus": bus.toJson(),
      "features": features.map((feature) => feature.toJson()).toList(),
      "seats": seats.map((seat) => seat.toJson()).toList(),
      "images": images.map((image) => image.toJson()).toList(),
    };
  }

  factory BusDetail.fromJson(Map<String, dynamic> json){
    return BusDetail(
      bus: Bus.fromJson(json["bus"]),
      features: json["features"].map<BusFeature>((feature) => BusFeature.fromJson(feature)).toList(),
      images: json["images"].map<BusImage>((image) => BusImage.fromJson(image)).toList(),
      seats: json["seats"].map<BusSeat>((seat) => BusSeat.fromJson(seat)).toList()
    );
  }
}

class JourneyWithBrand{
  Journey journey;
  BusBrand brand;

  JourneyWithBrand({
    required this.journey,
    required this.brand,
  });

  Map<String, dynamic> toJson(){
    return {
      "journey": journey.toJson(),
      "brand": brand.toJson(),
    };
  }

  factory JourneyWithBrand.fromJson(Map<String, dynamic> json){
    return JourneyWithBrand(
      journey: Journey.fromJson(json["journey"]),
      brand: BusBrand.fromJson(json["brand"])
    );
  }
}

class PassengerDetail{
  JourneyPassenger passenger;
  User user;
  BusSeat seat;

  PassengerDetail({
    required this.passenger,
    required this.user,
    required this.seat,
  });

  Map<String, dynamic> toJson(){
    return {
      "passenger": passenger.toJson(),
      "user": user.toJson(),
      "seat": seat.toJson(),
    };
  }

  factory PassengerDetail.fromJson(Map<String, dynamic> json){
    return PassengerDetail(
      passenger: JourneyPassenger.fromJson(json["passenger"]),
      user: User.fromJson(json["user"]),
      seat: BusSeat.fromJson(json["seat"]),
    );
  }
}