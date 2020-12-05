part of 'order_status.dart';

OrderStatus _$OrderStatusFromJson(Map<String, dynamic> json) {
  return OrderStatus()
    ..status = json['status'] as int ?? 0
    ..createdAt = json['created_at'] as int
    ..userNumber = json['user_number'] as String ?? ""
    ..updatedBy = json['updated_by'] as String ?? "";
}

Map<String, dynamic> _$OrderStatusToJson(OrderStatus instance) =>
    <String, dynamic>{
      'status': instance.status ?? 0,
      'created_at': instance.createdAt ?? "",
      'user_number': instance.userNumber ?? "",
      'updated_by': instance.updatedBy ?? "",
    };
