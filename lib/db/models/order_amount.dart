import './model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'order_amount.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderAmount extends Model {
  @JsonKey(name: 'order_amount', nullable: false)
  double orderAmount;
  @JsonKey(name: 'delivery_charge', nullable: false)
  double deliveryCharge;
  @JsonKey(name: 'coupon_code', nullable: false)
  String couponCode;
  @JsonKey(name: 'received_amount', nullable: false)
  double receivedAmount;
  @JsonKey(name: 'offer_amount', nullable: true)
  double offerAmount;
  @JsonKey(name: 'wallet_amount', nullable: true)
  double walletAmount;
  @JsonKey(name: 'bal_amount', nullable: true)
  double balAmount;

  OrderAmount();

  factory OrderAmount.fromJson(Map<String, dynamic> json) => _$OrderAmountFromJson(json);
  Map<String, dynamic> toJson() => _$OrderAmountToJson(this);

}
