import 'dart:math';

import 'package:chipchop_buyer/db/models/customers.dart';
import 'package:chipchop_buyer/db/models/order_captured_image.dart';
import 'package:chipchop_buyer/db/models/order_status.dart';
import 'package:chipchop_buyer/db/models/order_written_details.dart';
import 'package:chipchop_buyer/db/models/users_shopping_details.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  @JsonKey(name: 'order_id', nullable: false)
  String orderID;
  @JsonKey(name: 'store_name', nullable: false)
  String storeName;
  @JsonKey(name: 'store_uuid', nullable: false)
  String storeID;
  @JsonKey(name: 'user_number', nullable: false)
  String userNumber;
  @JsonKey(name: 'total_products', nullable: false)
  int totalProducts;
  @JsonKey(name: 'products', nullable: false)
  List<OrderProduct> products;
  @JsonKey(name: 'captured_order', defaultValue: [""])
  List<CapturedOrders> capturedOrders;
  @JsonKey(name: 'written_orders', nullable: false)
  List<WrittenOrders> writtenOrders;
  @JsonKey(name: 'customer_notes', defaultValue: "")
  String customerNotes;
  @JsonKey(name: 'store_notes', defaultValue: "")
  String storeNotes;
  @JsonKey(name: 'status')
  int status;
  @JsonKey(name: 'status_details')
  List<OrderStatus> statusDetails;
  @JsonKey(name: 'is_returnable', defaultValue: false)
  bool isReturnable;
  @JsonKey(name: 'return_days', defaultValue: false)
  int returnDays;
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

  DocumentReference getDocumentReference(String id) {
    return getCollectionRef().document(id);
  }

  String getID() {
    return this.uuid;
  }

  String generateOrderID() {
    var _random = new Random();

    return DateFormat('yyMMdd').format(this.createdAt) +
        "-" +
        this.totalProducts.toString() +
        (10 + _random.nextInt(10000 - 10)).toString();
  }

  String getStatus(int status) {
    switch (status) {
      case 0:
        return "Ordered";
        break;
      case 1:
        return "Confirmed";
        break;
      case 2:
        return "Cancelled By User";
        break;
      case 3:
        return "Cancelled By Store";
        break;
      case 4:
        return "DisPatched";
        break;
      case 5:
        return "Delivered";
        break;
      case 6:
        return "Return Requested";
        break;
      case 7:
        return "Return Cancelled";
        break;
      default:
        return "Returned";
    }
  }

  Color getTextColor() {
    switch (status) {
      case 0:
        return Colors.orange;
        break;
      case 1:
      case 4:
        return Colors.blue;
        break;
      case 2:
      case 3:
      case 7:
        return Colors.red;
        break;
      case 5:
        return Colors.green;
        break;
      default:
        return Colors.black;
    }
  }

  Color getBackGround() {
    switch (status) {
      case 0:
        return Colors.orange[100];
        break;
      case 1:
      case 4:
        return Colors.blue[100];
        break;
      case 2:
      case 3:
      case 7:
        return Colors.red[100];
        break;
      case 5:
        return Colors.green[100];
        break;
      default:
        return Colors.black45;
    }
  }

  String getDeliveryType() {
    switch (this.delivery.deliveryType) {
      case 0:
        return "Pickup From Store";
        break;
      case 1:
        return "Instant Delivery";
        break;
      case 2:
        return "Standard Delivery";
        break;
      case 3:
        return "Scheduled Delivery";
        break;
      default:
        return "Standard Delivery";
        break;
    }
  }

  Future<Order> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    this.status = 0;
    this.statusDetails = [
      OrderStatus.fromJson({
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_by': cachedLocalUser.getFullName(),
        'user_number': cachedLocalUser.getID(),
        'status': 0
      })
    ];
    this.orderID = generateOrderID();

    try {
      if (this.amount.walletAmount > 0.00) {
        DocumentReference custDocRef = Model.db
            .collection("stores")
            .document(storeID)
            .collection("customers")
            .document(cachedLocalUser.getID());
        await Model.db.runTransaction((tx) {
          return tx.get(custDocRef).then((doc) async {
            Customers cust = Customers.fromJson(doc.data);

            cust.availableBalance -= this.amount.walletAmount;

            DocumentReference docRef = this.getCollectionRef().document();
            this.uuid = docRef.documentID;
            Model().txCreate(tx, docRef, this.toJson());

            Model().txUpdate(tx, custDocRef, cust.toJson());
          });
        });
      } else {
        DocumentReference docRef = this.getCollectionRef().document();
        this.uuid = docRef.documentID;

        await docRef.setData(this.toJson());
      }

      if (this.products.length > 0) {
        CollectionReference _collRef =
            UserShoppingDetails().getCollectionRef(cachedLocalUser.getID());
        for (var i = 0; i < this.products.length; i++) {
          String _id = '${this.storeID}_${this.products[i].productID}';
          DocumentSnapshot _docSnap = await _collRef.document(_id).get();

          if (_docSnap.exists) {
            UserShoppingDetails _shoppDetails =
                UserShoppingDetails.fromJson(_docSnap.data);
            _shoppDetails.quantity += this.products[i].quantity;
            _shoppDetails.updatedAt = DateTime.now().millisecondsSinceEpoch;
            _docSnap.reference.updateData(_shoppDetails.toJson());
          } else {
            UserShoppingDetails _shoppDetails = UserShoppingDetails();
            _shoppDetails.productID = this.products[i].productID;
            _shoppDetails.productName = this.products[i].productName;
            _shoppDetails.quantity = this.products[i].quantity;
            _shoppDetails.storeID = this.storeID;
            _shoppDetails.userID = cachedLocalUser.getID();
            _shoppDetails.userName = cachedLocalUser.getFullName();
            _shoppDetails.updatedAt = DateTime.now().millisecondsSinceEpoch;

            _docSnap.reference.setData(_shoppDetails.toJson());
          }
        }
      }

      Analytics.sendAnalyticsEvent({
        'type': 'order_create',
        'store_id': storeID,
        'order_id': this.uuid,
      }, 'orders');
    } catch (err) {
      throw err;
    }

    return this;
  }

  Future<void> cancelOrder(String notes) async {
    List<OrderStatus> _newStatus = this.statusDetails;
    _newStatus.add(
      OrderStatus.fromJson({
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_by': cachedLocalUser.getFullName(),
        'user_number': cachedLocalUser.getID(),
        'status': 2
      }),
    );

    await this.getCollectionRef().document(this.getID()).updateData(
      {
        'status_details': _newStatus?.map((e) => e?.toJson())?.toList(),
        'status': 2,
        'updated_at': DateTime.now(),
        'customer_notes': notes
      },
    );
  }

  Stream<QuerySnapshot> streamOrders() {
    return getCollectionRef()
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> streamOrderByID(String id) {
    return getCollectionRef().document(id).snapshots();
  }

  Stream<QuerySnapshot> streamOrdersByStatus(int status) {
    if (status == null) {
      return getCollectionRef()
          .orderBy('created_at', descending: true)
          .snapshots();
    } else {
      return getCollectionRef()
          .where('status', isEqualTo: status)
          .orderBy('created_at', descending: true)
          .snapshots();
    }
  }

  Future<List<Map<String, dynamic>>> getByOrderID(String id) async {
    QuerySnapshot snap = await getCollectionRef()
        .where('order_id', isGreaterThanOrEqualTo: id)
        .getDocuments();

    List<Map<String, dynamic>> oList = [];
    if (snap.documents.isNotEmpty) {
      snap.documents.forEach((order) {
        oList.add(order.data);
      });
    }

    return oList;
  }
}
