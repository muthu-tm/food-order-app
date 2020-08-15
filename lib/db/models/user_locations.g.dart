// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLocations _$UserLocationsFromJson(Map<String, dynamic> json) {
  return UserLocations()
    ..uuid = json['uuid'] as String ?? ''
    ..locationName = json['loc_name'] as String ?? ''
    ..address = json['address'] == null
        ? new Address()
        : Address.fromJson(json['address'] as Map<String, dynamic>)
    ..geoPoint = json['geo_point'] == null
        ? new GeoPointData()
        : GeoPointData.fromJson(json['geo_point'] as Map<String, dynamic>);
}

Map<String, dynamic> _$UserLocationsToJson(UserLocations instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'loc_name': instance.locationName,
      'address': instance.address?.toJson(),
      'geo_point': instance.geoPoint?.toJson(),
    };
