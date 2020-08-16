part of 'order.dart';

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order()
    ..uuid = json['uuid'] as String ?? ''
    ..storeUUID = json['store_uuid'] as String
    ..userNumber = json['user_number'] as int
    ..customerNotes = json['customer_notes'] as String ?? ''
    ..status = json['status'] as int
    ..cancelledAt = json['cancelled_at'] as int
    ..amount = json['amount'] == null
        ? new OrderAmount()
        : OrderAmount.fromJson(json['amount'] as Map<String, dynamic>)
    ..delivery = json['delivery'] == null
        ? new OrderDelivery()
        : OrderDelivery.fromJson(json['delivery'] as Map<String, dynamic>)
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

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'guuid': instance.uuid,
      'store_uuid': instance.storeUUID,
      'user_number': instance.userNumber,
      'customer_notes': instance.customerNotes ?? '',
      'status': instance.status ?? 0,
      'cancelled_at': instance.cancelledAt,
      'amount': instance.amount?.toJson(),
      'delivery': instance.delivery?.toJson(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
