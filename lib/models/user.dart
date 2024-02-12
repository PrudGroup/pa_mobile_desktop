class User {
  String? id;
  String? email;
  String? fullName;
  String? countryOfResidence;
  String? deviceRegToken;
  String? phoneNo;
  String? pin;
  DateTime? createdOn;

  User({
    this.id,
    this.deviceRegToken,
    this.pin,
    this.countryOfResidence,
    this.phoneNo,
    this.email,
    this.fullName,
    this.createdOn
  });

  Map<String, dynamic> toJson() => {
    if(id != null) 'id': id,
    if(deviceRegToken != null) 'deviceRegToken': deviceRegToken,
    if(fullName != null) 'fullName': fullName,
    if(pin != null) 'pin': pin,
    if(email != null) 'email': email,
    if(countryOfResidence != null) 'countryOfResidence': countryOfResidence,
    if(createdOn != null) 'createdOn': createdOn?.toIso8601String()
  };

  factory User.fromJson(dynamic json) {
    return User(
      id: json['id'] as String,
      deviceRegToken: json['deviceRegToken'] as String,
      pin: json['pin'] as String,
      countryOfResidence: json['countryOfResidence'] as String,
      phoneNo: json['phoneNo'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      createdOn: DateTime.parse((json['createdOn'] as String)),
    );
  }

}
