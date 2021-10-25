part of 'product_variants.dart';

ProductVariants _$ProductVarientsFromJson(Map<String, dynamic> json) {
  return ProductVariants()
    ..originalPrice = (json['org_price'] as num)?.toDouble() ?? 0.00
    ..offer = (json['offer'] as num)?.toDouble() ?? 0.00
    ..currentPrice = (json['current_price'] as num)?.toDouble() ?? 0.00
    ..weight = (json['weight'] as num)?.toDouble() ?? 0.00
    ..unit = json['unit'] as int ?? 1
    ..availableUnit = json['available_unit'] as int ?? 1
    ..quantity = json['quantity'] as int ?? 0
    ..isAvailable = json['is_available'] as bool ?? true
    ..availableTimes = (json['available_times'] as List)
        ?.map((e) => e == null
            ? ProductAvailTime.fromJson({'id': "0"})
            : ProductAvailTime.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..id = json['id'] as String ?? "0";
}

Map<String, dynamic> _$ProductVarientsToJson(ProductVariants instance) =>
    <String, dynamic>{
      'id': instance.id ?? "0",
      'org_price': instance.originalPrice ?? 0.00,
      'is_available': instance.isAvailable ?? true,
      'offer': instance.offer ?? 0.00,
      'current_price': instance.currentPrice ?? 0.00,
      'weight': instance.weight ?? 0.00,
      'unit': instance.unit ?? 1,
      'available_unit': instance.availableUnit ?? 1,
      'available_times':
          instance.availableTimes?.map((e) => e?.toJson())?.toList(),
      'quantity': instance.quantity ?? 1,
    };
