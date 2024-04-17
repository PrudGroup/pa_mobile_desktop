
class Spark {
  String? id;
  String? targetLink;
  String? sparkType;
  String? sparkCategory;
  int? targetSparks;
  String? locationTarget;
  List<dynamic> targetCountries;
  List<dynamic> targetStates;
  List<dynamic> targetCities;
  List<dynamic> targetTowns;
  int? duration;
  String? affId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? monthCreated;
  int? yearCreated;
  String? description;
  String? title;
  DateTime? startDate;
  String? status;
  int? sparksCount;

  Spark({
    this.id,
    this.title,
    this.affId,
    this.createdAt,
    this.updatedAt,
    this.monthCreated,
    this.yearCreated,
    this.description,
    this.duration,
    this.locationTarget,
    this.sparkCategory,
    this.sparkType,
    this.startDate,
    required this.targetCities,
    required this.targetCountries,
    this.targetLink,
    this.targetSparks,
    required this.targetStates,
    required this.targetTowns,
    this.status = "Pending",
    this.sparksCount = 0,
  });

  Map<String, dynamic> toJson() => {
    if(id != null) 'id': id,
    if(title != null) 'title': title,
    if(affId != null) 'aff_id': affId,
    if(createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if(updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    if(monthCreated != null) 'month_created': monthCreated,
    if(yearCreated != null) 'year_created': yearCreated,
    if(description != null) 'description': description,
    if(duration != null) 'duration': duration,
    if(locationTarget != null) 'location_target': locationTarget,
    if(sparkCategory != null) 'spark_category': sparkCategory,
    if(sparkType != null) 'spark_type': sparkType,
    if(startDate != null) 'start_date': startDate!.toIso8601String(),
    'target_cities': targetCities,
    'target_countries': targetCountries,
    if(targetLink != null) 'target_link': targetLink,
    if(targetSparks != null) 'target_sparks': targetSparks,
    'target_states': targetStates,
    'target_towns': targetTowns,
    if(status != null) 'status': status,
    if(sparksCount != null) 'sparks_count': sparksCount,
  };

  factory Spark.fromJson(dynamic json) {
    return Spark(
      id: json["id"] as String?,
      targetLink: json["target_link"] as String?,
      sparkType: json["spark_type"] as String?,
      sparkCategory: json["spark_category"] as String?,
      targetSparks: json["target_sparks"] as int?,
      locationTarget: json["location_target"] as String?,
      targetCountries: json["target_countries"] as List<dynamic>,
      targetStates: json["target_states"] as List<dynamic>,
      targetCities: json["target_cities"] as List<dynamic>,
      targetTowns: json["target_towns"] as List<dynamic>,
      duration: json["duration"] as int?,
      affId: json["aff_id"] as String?,
      createdAt: json["created_at"] != null? DateTime.parse(json["created_at"]) : null,
      updatedAt: json["updated_at"] != null? DateTime.parse(json["updated_at"]) : null,
      monthCreated: json["month_created"] as int?,
      yearCreated: json["year_created"] as int?,
      description: json["description"] as String?,
      title: json["title"] as String?,
      startDate: json["start_date"] != null? DateTime.parse(json["start_date"]) : null,
      status: json["status"] as String?,
      sparksCount: json["sparks_count"] as int?,
    );
  }

}