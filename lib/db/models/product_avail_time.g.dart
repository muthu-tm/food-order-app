part of 'product_avail_time.dart';

ProductAvailTime _$ProductAvailTimeFromJson(Map<String, dynamic> json) {
  return ProductAvailTime()
    ..activeFrom = json['active_from'] as String ?? "0:0"
    ..activeTill = json['active_till'] as String ?? "0:0"
    ..id = json['id'] as String ?? "0";
}

Map<String, dynamic> _$ProductAvailTimeToJson(ProductAvailTime instance) =>
    <String, dynamic>{
      'id': instance.id ?? "0",
      'active_from': instance.activeFrom ?? null,
      'active_till': instance.activeTill ?? null,
    };
