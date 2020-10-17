import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'product_categories.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductCategories extends Model {
  static CollectionReference _categoriesCollRef =
      Model.db.collection("product_categories");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'type_uuid', nullable: false)
  List<String> typeID;
  @JsonKey(name: 'name', defaultValue: "")
  String name;
  @JsonKey(name: 'short_details', defaultValue: "")
  String shortDetails;
  @JsonKey(name: 'product_images', defaultValue: [""])
  List<String> productImages;
  @JsonKey(name: 'show_in_search', defaultValue: false)
  bool showInSearch;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ProductCategories();

  String getCategoryImage() {
    if (this.productImages.isEmpty) {
      return no_image_placeholder.replaceFirst(
          firebase_storage_path, image_kit_path + ik_medium_size);
    } else {
      if (this.productImages.first != null && this.productImages.first != "") {
        return this.productImages.first.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size);
      } else
        return no_image_placeholder.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size);
    }
  }

  factory ProductCategories.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoriesFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCategoriesToJson(this);

  CollectionReference getCollectionRef() {
    return _categoriesCollRef;
  }

  DocumentReference getDocumentReference(String uuid) {
    return getCollectionRef().document(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Future<List<ProductCategories>> getCategoriesForTypes(
      List<String> types) async {
    // handle empty params
    if (types.isEmpty) return [];

    List<ProductCategories> categories = [];

    QuerySnapshot snap = await getCollectionRef()
        .where('type_uuid', arrayContainsAny: types)
        .getDocuments();
    for (var j = 0; j < snap.documents.length; j++) {
      ProductCategories _c = ProductCategories.fromJson(snap.documents[j].data);
      categories.add(_c);
    }
    return categories;
  }

  Future<List<ProductCategories>> getCategoriesForIDs(List<String> ids) async {
    // handle empty params
    if (ids.isEmpty) return [];

    List<ProductCategories> categories = [];

    try {
      QuerySnapshot snap =
          await getCollectionRef().where('uuid', whereIn: ids).getDocuments();
      for (var j = 0; j < snap.documents.length; j++) {
        ProductCategories _c =
            ProductCategories.fromJson(snap.documents[j].data);
        categories.add(_c);
      }

      return categories;
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<List<ProductCategories>> getSearchables() async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('show_in_search', isEqualTo: true)
          .getDocuments();

      List<ProductCategories> categories = [];
      if (snap.documents.isNotEmpty) {
        for (var i = 0; i < snap.documents.length; i++) {
          ProductCategories _s =
              ProductCategories.fromJson(snap.documents[i].data);
          categories.add(_s);
        }
      }

      return categories;
    } catch (err) {
      throw err;
    }
  }
}
