import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customers.g.dart';

@JsonSerializable(explicitToJson: true)
class Customers {
  @JsonKey(name: 'contact_number', nullable: false)
  String contactNumber;
  @JsonKey(name: 'first_name', nullable: false)
  String firstName;
  @JsonKey(name: 'last_name', nullable: false)
  String lastName;
  @JsonKey(name: 'store_name', nullable: false)
  String storeName;
  @JsonKey(name: 'store_uuid', nullable: false)
  String storeID;
  @JsonKey(name: 'total_amount', defaultValue: 0)
  double totalAmount;
  @JsonKey(name: 'available_balance', defaultValue: 0)
  double availableBalance;
  @JsonKey(name: 'has_customer_unread')
  bool hasCustUnread;
  @JsonKey(name: 'has_store_unread')
  bool hasStoreUnread;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  Customers();

  factory Customers.fromJson(Map<String, dynamic> json) =>
      _$CustomersFromJson(json);
  Map<String, dynamic> toJson() => _$CustomersToJson(this);

  CollectionReference getCollectionRef(String storeID) {
    return Model.db
        .collection("stores")
        .document(storeID)
        .collection("customers");
  }

  Future<void> storeCreateCustomer(String storeID, String storeName) async {
    DocumentSnapshot custSnap =
        await getCollectionRef(storeID).document(cachedLocalUser.getID()).get();

    if (custSnap.exists) return;

    if (storeName == "") {
      DocumentSnapshot docSnap =
          await Model.db.collection("stores").document(storeID).get();

      if (docSnap.exists) {
        storeName = docSnap.data['store_name'];
      }
    }

    await getCollectionRef(storeID).document(cachedLocalUser.getID()).setData({
      'contact_number': cachedLocalUser.getID(),
      'first_name': cachedLocalUser.firstName,
      'last_name': cachedLocalUser.lastName,
      'store_name': storeName,
      'has_store_unread': false,
      'has_customer_unread': false,
      'store_uuid': storeID,
      'total_amount': 0.00,
      'available_balance': 0.00,
      'created_at': DateTime.now(),
      'updated_at': DateTime.now()
    });
  }

  Stream<QuerySnapshot> streamUsersStores() {
    return Model.db
        .collectionGroup("customers")
        .where('contact_number', isEqualTo: cachedLocalUser.getID())
        .snapshots();
  }

  Stream<DocumentSnapshot> streamUsersData(String storeID) {
    return getCollectionRef(storeID).document(cachedLocalUser.getID()).snapshots();
  }
}
