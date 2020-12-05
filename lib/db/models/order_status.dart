import 'package:json_annotation/json_annotation.dart';

part 'order_status.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderStatus {
  @JsonKey(name: 'created_at', defaultValue: 0)
  int createdAt;
  @JsonKey(name: 'status')
  int status;
  @JsonKey(name: 'user_number')
  String userNumber;
  @JsonKey(name: 'updated_by')
  String updatedBy;

  OrderStatus();

  factory OrderStatus.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusFromJson(json);
  Map<String, dynamic> toJson() => _$OrderStatusToJson(this);
}
