import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
part 'user_activity_tracker.g.dart';

@JsonSerializable(explicitToJson: true)
class UserActivityTracker {
  @JsonKey(name: 'store_uuid', nullable: false)
  String storeID;
  @JsonKey(name: 'store_name', nullable: false)
  String storeName;
  @JsonKey(name: 'product_uuid', nullable: false)
  String productID;
  @JsonKey(name: 'product_name', nullable: false)
  String productName;
  @JsonKey(name: 'image', nullable: false)
  String refImage;
  @JsonKey(name: 'user_number', nullable: false)
  String userID;
  @JsonKey(name: 'user_name', nullable: false)
  String userName;
  @JsonKey(name: 'keywords', nullable: false)
  String keywords;
  @JsonKey(name: 'type', nullable: false)
  int type; // 1 - Store, 2 - Product, 3 - Store Search, 4 - Product Search
  @JsonKey(name: 'created_at', nullable: false)
  int createdAt;
  @JsonKey(name: 'updated_at', nullable: false)
  int updatedAt;

  UserActivityTracker();

  factory UserActivityTracker.fromJson(Map<String, dynamic> json) =>
      _$UserActivityTrackerFromJson(json);
  Map<String, dynamic> toJson() => _$UserActivityTrackerToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return User()
        .getDocumentReference(uuid)
        .collection("user_activity_details");
  }

  String getID() {
    return '${this.createdAt}';
  }

  String getImage() {
    if (this.refImage != null && this.refImage.isNotEmpty) {
      return this.refImage;
    } else
      return noImagePlaceholder;
  }

  Future<void> create() async {
    try {
      this.userID = cachedLocalUser.getID();
      this.userName = cachedLocalUser.getFullName();
      this.createdAt = DateTime.now().millisecondsSinceEpoch;
      this.updatedAt = DateTime.now().millisecondsSinceEpoch;

      if (this.type == 2) {
        QuerySnapshot _qSnap = await getCollectionRef(cachedLocalUser.getID())
            .where('product_uuid', isEqualTo: this.productID)
            .getDocuments();
        if (_qSnap.documents.isNotEmpty) {
          await _qSnap.documents.first.reference.updateData(
              {'updated_at': DateTime.now().millisecondsSinceEpoch});
          return;
        }
      } else if (this.type == 1) {
        QuerySnapshot _qSnap = await getCollectionRef(cachedLocalUser.getID())
            .where('store_uuid', isEqualTo: this.storeID)
            .getDocuments();
        if (_qSnap.documents.isNotEmpty) {
          await _qSnap.documents.first.reference.updateData(
              {'updated_at': DateTime.now().millisecondsSinceEpoch});
          return;
        }
      } else if (this.keywords != null) {
        QuerySnapshot _qSnap = await getCollectionRef(cachedLocalUser.getID())
            .where('keywords', isEqualTo: this.keywords)
            .getDocuments();
        if (_qSnap.documents.isNotEmpty) {
          await _qSnap.documents.first.reference.updateData(
              {'updated_at': DateTime.now().millisecondsSinceEpoch});
          return;
        }
      }

      await getCollectionRef(cachedLocalUser.getID())
          .document(getID())
          .setData(this.toJson());
    } catch (err) {
      print(err);
    }
  }

  Future<List<UserActivityTracker>> getAllActivities() async {
    try {
      QuerySnapshot _qSnap = await getCollectionRef(cachedLocalUser.getID())
          .orderBy('updated_at', descending: true)
          .getDocuments();

      List<UserActivityTracker> _activities = [];
      for (var i = 0; i < _qSnap.documents.length; i++) {
        UserActivityTracker _ua =
            UserActivityTracker.fromJson(_qSnap.documents[i].data);
        _activities.add(_ua);
      }

      return _activities;
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamRecentActivity(List<int> ids) {
    try {
      return getCollectionRef(cachedLocalUser.getID())
          .where('type', whereIn: ids)
          .orderBy('updated_at', descending: true)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<List<UserActivityTracker>> getRecentActivity(List<int> ids) async {
    try {
      QuerySnapshot _qSnap = await getCollectionRef(cachedLocalUser.getID())
          .where('type', whereIn: ids)
          .orderBy('updated_at', descending: true)
          .getDocuments();

      List<UserActivityTracker> _activities = [];
      for (var i = 0; i < _qSnap.documents.length; i++) {
        UserActivityTracker _ua =
            UserActivityTracker.fromJson(_qSnap.documents[i].data);
        _activities.add(_ua);
      }

      return _activities;
    } catch (err) {
      throw err;
    }
  }

  Future<List<UserActivityTracker>> getRecentActivityForStore(
      String storeID, List<int> ids) async {
    try {
      QuerySnapshot _qSnap = await getCollectionRef(cachedLocalUser.getID())
          .where('store_uuid', isEqualTo: storeID)
          .where('type', whereIn: ids)
          .orderBy('updated_at', descending: true)
          .getDocuments();

      List<UserActivityTracker> _activities = [];
      for (var i = 0; i < _qSnap.documents.length; i++) {
        UserActivityTracker _ua =
            UserActivityTracker.fromJson(_qSnap.documents[i].data);
        _activities.add(_ua);
      }

      return _activities;
    } catch (err) {
      throw err;
    }
  }

  Future<void> clearRecentActivity(List<int> ids) async {
    try {
      QuerySnapshot _qSnap = await getCollectionRef(cachedLocalUser.getID())
          .where('type', whereIn: ids)
          .getDocuments();

      for (var i = 0; i < _qSnap.documents.length; i++) {
        await _qSnap.documents[i].reference.delete();
      }
    } catch (err) {
      throw err;
    }
  }
}
