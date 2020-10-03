// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_contacts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreContacts _$StoreContactsFromJson(Map<String, dynamic> json) {
  return StoreContacts()
    ..contactName = json['contact_name'] as String ?? ''
    ..contactNumber = json['contact_number'] as String
    ..emailId = json['email'] as String ?? ''
    ..isVerfied = json['is_verified'] as bool ?? false
    ..isActive = json['is_active'] as bool ?? true;
}

Map<String, dynamic> _$StoreContactsToJson(StoreContacts instance) =>
    <String, dynamic>{
      'contact_name': instance.contactName,
      'contact_number': instance.contactNumber,
      'email': instance.emailId ?? '',
      'is_verified': instance.isVerfied,
      'is_active': instance.isActive ?? true,
    };
