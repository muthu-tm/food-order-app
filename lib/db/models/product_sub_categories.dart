import 'package:chipchop_buyer/db/models/product_categories.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'product_sub_categories.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductSubCategories {
  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'category_uuid', nullable: false)
  String categoryUUID;
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

  ProductSubCategories();

  List<String> getMediumProfilePicPath() {
    List<String> paths = [];

    for (var productImage in productImages) {
      if (productImage != null && productImage != "")
        paths.add(productImage.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size));
    }

    return paths;
  }

  factory ProductSubCategories.fromJson(Map<String, dynamic> json) =>
      _$ProductSubCategoriesFromJson(json);
  Map<String, dynamic> toJson() => _$ProductSubCategoriesToJson(this);

  CollectionReference getCollectionRef(String typeUUID, String catUUID) {
    return ProductCategories()
        .getDocumentReference(typeUUID, catUUID)
        .collection("product_sub_categories");
  }

  String getID() {
    return this.uuid;
  }

  Future<List<ProductSubCategories>> getSubCategories(
      List<ProductCategories> categories) async {
    List<ProductSubCategories> subCategories = [];

    for (var i = 0; i < categories.length; i++) {
      QuerySnapshot snap =
          await getCollectionRef(categories[i].typeUUID, categories[i].uuid)
              .getDocuments();
      if (snap.documents.isEmpty)
        continue;
      else {
        for (var j = 0; j < snap.documents.length; j++) {
          ProductSubCategories _c =
              ProductSubCategories.fromJson(snap.documents[j].data);
          subCategories.add(_c);
        }
      }
    }

    return subCategories;
  }
}
