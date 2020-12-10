part of 'order_captured_image.dart';

CapturedOrders _$CapturedOrdersFromJson(Map<String, dynamic> json) {
  return CapturedOrders()
    ..notes = json['notes'] as String ?? ''
    ..image = json['image'] as String
    ..price = (json['price'] as num)?.toDouble() ?? 0.00;
}

Map<String, dynamic> _$CapturedOrdersToJson(CapturedOrders instance) =>
    <String, dynamic>{
      'notes': instance.notes ?? '',
      'image': instance.image,
      'price': instance.price ?? 0.00,
    };
