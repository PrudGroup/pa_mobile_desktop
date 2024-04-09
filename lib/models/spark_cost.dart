class SparkCost{
  String? id;
  String? platform;
  double? costPerSpark;

  SparkCost({
    this.id,
    this.platform,
    this.costPerSpark,
  });

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(platform != null) "platform": platform,
      if(costPerSpark != null) "costPerSpark": costPerSpark,
    };
  }

  factory SparkCost.fromJson(Map<String, dynamic> json){
    return SparkCost(
      id: json["id"] as String?,
      costPerSpark: json["cost_per_spark"] as double?,
      platform: json["platform"] as String?
    );
  }
}