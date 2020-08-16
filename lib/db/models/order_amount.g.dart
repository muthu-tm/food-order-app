part of 'order_amount.dart';

OrderAmount _$OrderAmountFromJson(Map<String, dynamic> json) {
  return OrderAmount()
    ..orderAmount = json['order_amount'] as int
    ..deliveryCharge = json['delivery_charge'] as int
    ..couponCode = json['coupon_code'] as String
    ..paidAmount = json['paid_amount'] as int
    ..offerAmount = json['offer_amount'] as int
    ..balAmount = json['bal_amount'] as int;
}

Map<String, dynamic> _$OrderAmountToJson(OrderAmount instance) =>
    <String, dynamic>{
      'order_amount': instance.orderAmount,
      'delivery_charge': instance.deliveryCharge,
      'coupon_code': instance.couponCode,
      'paid_amount': instance.paidAmount,
      'offer_amount': instance.offerAmount,
      'bal_amount': instance.balAmount
    };
