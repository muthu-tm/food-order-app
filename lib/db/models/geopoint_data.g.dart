part of 'geopoint_data.dart';

GeoPointData _$GeoPointDataFromJson(Map<String, dynamic> json) {
  return GeoPointData()
    ..geoHash = json['geohash'] as String
    ..geoPoint = json['geopoint'] as GeoPoint;
}

Map<String, dynamic> _$GeoPointDataToJson(GeoPointData instance) =>
    <String, dynamic>{
      'geohash': instance.geoHash,
      'geopoint': instance.geoPoint
    };
