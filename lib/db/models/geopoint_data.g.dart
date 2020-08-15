part of 'geopoint_data.dart';

GeoPointData _$GeoPointDataFromJson(Map<String, dynamic> json) {
  return GeoPointData()
    ..geoHash = json['geo_hash'] as String
    ..latitude = (json['latitude'] as num)?.toDouble()
    ..longitude = (json['longitude'] as num)?.toDouble();
}

Map<String, dynamic> _$GeoPointDataToJson(GeoPointData instance) =>
    <String, dynamic>{
      'geo_hash': instance.geoHash,
      'latitude': instance.latitude,
      'longitude': instance.longitude
    };
