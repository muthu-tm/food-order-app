// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryDetails _$DeliveryDetailsFromJson(Map<String, dynamic> json) {
  return DeliveryDetails()
    ..minOrderAmount = (json['min_order_amount'] as num)?.toDouble() ?? 100
    ..maxOrderAmount = (json['max_order_amount'] as num)?.toDouble() ?? 10000
    ..maxDistance = json['max_distance'] as int ?? 5
    ..deliveryFrom = json['delivery_from'] as String
    ..deliveryTill = json['delivery_till'] as String
    ..availableOptions =
        (json['delivery_options'] as List)?.map((e) => e as int)?.toList() ??
            [1, 2]
    ..deliveryCharges02 =
        (json['delivery_charges_02'] as num)?.toDouble() ?? 0.00
    ..deliveryCharges05 =
        (json['delivery_charges_05'] as num)?.toDouble() ?? 0.00
    ..deliveryCharges10 =
        (json['delivery_charges_10'] as num)?.toDouble() ?? 0.00
    ..deliveryChargesMax =
        (json['delivery_charges_max'] as num)?.toDouble() ?? 0.00
    ..instantDelivery = json['instant_delivery_fee'] as int ?? 0
    ..sameDayDelivery = json['same_day_delivery_fee'] as int ?? 0
    ..scheduledDelivery = json['scheduled_delivery_fee'] as int ?? 0;
}

Map<String, dynamic> _$DeliveryDetailsToJson(DeliveryDetails instance) =>
    <String, dynamic>{
      'min_order_amount': instance.minOrderAmount ?? 100,
      'max_order_amount': instance.minOrderAmount ?? 10000,
      'max_distance': instance.maxDistance ?? 5,
      'delivery_from': instance.deliveryFrom ?? '9:00',
      'delivery_till': instance.deliveryTill ?? '17:00',
      'delivery_options': instance.availableOptions ?? [1, 2],
      'delivery_charges_02': instance.deliveryCharges02 ?? 0.00,
      'delivery_charges_05': instance.deliveryCharges05 ?? 0.00,
      'delivery_charges_10': instance.deliveryCharges10 ?? 0.00,
      'delivery_charges_max': instance.deliveryChargesMax ?? 0.00,
      'instant_delivery_fee': instance.instantDelivery ?? 50,
      'same_day_delivery_fee': instance.sameDayDelivery ?? 0,
      'scheduled_delivery_fee': instance.scheduledDelivery ?? -50,
    };
