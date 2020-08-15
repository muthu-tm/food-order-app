import 'package:json_annotation/json_annotation.dart';

part 'geopoint_data.g.dart';

@JsonSerializable(explicitToJson: true)
class GeoPointData {
  @JsonKey(name: 'latitude')
  double latitude;
  @JsonKey(name: 'longitude')
  double longitude;
  @JsonKey(name: 'geo_hash')
  String geoHash;

  GeoPointData();

  factory GeoPointData.fromJson(Map<String, dynamic> json) =>
      _$GeoPointDataFromJson(json);
  Map<String, dynamic> toJson() => _$GeoPointDataToJson(this);
}
