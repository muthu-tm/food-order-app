import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_buyer/db/models/model.dart';

part 'product_types.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductTypes extends Model {
  static CollectionReference _storeCollRef =
      Model.db.collection("product_types");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'name', defaultValue: "")
  String name;
  @JsonKey(name: 'show_in_dashboard', defaultValue: "")
  bool showInDashboard;
  @JsonKey(name: 'dashboard_order')
  int dashboardOrder;
  @JsonKey(name: 'short_details', defaultValue: "")
  String shortDetails;
  @JsonKey(name: 'product_images', defaultValue: [""])
  List<String> productImages;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ProductTypes();

  List<String> getMediumProfilePicPath() {
    List<String> paths = [];

    for (var productImage in productImages) {
      if (productImage != null && productImage != "")
        paths.add(productImage.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size));
    }

    return paths;
  }

  factory ProductTypes.fromJson(Map<String, dynamic> json) =>
      _$ProductTypesFromJson(json);
  Map<String, dynamic> toJson() => _$ProductTypesToJson(this);

  CollectionReference getCollectionRef() {
    return _storeCollRef;
  }

  DocumentReference getDocumentReference(String uuid) {
    return _storeCollRef.doc(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Stream<QuerySnapshot> streamProductTypes() {
    return getCollectionRef().snapshots();
  }

  Future<List<ProductTypes>> getProductTypes() async {
    try {
      QuerySnapshot snap = await getCollectionRef().get();

      List<ProductTypes> types = [];
      if (snap.docs.isNotEmpty) {
        for (var i = 0; i < snap.docs.length; i++) {
          ProductTypes _s = ProductTypes.fromJson(snap.docs[i].data());
          types.add(_s);
        }
      }

      return types;
    } catch (err) {
      throw err;
    }
  }

  Future<List<ProductTypes>> getDashboardTypes() async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('show_in_dashboard', isEqualTo: true)
          .orderBy('dashboard_order')
          .get();

      List<ProductTypes> types = [];
      if (snap.docs.isNotEmpty) {
        for (var i = 0; i < snap.docs.length; i++) {
          ProductTypes _s = ProductTypes.fromJson(snap.docs[i].data());
          types.add(_s);
        }
      }

      return types;
    } catch (err) {
      throw err;
    }
  }
}
