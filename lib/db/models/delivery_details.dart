import 'package:json_annotation/json_annotation.dart';

part 'delivery_details.g.dart';

@JsonSerializable(explicitToJson: true)
class DeliveryDetails {
  @JsonKey(name: 'min_order_amount', defaultValue: 100)
  double minOrderAmount;
  @JsonKey(name: 'max_order_amount', defaultValue: 10000)
  double maxOrderAmount;
  @JsonKey(name: 'max_distance', defaultValue: 5)
  int maxDistance;
  @JsonKey(name: 'delivery_from')
  String deliveryFrom;
  @JsonKey(name: 'delivery_till')
  String deliveryTill;
  @JsonKey(name: 'delivery_options', defaultValue: [1, 2])
  List<int> availableOptions; // 0 - Pickup from Store, 1 - Instant delivery, 2 - Same-Day delivery, 3 - Scheduled delivery
  @JsonKey(name: 'delivery_charges_02')
  double deliveryCharges02;
  @JsonKey(name: 'delivery_charges_05')
  double deliveryCharges05;
  @JsonKey(name: 'delivery_charges_10')
  double deliveryCharges10;
  @JsonKey(name: 'delivery_charges_max')
  double deliveryChargesMax;
  @JsonKey(name: 'instant_delivery_fee')
  int instantDelivery;
  @JsonKey(name: 'same_day_delivery_fee')
  int sameDayDelivery;
  @JsonKey(name: 'scheduled_delivery_fee')
  int scheduledDelivery;

  DeliveryDetails();

  factory DeliveryDetails.fromJson(Map<String, dynamic> json) =>
      _$DeliveryDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryDetailsToJson(this);
}
