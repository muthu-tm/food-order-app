part of 'shopping_cart.dart';

ShoppingCart _$ShoppingCartFromJson(Map<String, dynamic> json) {
  return ShoppingCart()
    ..uuid = json['uuid'] as String
    ..storeID = json['store_uuid'] as String ?? ''
    ..storeName = json['store_name'] as String ?? ''
    ..productID = json['product_uuid'] as String ?? ''
    ..quantity = (json['quantity'] as num)?.toDouble() ?? 1.00
    ..inWishlist = json['in_wishlist'] as bool ?? true
    ..createdAt = json['created_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['created_at'] as Timestamp))
    ..updatedAt = json['updated_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['updated_at'] as Timestamp));
}

int _getMillisecondsSinceEpoch(Timestamp ts) {
  return ts.millisecondsSinceEpoch;
}

Map<String, dynamic> _$ShoppingCartToJson(ShoppingCart instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'store_uuid': instance.storeID ?? "",
      'store_name': instance.storeName ?? "",
      'product_uuid': instance.productID ?? "",
      'quantity': instance.quantity ?? 1.00,
      'in_wishlist': instance.inWishlist ?? true,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
