import 'dart:core';

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
  });

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
    );
  }

}
