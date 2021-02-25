part of 'store_banners.dart';

StoreBanners _$StoreBannersFromJson(Map<String, dynamic> json) {
  return StoreBanners()
    ..uuid = json['uuid'] as String
    ..image = json['image'] as String ?? ''
    ..isActive = json['is_active'] as bool ?? false
    ..isDefault = json['is_default'] as bool ?? false
    ..storeID = json['store_uuid'] as String ?? ""
    ..productID = json['product_uuid'] as String ?? ""
    ..geoPoint = json['geo_point'] == null
        ? null
        : GeoPointData.fromJson(json['geo_point'] as Map<String, dynamic>)
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

Map<String, dynamic> _$StoreBannersToJson(StoreBanners instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'image': instance.image,
      'is_active': instance.isActive ?? false,
      'is_default': instance.isDefault ?? false,
      'store_uuid': instance.storeID ?? "",
      'product_uuid': instance.productID ?? "",
      'geo_point': instance.geoPoint?.toJson(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
