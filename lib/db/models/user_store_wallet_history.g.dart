part of 'user_store_wallet_history.dart';

UserStoreWalletHistory _$UserStoreWalletHistoryFromJson(
    Map<String, dynamic> json) {
  return UserStoreWalletHistory()
    ..id = json['id'] as String ?? ''
    ..type = json['type'] as int
    ..details = json['details'] as String ?? ''
    ..storeUUID = json['store_uuid'] as String ?? ''
    ..addedBy = json['added_by'] as String
    ..userNumber = json['user_number'] as String
    ..amount = (json['amount'] as num)?.toDouble() ?? 0.00
    ..createdAt = json['created_at'] as int;
}

Map<String, dynamic> _$UserStoreWalletHistoryToJson(
        UserStoreWalletHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'details': instance.details,
      'store_uuid': instance.storeUUID,
      'added_by': instance.addedBy,
      'user_number': instance.userNumber,
      'amount': instance.amount ?? 0.00,
      'created_at': instance.createdAt,
    };
