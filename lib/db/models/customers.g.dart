part of 'customers.dart';

Customers _$CustomersFromJson(Map<String, dynamic> json) {
  return Customers()
    ..contactNumber = json['contact_number'] as String
    ..firstName = json['first_name'] as String
    ..lastName = json['last_name'] as String ?? ""
    ..storeName = json['store_name'] as String
    ..storeID = json['store_uuid'] as String
    ..hasCustUnread = json['has_customer_unread'] as bool ?? false
    ..hasStoreUnread = json['has_store_unread'] as bool ?? false
    ..totalAmount = (json['total_amount'] as num)?.toDouble() ?? 0.00
    ..availableBalance = (json['available_balance'] as num)?.toDouble() ?? 0.00
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

Map<String, dynamic> _$CustomersToJson(Customers instance) => <String, dynamic>{
      'contact_number': instance.contactNumber,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'store_name': instance.storeName,
      'store_uuid': instance.storeID,
      'has_customer_unread': instance.hasCustUnread,
      'has_store_unread': instance.hasStoreUnread,
      'total_amount': instance.totalAmount ?? 0.00,
      'available_balance': instance.availableBalance ?? 0.00,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
