import 'package:flutter/foundation.dart';


class PhoneDetails{
  String? countryCode;
  String? phoneNumber;

  PhoneDetails({
    this.countryCode,
    this.phoneNumber
  });

  Map<String, dynamic> toJson(){
    return {
      if(countryCode != null) "countryCode": countryCode,
      if(phoneNumber != null) "phoneNumber": phoneNumber
    };
  }
}

class Beneficiary{
  String fullName;
  String countryCode;
  String phoneNo;
  String currencyCode;
  String gender;
  String email;
  String avatar;
  dynamic photo;
  bool isAvatar;
  String parseablePhoneNo;

  Beneficiary({
    required this.currencyCode,
    required this.countryCode,
    required this.fullName,
    required this.gender,
    required this.phoneNo,
    required this.email,
    required this.avatar,
    required this.photo,
    required this.parseablePhoneNo,
    this.isAvatar = true,
  });

  Map<String, dynamic> toJson(){
    return {
      "countryCode": countryCode,
      "currencyCode": currencyCode,
      "fullName": fullName,
      "email": email,
      "phoneNo": phoneNo,
      "gender": gender,
      "avatar": avatar,
      "isAvatar": isAvatar,
      "photo": photo,
      "parseablePhoneNo": parseablePhoneNo,
    };
  }

  factory Beneficiary.fromJson(Map<String, dynamic> json){
    return Beneficiary(
      currencyCode: json["currencyCode"],
      countryCode: json["countryCode"],
      fullName: json["fullName"],
      gender: json["gender"],
      phoneNo: json["phoneNo"],
      email: json["email"],
      avatar: json["avatar"],
      isAvatar: json["isAvatar"],
      parseablePhoneNo: json["parseablePhoneNo"],
      photo: json["photo"] != null? Uint8List.fromList(json["photo"].cast<int>().toList()) : null,
    );
  }
}

class PhoneNo{
  String? countryCode;
  int? number;

  PhoneNo({
    this.countryCode,
    this.number,
  });

  Map<String, dynamic> toJson(){
    return {
      if(countryCode != null) "countryCode": countryCode,
      if(number != null) "number": number,
    };
  }

  factory PhoneNo.fromJson(Map<String, dynamic> json){
    return PhoneNo(
      countryCode: json["countryCode"],
      number: json["number"],
    );
  }
}