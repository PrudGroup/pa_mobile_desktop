class Location{
  String? country;
  String? state;
  String? city;
  String? town;
  int? limit;
  String? offsetId;

  Location({
    this.country,
    this.state, this.city,
    this.town, this.limit = 50,
    this.offsetId
  });

  Map<String, dynamic> toJson(){
    return {
      if(country != null) "country": country,
      if(state != null) "state": state,
      if(city != null) "city": city,
      if(town != null) "town": town,
      if(limit != null) "limit": limit,
      if(offsetId != null) "offset_id": offsetId,
    };
  }
}