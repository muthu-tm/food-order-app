part of 'store.dart';

Store _$StoreFromJson(Map<String, dynamic> json) {
  return Store()
    ..uuid = json['uuid'] as String
    ..name = json['store_name'] as String ?? ''
    ..shortDetails = json['short_details'] as String ?? ''
    ..ownedBy = json['owned_by'] as String
    ..availProducts =
        (json['avail_products'] as List)?.map((e) => e as String)?.toList()
    ..availProductCategories = (json['avail_product_categories'] as List)
        ?.map((e) => e as String)
        ?.toList()
    ..availProductSubCategories = (json['avail_product_sub_categories'] as List)
        ?.map((e) => e as String)
        ?.toList()
    ..workingDays =
        (json['working_days'] as List)?.map((e) => e as int)?.toList()
    ..activeFrom = json['active_from'] as String
    ..activeTill = json['active_till'] as String
    ..address = json['address'] == null
        ? new Address()
        : Address.fromJson(json['address'] as Map<String, dynamic>)
    ..geoPoint = json['geo_point'] == null
        ? null
        : GeoPointData.fromJson(json['geo_point'] as Map<String, dynamic>)
    ..isActive = json['is_active'] as bool ?? true
    ..deliverAnywhere = json['deliver_anywhere'] as bool ?? false
    ..contacts = (json['contacts'] as List)
        ?.map((e) => e == null
            ? null
            : StoreContacts.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..image = json['image'] as String ?? ''
    ..storeImages = (json['store_images'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        []
    ..users = (json['users'] as List)?.map((e) => e == null ? null : e as String)?.toList() ??
        []
    ..upiID = json['upi'] as String ?? ""
    ..walletNumber = json['wallet_number'] as String ?? ""
    ..availablePayments = (json['avail_payments'] as List)
            ?.map((e) => e == null ? null : e as int)
            ?.toList() ??
        [0]
    ..usersAccess = (json['users_access'] as List)
        ?.map((e) => e == null
            ? null
            : StoreUserAccess.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..deliveryDetails = json['delivery'] == null
        ? new DeliveryDetails()
        : DeliveryDetails.fromJson(json['delivery'] as Map<String, dynamic>)
    ..keywords =
        (json['keywords'] as List)?.map((e) => e == null ? null : e as String)?.toList() ?? []
    ..createdAt = json['created_at'] == null
        ? null
        : (json['created_at'] is Timestamp)
            ? DateTime.fromMillisecondsSinceEpoch(_getMillisecondsSinceEpoch(json['created_at'] as Timestamp))
            : DateTime.fromMillisecondsSinceEpoch(
                _getMillisecondsSinceEpoch(
                  Timestamp(json['created_at']['_seconds'],
                      json['created_at']['_nanoseconds']),
                ),
              )
    ..updatedAt = json['updated_at'] == null
        ? null
        : (json['updated_at'] is Timestamp)
            ? DateTime.fromMillisecondsSinceEpoch(_getMillisecondsSinceEpoch(json['updated_at'] as Timestamp))
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

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'store_name': instance.name,
      'short_details': instance.shortDetails,
      'owned_by': instance.ownedBy,
      'avail_products': instance.availProducts,
      'avail_product_categories': instance.availProductCategories,
      'avail_product_sub_categories': instance.availProductSubCategories,
      'working_days': instance.workingDays,
      'active_from': instance.activeFrom,
      'active_till': instance.activeTill,
      'address': instance.address?.toJson(),
      'geo_point': instance.geoPoint?.toJson(),
      'is_active': instance.isActive,
      'deliver_anywhere': instance.deliverAnywhere,
      'image': instance.image ?? "",
      'store_images': instance.storeImages == null ? [] : instance.storeImages,
      'contacts': instance.contacts?.map((e) => e?.toJson())?.toList(),
      'users': instance.users == null ? [] : instance.users,
      'wallet_number': instance.walletNumber,
      'upi': instance.upiID,
      'avail_payments':
          instance.availablePayments == null ? [0] : instance.availablePayments,
      'users_access': instance.usersAccess?.map((e) => e?.toJson())?.toList(),
      'delivery': instance.deliveryDetails?.toJson(),
      'keywords': instance.keywords == null ? [] : instance.keywords,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
