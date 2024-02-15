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
  });

  Map<String, dynamic> toJson() => {
    if(id != null) 'id': id,
    if(deviceRegToken != null) 'device_push_token': deviceRegToken,
    if(fullName != null) 'fullname': fullName,
    if(password != null) 'password': password,
    if(email != null) 'email': email,
    if(country != null) 'country': country,
    if(state != null) 'state': state,
    if(city != null) 'city': city,
    if(town != null) 'town': town,
    if(phoneNo != null) 'phone_no': phoneNo,
    if(createdAt != null) 'created_at': createdAt?.toIso8601String(),
    if(updatedAt != null) 'updated_at': updatedAt?.toIso8601String()
  };

  factory User.fromJson(dynamic json) {
    return User(
      id: json['id'] as String?,
      deviceRegToken: json['device_push_token'] as String?,
      password: json['password'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      town: json['town'] as String?,
      city: json['city'] as String?,
      phoneNo: json['phone_no'] as String?,
      email: json['email'] as String?,
      fullName: json['fullname'] as String?,
      createdAt: json['created_at'] != null? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null? DateTime.parse(json['updated_at']) : null,
    );
  }

}
