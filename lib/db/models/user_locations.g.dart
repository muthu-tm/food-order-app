// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLocations _$UserLocationsFromJson(Map<String, dynamic> json) {
  return UserLocations()
    ..uuid = json['uuid'] as String ?? ''
    ..userNumber = json['user_number'] as String
    ..locationName = json['loc_name'] as String ?? ''
    ..address = json['address'] == null
        ? new Address()
        : Address.fromJson(json['address'] as Map<String, dynamic>)
    ..geoPoint = json['geo_point'] == null
        ? null
        : GeoPointData.fromJson(json['geo_point'] as Map<String, dynamic>);
}

Map<String, dynamic> _$UserLocationsToJson(UserLocations instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'user_number': instance.userNumber,
      'loc_name': instance.locationName,
      'address': instance.address?.toJson(),
      'geo_point': instance.geoPoint?.toJson()
    };
