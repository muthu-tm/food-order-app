part of 'order_product.dart';

OrderProduct _$OrderProductFromJson(Map<String, dynamic> json) {
  return OrderProduct()
    ..productID = json['product_uuid'] as String ?? ''
    ..quantity = (json['quantity'] as num)?.toDouble() ?? 0.00
    ..amount = (json['amount'] as num)?.toDouble() ?? 0.00;
}


Map<String, dynamic> _$OrderProductToJson(OrderProduct instance) => <String, dynamic>{
      'product_uuid': instance.productID,
      'quantity': instance.quantity,
      'amount': instance.amount,
    };
