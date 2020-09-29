import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/controllers/user/user_service.dart';
import './order_amount.dart';
import './order_delivery.dart';
import './order_product.dart';
import 'model.dart';
import 'user.dart';
part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'store_uuid', nullable: false)
  String storeID;
  @JsonKey(name: 'user_number', nullable: false)
  String userNumber;
  @JsonKey(name: 'total_products', nullable: false)
  int totalProducts;
  @JsonKey(name: 'products', nullable: false)
  List<OrderProduct> products;
  @JsonKey(name: 'order_images', defaultValue: [""])
  List<String> orderImages;
  @JsonKey(name: 'written_orders', defaultValue: "")
  String writtenOrders;
  @JsonKey(name: 'customer_notes', defaultValue: "")
  String customerNotes;
  @JsonKey(name: 'status', defaultValue: 0)
  int status;
  @JsonKey(name: 'is_returnable', defaultValue: false)
  bool isReturnable;
  @JsonKey(name: 'return_days', defaultValue: false)
  int returnDays;
  @JsonKey(name: 'returned_at', nullable: true)
  int returnedAt;
  @JsonKey(name: 'cancelled_at', nullable: true)
  int cancelledAt;
  @JsonKey(name: 'delivery')
  OrderDelivery delivery;
  @JsonKey(name: 'amount')
  OrderAmount amount;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  Order();

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  CollectionReference getCollectionRef() {
    return User().getDocumentRef(cachedLocalUser.getID()).collection("orders");
  }

  Query getGroupQuery() {
    return Model.db.collectionGroup('orders');
  }

  DocumentReference getDocumentReference() {
    return getCollectionRef().document(getID());
  }

  String getID() {
    return this.uuid;
  }

  String getStatus() {
    if (this.status == 0) {
      return "Ordered";
    } else if (this.status == 1) {
      return "Confirmed";
    } else if (this.status == 2) {
      return "Cancelled By User";
    } else if (this.status == 3) {
      return "Cancelled By Store";
    } else if (this.status == 4) {
      return "DisPatched";
    } else {
      return "Delivered";
    }
  }

  Future<Order> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    this.status = 0;

    DocumentReference docRef = this.getCollectionRef().document();
    this.uuid = docRef.documentID;

    await docRef.setData(this.toJson());
    return this;
  }

  Stream<QuerySnapshot> streamOrders() {
    return getCollectionRef()
        .orderBy('created_at', descending: true)
        .snapshots();
  }
}
