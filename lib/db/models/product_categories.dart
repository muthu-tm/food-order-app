import 'package:chipchop_buyer/db/models/product_types.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'product_sub_categories.dart';
part 'product_categories.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductCategories {
  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'type_uuid', nullable: false)
  String typeUUID;
  @JsonKey(name: 'name', defaultValue: "")
  String name;
  @JsonKey(name: 'short_details', defaultValue: "")
  String shortDetails;
  @JsonKey(name: 'product_images', defaultValue: [""])
  List<String> productImages;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ProductCategories();

  List<String> getMediumProfilePicPath() {
    List<String> paths = [];

    for (var productImage in productImages) {
      if (productImage != null && productImage != "")
        paths.add(productImage.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size));
    }

    return paths;
  }

  factory ProductCategories.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoriesFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCategoriesToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return ProductTypes()
        .getDocumentReference(uuid)
        .collection("product_categories");
  }

  DocumentReference getDocumentReference(String typeUUID, String uuid) {
    return getCollectionRef(typeUUID).document(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Future<List<ProductCategories>> getCategoriesForTypes(
      List<String> types) async {
    List<ProductCategories> categories = [];

    for (var i = 0; i < types.length; i++) {
      QuerySnapshot snap = await getCollectionRef(types[i]).getDocuments();
      if (snap.documents.isEmpty)
        continue;
      else {
        for (var j = 0; j < snap.documents.length; j++) {
          ProductCategories _c = ProductCategories.fromJson(snap.documents[j].data);
          categories.add(_c);
        }
      }
    }

    return categories;
  }

  Future<List<ProductSubCategories>> getSubCategories(String typeUUId, String cuuid) async {
    try {
      QuerySnapshot snap = await getDocumentReference(typeUUId, cuuid)
              .collection("product_sub_categories").getDocuments();

      List<ProductSubCategories> _c = [];
      if (snap.documents.isNotEmpty) {
        for (var i = 0; i < snap.documents.length; i++) {
          ProductSubCategories _s = ProductSubCategories.fromJson(snap.documents[i].data);
          _c.add(_s);
        }
      }

      return _c;
    } catch (err) {
      throw err;
    }
  }
}
