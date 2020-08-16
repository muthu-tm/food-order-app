import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'geopoint_data.g.dart';

@JsonSerializable(explicitToJson: true)
class GeoPointData {
  @JsonKey(name: 'geohash')
  String geoHash;
  @JsonKey(name: 'geopoint')
  GeoPoint geoPoint;

  GeoPointData();

  factory GeoPointData.fromJson(Map<String, dynamic> json) =>
      _$GeoPointDataFromJson(json);
  Map<String, dynamic> toJson() => _$GeoPointDataToJson(this);
}
