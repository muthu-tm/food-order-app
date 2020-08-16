import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/db/models/order_amount.dart';
import 'package:chipchop_buyer/db/models/order_delivery.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class Order extends Model {
  static CollectionReference _orderCollRef = Model.db.collection("orders");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'store_uuid', nullable: false)
  String storeUUID;
  @JsonKey(name: 'user_number', nullable: false)
  int userNumber;
  @JsonKey(name: 'customer_notes', nullable: true)
  String customerNotes;
  @JsonKey(name: 'status', defaultValue: true)
  int status;
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
    return _orderCollRef;
  }

  DocumentReference getDocumentReference() {
    return _orderCollRef.document(getID());
  }

  String getID() {
    return this.uuid;
  }

  Stream<DocumentSnapshot> streamUserData() {
    return getDocumentReference().snapshots();
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

    await super.add(this.toJson());

    return this;
  }
}
