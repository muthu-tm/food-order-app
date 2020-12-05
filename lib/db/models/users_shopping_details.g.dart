part of 'users_shopping_details.dart';

UserShoppingDetails _$UserShoppingDetailsFromJson(Map<String, dynamic> json) {
  return UserShoppingDetails()
    ..storeID = json['store_uuid'] as String ?? ''
    ..productID = json['product_uuid'] as String ?? ''
    ..userID = json['user_number'] as String ?? ''
    ..userName = json['user_name'] as String ?? ''
    ..quantity = (json['quantity'] as num)?.toDouble() ?? 0.00
    ..productName = json['product_name'] as String ?? ''
    ..updatedAt = json['updated_at'] as int;
}

Map<String, dynamic> _$UserShoppingDetailsToJson(
        UserShoppingDetails instance) =>
    <String, dynamic>{
      'store_uuid': instance.storeID,
      'product_uuid': instance.productID,
      'quantity': instance.quantity,
      'user_number': instance.userID,
      'user_name': instance.userName,
      'product_name': instance.productName,
      'updated_at': instance.updatedAt,
    };
