part of 'order_delivery.dart';

OrderDelivery _$OrderDeliveryFromJson(Map<String, dynamic> json) {
  return OrderDelivery()
    ..deliveredAt = json['delivered_at'] as int
    ..deliveredBy = json['delivered_by'] as String
    ..deliveredTo = json['delivered_to'] as String
    ..notes = json['notes'] as String ?? ''
    ..geoPoint = json['geo_point'] == null
        ? null
        : GeoPointData.fromJson(json['geo_point'] as Map<String, dynamic>)
    ..address = json['address'] == null
        ? new Address()
        : Address.fromJson(json['address'] as Map<String, dynamic>);
}

Map<String, dynamic> _$OrderDeliveryToJson(OrderDelivery instance) =>
    <String, dynamic>{
      'delivered_at': instance.deliveredAt,
      'delivered_by': instance.deliveredBy,
      'delivered_to': instance.deliveredTo,
      'notes': instance.notes ?? '',
      'geo_point': instance.geoPoint?.toJson(),
      'address': instance.address?.toJson()
    };
