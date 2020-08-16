// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryDetails _$DeliveryDetailsFromJson(Map<String, dynamic> json) {
  return DeliveryDetails()
    ..maxDistance = json['max_distance'] as int ?? 5
    ..deliveryFrom = json['delivery_from'] as String
    ..deliveryTill = json['delivery_till'] as String
    ..availableOptions =
        (json['delivery_options'] as List)?.map((e) => e as int)?.toList() ??
            [1, 2]
    ..deliveryCharges02 = json['delivery_charges_02'] as int ?? 0
    ..deliveryCharges25 = json['delivery_charges_25'] as int ?? 0
    ..deliveryChargesPerKM = json['delivery_charges_km'] as int ?? 0;
}

Map<String, dynamic> _$DeliveryDetailsToJson(DeliveryDetails instance) =>
    <String, dynamic>{
      'max_distance': instance.maxDistance ?? 5,
      'delivery_from': instance.deliveryFrom ?? '9:00',
      'delivery_till': instance.deliveryTill ?? '17:00',
      'delivery_options': instance.availableOptions ?? [1, 2],
      'delivery_charges_02': instance.deliveryCharges02 ?? 0,
      'delivery_charges_25': instance.deliveryCharges25 ?? 0,
      'delivery_charges_km': instance.deliveryChargesPerKM ?? 0,
    };
