part of 'user_activity_tracker.dart';

UserActivityTracker _$UserActivityTrackerFromJson(Map<String, dynamic> json) {
  return UserActivityTracker()
    ..storeID = json['store_uuid'] as String ?? ''
    ..storeName = json['store_name'] as String ?? ''
    ..productID = json['product_uuid'] as String ?? ''
    ..userID = json['user_number'] as String ?? ''
    ..userName = json['user_name'] as String ?? ''
    ..productName = json['product_name'] as String ?? ''
    ..keywords = json['keywords'] as String ?? ''
    ..type = json['type'] as int
    ..updatedAt = json['updated_at'] as int
    ..createdAt = json['created_at'] as int;
}

Map<String, dynamic> _$UserActivityTrackerToJson(
        UserActivityTracker instance) =>
    <String, dynamic>{
      'store_uuid': instance.storeID ?? '',
      'store_name': instance.storeName ?? '',
      'product_uuid': instance.productID ?? '',
      'product_name': instance.productName ?? '',
      'keywords': instance.keywords ?? '',
      'type': instance.type,
      'user_number': instance.userID,
      'user_name': instance.userName ?? '',
      'updated_at': instance.updatedAt,
      'created_at': instance.createdAt,
    };
