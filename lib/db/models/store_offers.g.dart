// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_offers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreOffers _$StoreOffersFromJson(Map<String, dynamic> json) {
  return StoreOffers()
    ..storeLocationID = json['store_loc_id'] as String ?? ''
    ..offerCode = json['offer_code'] as String ?? ''
    ..offerName = json['offer_name'] as String ?? ''
    ..desc = json['desc'] as String ?? ''
    ..offerImage = json['offer_image'] as String ?? ''
    ..activeFrom = json['active_from'] as int
    ..activeTill = json['active_till'] as int
    ..isActive = json['is_active'] as bool ?? true
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

Map<String, dynamic> _$StoreOffersToJson(StoreOffers instance) =>
    <String, dynamic>{
      'store_loc_id': instance.storeLocationID,
      'offer_code': instance.offerCode,
      'offer_name': instance.offerName,
      'desc': instance.desc,
      'offer_image': instance.offerImage ?? "",
      'active_from': instance.activeFrom,
      'active_till': instance.activeTill,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
