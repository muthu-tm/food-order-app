part of 'order.dart';

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order()
    ..uuid = json['uuid'] as String ?? ''
    ..storeUUID = json['store_uuid'] as String
    ..userNumber = json['user_number'] as int
    ..totalProducts = json['total_products'] as int
    ..orderImages = (json['order_images'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        []
    ..writtenOrders = json['written_orders'] as String ?? ''
    ..deliveryContact = json['delivery_contact'] as int
    ..customerNotes = json['customer_notes'] as String ?? ''
    ..status = json['status'] as int
    ..isReturnable = json['is_returnable'] as bool
    ..returnDays = json['return_days'] as int
    ..returnedAt = json['returned_at'] as int
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
      'total_products': instance.totalProducts,
      'order_images': instance.orderImages == null ? [] : instance.orderImages,
      'written_orders': instance.writtenOrders ?? '',
      'delivery_contact': instance.deliveryContact,
      'customer_notes': instance.customerNotes ?? '',
      'status': instance.status ?? 0,
      'is_returnable': instance.isReturnable,
      'return_days': instance.returnDays,
      'returned_at': instance.returnedAt,
      'cancelled_at': instance.cancelledAt,
      'amount': instance.amount?.toJson(),
      'delivery': instance.delivery?.toJson(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
