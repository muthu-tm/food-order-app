part of 'products.dart';

Products _$ProductsFromJson(Map<String, dynamic> json) {
  return Products()
    ..uuid = json['uuid'] as String
    ..productType = json['product_type'] as String ?? ""
    ..productCategory = json['product_category'] as String ?? ""
    ..productSubCategory = json['product_sub_category'] as String ?? ""
    ..name = json['name'] as String ?? ''
    ..shortDetails = json['short_details'] as String
    ..storeID = json['store_uuid'] as String ?? ''
    ..productImages = (json['product_images'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        []
    ..weight = (json['weight'] as num)?.toDouble() ?? 0.00
    ..unit = json['unit'] as int ?? 1
    ..originalPrice = (json['org_price'] as num)?.toDouble() ?? 0.00
    ..offer = (json['offer'] as num)?.toDouble() ?? 0.00
    ..currentPrice = (json['current_price'] as num)?.toDouble() ?? 0.00
    ..isAvailable = json['is_available'] as bool ?? true
    ..isDeliverable = json['is_deliverable'] as bool ?? true
    ..isPopular = json['is_popular'] as bool ?? false
    ..keywords = (json['keywords'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        []
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

Map<String, dynamic> _$ProductsToJson(Products instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'product_type': instance.productType ?? "",
      'product_category': instance.productCategory ?? "",
      'product_sub_category': instance.productSubCategory ?? "",
      'name': instance.name,
      'short_details': instance.shortDetails,
      'store_uuid': instance.storeID ?? "",
      'product_images':
          instance.productImages == null ? [] : instance.productImages,
      'weight': instance.weight ?? 0.00,
      'unit': instance.unit ?? 1,
      'org_price': instance.originalPrice ?? 0.00,
      'offer': instance.offer ?? 0.00,
      'current_price': instance.currentPrice ?? 0.00,
      'is_available': instance.isAvailable ?? true,
      'is_deliverable': instance.isDeliverable ?? true,
      'is_popular': instance.isPopular ?? false,
      'keywords': instance.keywords == null ? [] : instance.keywords,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
