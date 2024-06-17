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
      if(sparkId != null) "spark_id": sparkId,
      if(affId != null) "aff_id": affId,
      if(totalSparks != null) "total_sparks": totalSparks,
      if(shortenerId != null) "shortener_id": shortenerId,
      if(createdAt != null) "created_at": createdAt!.toIso8601String(),
      if(updatedAt != null) "updated_at": updatedAt!.toIso8601String(),
      if(fullShortUrl != null) "full_short_url": fullShortUrl,
    };
  }

  factory AffLink.fromJson(dynamic json){
    return AffLink(
      id: json["id"] as String?,
      sparkId: json["spark_id"] as String?,
      affId: json["aff_id"] as String?,
      totalSparks: json["total_sparks"] as int?,
      shortenerId: json["shortener_id"] as String?,
      createdAt: json["created_at"] != null? DateTime.parse(json["created_at"]) : null,
      updatedAt: json["updated_at"] != null? DateTime.parse(json["updated_at"]) : null,
      fullShortUrl: json["full_short_url"] as String?,
    );
  }

}