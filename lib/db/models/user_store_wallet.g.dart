// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store_wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStoreWallet _$UserStoreWalletFromJson(Map<String, dynamic> json) {
  return UserStoreWallet()
    ..uuid = json['uuid'] as String ?? ''
    ..storeUUID = json['store_uuid'] as String ?? ''
    ..userNumber = json['user_number'] as int
    ..amount = json['amount'] as int
    ..createdAt = json['created_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['created_at'] as Timestamp))
    ..updatedAt = json['updated_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['updated_at'] as Timestamp));
}

int _getMillisecondsSinceEpoch(Timestamp ts) {
  return ts.millisecondsSinceEpoch;
}

Map<String, dynamic> _$UserStoreWalletToJson(UserStoreWallet instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'store_uuid': instance.storeUUID,
      'user_number': instance.userNumber,
      'amount': instance.amount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
