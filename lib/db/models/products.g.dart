part of 'products.dart';

Products _$ProductsFromJson(Map<String, dynamic> json) {
  return Products()
    ..uuid = json['uuid'] as String
    ..productType = json['product_type'] as String ?? ""
    ..productCategory = json['product_category'] as String ?? ""
    ..productSubCategory = json['product_sub_category'] as String ?? ""
    ..brandName = json['brand_name'] as String ?? ""
    ..name = json['name'] as String ?? ''
    ..rating = (json['rating'] as num)?.toDouble() ?? 0.00
    ..totalRatings = (json['total_ratings'] as num)?.toDouble() ?? 0.00
    ..totalReviews = json['total_reviews'] as int ?? 0
    ..shortDetails = json['short_details'] as String
    ..storeID = json['store_uuid'] as String ?? ''
    ..storeName = json['store_name'] as String ?? ''
    ..orders = json['orders'] as int ?? 0
    ..image = json['image'] as String ?? ''
    ..productImages = (json['product_images'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        []
    ..productDescription = (json['product_description'] as List)
        ?.map((e) => e == null
            ? null
            : ProductDescription.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..variants = (json['variants'] as List)
        ?.map((e) => e == null
            ? null
            : ProductVariants.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..isReturnable = json['is_returnable'] as bool ?? false
    ..returnWithin = json['return_within'] as int ?? 1
    ..isReplaceable = json['is_replaceable'] as bool ?? false
    ..replaceWithin = json['replace_within'] as int ?? 1
    ..isAvailable = json['is_available'] as bool ?? true
    ..isDeliverable = json['is_deliverable'] as bool ?? true
    ..isPopular = json['is_popular'] as bool ?? false
    ..keywords = (json['keywords'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        []
    ..createdAt = json['created_at'] == null
        ? null : (json['created_at'] is Timestamp) ? DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['created_at'] as Timestamp))
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(
              Timestamp(json['created_at']['_seconds'],
                  json['created_at']['_nanoseconds']),
            ),
          )
    ..updatedAt = json['updated_at'] == null
        ? null : (json['updated_at'] is Timestamp) ? DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['updated_at'] as Timestamp))
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(
              Timestamp(json['updated_at']['_seconds'],
                  json['updated_at']['_nanoseconds']),
            ),
          );
}

int _getMillisecondsSinceEpoch(Timestamp ts) {
  return ts.millisecondsSinceEpoch;
}

Map<String, dynamic> _$ProductsToJson(Products instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'product_type': instance.productType ?? "",
      'product_category': instance.productCategory ?? "",
      'product_sub_category': instance.productSubCategory ?? "",
      'brand_name': instance.brandName ?? "",
      'name': instance.name,
      'rating': instance.rating ?? 0.0,
      'total_ratings': instance.totalRatings ?? 0.00,
      'total_reviews': instance.totalReviews ?? 0,
      'short_details': instance.shortDetails,
      'store_uuid': instance.storeID ?? "",
      'store_name': instance.storeName ?? "",
      'orders': instance.orders ?? 0,
      'image': instance.image ?? "",
      'product_images':
          instance.productImages == null ? [] : instance.productImages,
      'product_description':
          instance.productDescription?.map((e) => e?.toJson())?.toList(),
      'variants':
          instance.variants?.map((e) => e?.toJson())?.toList(),
      'is_returnable': instance.isReturnable ?? false,
      'return_within': instance.returnWithin ?? 1,
      'is_replaceable': instance.isReplaceable ?? false,
      'replace_within': instance.replaceWithin ?? 1,
      'is_available': instance.isAvailable ?? true,
      'is_deliverable': instance.isDeliverable ?? true,
      'is_popular': instance.isPopular ?? false,
      'keywords': instance.keywords == null ? [] : instance.keywords,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
