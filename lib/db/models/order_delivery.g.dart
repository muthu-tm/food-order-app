part of 'order_delivery.dart';

OrderDelivery _$OrderDeliveryFromJson(Map<String, dynamic> json) {
  return OrderDelivery()
    ..deliveryType = json['delivery_type'] as int
    ..scheduledDate = json['scheduled_date'] as int
    ..expectedAt = json['expected_at'] as int
    ..deliveryCharge = (json['delivery_charge'] as num)?.toDouble() ?? 0.00
    ..deliveryContact = json['delivery_contact'] as String
    ..deliveredAt = json['delivered_at'] as int
    ..deliveredBy = json['delivered_by'] as String
    ..deliveredTo = json['delivered_to'] as String
    ..notes = json['notes'] as String ?? ''
    ..userLocation = json['user_location'] == null
        ? null
        : UserLocations.fromJson(json['user_location'] as Map<String, dynamic>);
}

Map<String, dynamic> _$OrderDeliveryToJson(OrderDelivery instance) =>
    <String, dynamic>{
      'delivery_type': instance.deliveryType,
      'scheduled_date': instance.scheduledDate,
      'expected_at': instance.expectedAt,
      'delivery_charge': instance.deliveryCharge,
      'delivery_contact': instance.deliveryContact,
      'delivered_at': instance.deliveredAt,
      'delivered_by': instance.deliveredBy,
      'delivered_to': instance.deliveredTo,
      'notes': instance.notes ?? '',
      'user_location': instance.userLocation?.toJson(),
    };
