part of 'order_product.dart';

OrderProduct _$OrderProductFromJson(Map<String, dynamic> json) {
  return OrderProduct()
    ..productID = json['product_uuid'] as String ?? ''
    ..variantID = json['variant_id'] as String ?? '0'
    ..productName = json['product_name'] as String ?? ''
    ..quantity = (json['quantity'] as num)?.toDouble() ?? 0.00
    ..amount = (json['amount'] as num)?.toDouble() ?? 0.00
    ..isReturnable = json['is_returnable'] as bool;
}


Map<String, dynamic> _$OrderProductToJson(OrderProduct instance) => <String, dynamic>{
      'product_uuid': instance.productID,
      'variant_id': instance.variantID ?? "0",
      'product_name': instance.productName ?? "",
      'quantity': instance.quantity,
      'amount': instance.amount,
      'is_returnable': instance.isReturnable,
    };
