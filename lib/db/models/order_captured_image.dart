import 'package:json_annotation/json_annotation.dart';

part 'order_captured_image.g.dart';

@JsonSerializable(explicitToJson: true)
class CapturedOrders {
  @JsonKey(name: 'notes')
  String notes;
  @JsonKey(name: 'image')
  String image;
  @JsonKey(name: 'price')
  double price;

  CapturedOrders();

  factory CapturedOrders.fromJson(Map<String, dynamic> json) =>
      _$CapturedOrdersFromJson(json);
  Map<String, dynamic> toJson() => _$CapturedOrdersToJson(this);
}
