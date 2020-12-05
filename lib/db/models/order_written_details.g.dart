part of 'order_written_details.dart';

WrittenOrders _$WrittenOrdersFromJson(Map<String, dynamic> json) {
  return WrittenOrders()
    ..quantity = json['quantity'] as int ?? 1
    ..weight = (json['weight'] as num)?.toDouble() ?? 0.00
    ..price = (json['price'] as num)?.toDouble() ?? 0.00
    ..unit = json['unit'] as int ?? 0
    ..name = json['name'] as String ?? "";
}

Map<String, dynamic> _$WrittenOrdersToJson(WrittenOrders instance) =>
    <String, dynamic>{
      'quantity': instance.quantity ?? 1,
      'weight': instance.weight,
      'price': instance.price ?? 0.00,
      'unit': instance.unit ?? 0,
      'name': instance.name ?? "",
    };
