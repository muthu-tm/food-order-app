// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_user_access.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreUserAccess _$StoreUserAccessFromJson(Map<String, dynamic> json) {
  return StoreUserAccess()
    ..positionName = json['position_name'] as String ?? ''
    ..userNumber = json['user_number'] as String
    ..accessLevel =
        (json['access_level'] as List)?.map((e) => e as int)?.toList();
}

Map<String, dynamic> _$StoreUserAccessToJson(StoreUserAccess instance) =>
    <String, dynamic>{
      'position_name': instance.positionName,
      'user_number': instance.userNumber,
      'access_level': instance.accessLevel,
    };
