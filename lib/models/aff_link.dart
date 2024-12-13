class AffLink {

  String? id;
  String? sparkId;
  String? affId;
  int? totalSparks;
  String? shortenerId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? fullShortUrl;

  AffLink({
    this.id,
    this.sparkId,
    this.affId,
    this.totalSparks,
    this.shortenerId,
    this.createdAt,
    this.updatedAt,
    this.fullShortUrl,
  });

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(sparkId != null) "sparkId": sparkId,
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
      sparkId: json["sparkId"] as String?,
      affId: json["affId"] as String?,
      totalSparks: json["totalSparks"] as int?,
      shortenerId: json["shortenerId"] as String?,
      createdAt: json["createdAt"] != null? DateTime.parse(json["createdAt"]) : null,
      updatedAt: json["updatedAt"] != null? DateTime.parse(json["updatedAt"]) : null,
      fullShortUrl: json["fullShortUrl"] as String?,
    );
  }

}