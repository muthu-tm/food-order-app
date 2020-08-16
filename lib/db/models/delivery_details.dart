import 'package:json_annotation/json_annotation.dart';

part 'delivery_details.g.dart';

@JsonSerializable(explicitToJson: true)
class DeliveryDetails {
  @JsonKey(name: 'max_distance', defaultValue: 5)
  int maxDistance;
  @JsonKey(name: 'delivery_from')
  String deliveryFrom;
  @JsonKey(name: 'delivery_till')
  String deliveryTill;
  @JsonKey(name: 'delivery_options', defaultValue: [1, 2])
  List<int> availableOptions;
  @JsonKey(name: 'delivery_charges_02')
  int deliveryCharges02;
  @JsonKey(name: 'delivery_charges_25')
  int deliveryCharges25;
  @JsonKey(name: 'delivery_charges_km')
  int deliveryChargesPerKM;

  DeliveryDetails();

  factory DeliveryDetails.fromJson(Map<String, dynamic> json) =>
      _$DeliveryDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryDetailsToJson(this);
}
