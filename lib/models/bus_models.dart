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
      "brand_name": brandName,
      "email": email,
      "country": country,
      "own_by": ownBy,
      if(slogan != null) "slogan": slogan!,
      if(status != null) "status": status,
      "logo": logo,
      "registrar": registrar,
      if(emailVerified != null) "email_verified": emailVerified,
      "gov_registration_id": govRegistrationId,
      "votes": votes,
      "voters": voters,
      "referral_code": referralCode,
      if(createdOn != null) "created_on": createdOn!.toIso8601String(),
      if(updatedAt != null) "updated_at": updatedAt!.toIso8601String()
    };
  }

  factory BusBrand.fromJson(Map<String, dynamic> json){
    return BusBrand(
      email: json["email"],
      country: json["country"],
      brandName: json["brand_name"],
      govRegistrationId: json["gov_registration_id"],
      logo: json["logo"],
      ownBy: json["own_by"],
      registrar: json["registrar"],
      referralCode: json["referral_code"],
      slogan: json["slogan"],
      status: json["status"],
      createdOn: json["created_on"] != null? DateTime.parse(json["created_on"]) : null,
      updatedAt: json["updated_at"] != null? DateTime.parse(json["updated_at"]) : null,
      id: json["id"],
      voters: json["voters"],
      votes: json["votes"],
      emailVerified: json["email_verified"],
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
      if(createdOn != null) "created_on": createdOn!.toIso8601String(),
      if(updatedAt != null) "updated_at": updatedAt!.toIso8601String(),
      if(id != null) "id": id,
      "role": role,
      "brand_id": brandId,
      "status": status,
      "aff_id": affId
    };
  }

  factory BusBrandOperator.fromJson(Map<String, dynamic> json){
    return BusBrandOperator(
      affId: json["aff_id"],
      status: json["status"],
      brandId: json["brand_id"],
      role: json["role"],
      createdOn: json["created_on"] != null? DateTime.parse(json["created_on"]) : null,
      updatedAt: json["updated_at"] != null? DateTime.parse(json["updated_at"]) : null,
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
      "operator_id": operatorId,
      "joined_date": joinedDate.toIso8601String(),
      "added_by": addedBy,
      "rank": rank,
      "journeys": journeys,
      "active": active,
      "votes": votes,
      "voters": voters,
      if(createdAt != null) "created_at": createdAt!.toIso8601String(),
      if(updatedAt != null) "updated_at": updatedAt!.toIso8601String()
    };
  }

  factory BusBrandDriver.fromJson(Map<String, dynamic> json){
    return BusBrandDriver(
      operatorId: json["operator_id"],
      joinedDate: json["joined_date"],
      addedBy: json["added_by"],
      rank: json["rank"],
      journeys: json["journeys"],
      active: json["active"],
      votes: json["votes"],
      voters: json["voters"],
      createdAt: json["created_at"] != null? DateTime.parse(json["created_at"]) : null,
      updatedAt: json["updated_at"] != null? DateTime.parse(json["updated_at"]) : null,
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
      if(createdOn != null) "created_on": createdOn!.toIso8601String(),
      if(updatedOn != null) "updated_on": updatedOn!.toIso8601String(),
      "bus_type": busType,
      "bus_no": busNo,
      "bus_manufacturer": busManufacturer,
      "bought_on": boughtOn,
      "brand_id": brandId,
      "active": active,
      "created_by": createdBy,
      "manufactured_year": manufacturedYear,
      "votes": votes,
      "voters": voters,
      "plateN_no": plateNo,
      "total_journey": totalJourney
    };
  }

  factory Bus.fromJson(Map<String, dynamic> json){
    return Bus(
      brandId: json["brand_id"],
      boughtOn: json["bought_on"],
      busManufacturer: json["bus_manufacturer"],
      busNo: json["bus_no"],
      busType: json["bus_type"],
      createdBy: json["created_by"],
      manufacturedYear: json["manufactured_year"],
      plateNo: json["plate_no"],
      totalJourney: json["total_journey"],
      createdOn: json["created_on"] != null? DateTime.parse(json["created_on"]) : null,
      updatedOn: json["updated_on"] != null? DateTime.parse(json["updated_on"]) : null,
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
      if(createdOn != null) "created_on": createdOn!.toIso8601String(),
      if(updatedOn != null) "updated_on": updatedOn!.toIso8601String(),
      "description": description,
      "bus_id": busId,
      "seat_no": seatNo,
      "position": position,
      "seat_type": seatType,
      "status": status,
      "created_by": createdBy,
      "fixed": fixed,
      "votes": votes,
      "voters": voters,
      if(fixedDate != null) "fixed_date": fixedDate!.toIso8601String(),
      if(statusDate != null) "status_date": statusDate!.toIso8601String(),
    };
  }

  factory BusSeat.fromJson(Map<String, dynamic> json){
    return BusSeat(
      description: json["description"],
      busId: json["bus_id"],
      position: json["position"],
      seatNo: json["seat_no"],
      seatType: json["seat_type"],
      createdBy: json["created_by"],
      status: json["status"],
      fixed: json["fixed"],
      statusDate: json["status_date"] != null? DateTime.parse(json["status_date"]) : null,
      fixedDate: json["fixed_date"] != null? DateTime.parse(json["fixed_date"]) : null,
      createdOn: json["created_on"] != null? DateTime.parse(json["created_on"]) : null,
      updatedOn: json["updated_on"] != null? DateTime.parse(json["updated_on"]) : null,
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
      if(createdOn != null) "created_on": createdOn!.toIso8601String(),
      if(updatedOn != null) "updated_on": updatedOn!.toIso8601String(),
      "description": description,
      "bus_id": busId,
      "feature_name": featureName,
      "subtitle": subtitle,
      "how_to": howTo,
      "status": status,
      "created_by": createdBy,
      "fixed": fixed,
      "votes": votes,
      "voters": voters,
      if(fixedDate != null) "fixed_date": fixedDate!.toIso8601String(),
      if(statusDate != null) "status_date": statusDate!.toIso8601String(),
    };
  }

  factory BusFeature.fromJson(Map<String, dynamic> json){
    return BusFeature(
      description: json["description"],
      busId: json["bus_id"],
      featureName: json["feature_name"],
      subtitle: json["subtitle"],
      howTo: json["how_to"],
      createdBy: json["created_by"],
      status: json["status"],
      fixed: json["fixed"],
      statusDate: json["status_date"] != null? DateTime.parse(json["status_date"]) : null,
      fixedDate: json["fixed_date"] != null? DateTime.parse(json["fixed_date"]) : null,
      createdOn: json["created_on"] != null? DateTime.parse(json["created_on"]) : null,
      updatedOn: json["updated_on"] != null? DateTime.parse(json["updated_on"]) : null,
      id: json["id"],
      voters: json["voters"],
      votes: json["votes"],
    );
  }
}


class BusImages{
  String? id;
  String busId;
  String imgUrl;
  String createdBy;
  DateTime? createdOn;
  DateTime? updatedOn;

  BusImages({
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
      if(createdOn != null) "created_on": createdOn!.toIso8601String(),
      if(updatedOn != null) "updated_on": updatedOn!.toIso8601String(),
      "bus_id": busId,
      "img_url": imgUrl,
      "created_by": createdBy,
    };
  }

  factory BusImages.fromJson(Map<String, dynamic> json){
    return BusImages(
      busId: json["bus_id"],
      imgUrl: json["img_url"],
      createdBy: json["created_by"],
      createdOn: json["created_on"] != null? DateTime.parse(json["created_on"]) : null,
      updatedOn: json["updated_on"] != null? DateTime.parse(json["updated_on"]) : null,
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
  JourneyPoint depPoint;
  JourneyPoint arrPoint;
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

  Journey({
    required this.createdBy,
    required this.driverId,
    required this.busId,
    required this.departureCity,
    required this.depPoint,
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
    required this.arrPoint,
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
    this.arrivedAt
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
      "depPoint": depPoint.toJson(),
      "arrPoint": arrPoint.toJson(),
      "status": status,
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
      depPoint: JourneyPoint.fromJson(json["depPoint"]),
      arrPoint: JourneyPoint.fromJson(json["arrPoint"]),
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
      statusDate: json["statusDate"] != null? DateTime.parse(json["status_date"]) : null,
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