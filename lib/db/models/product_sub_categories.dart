import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'product_sub_categories.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductSubCategories extends Model {
  static CollectionReference _subCategoriesCollRef =
      Model.db.collection("product_sub_categories");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'category_id', nullable: false)
  String categoryID;
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

  ProductSubCategories();

  String getSubCategoryImage() {
    if (this.productImages.isEmpty) {
      return noImagePlaceholder.replaceFirst(
          firebase_storage_path, image_kit_path + ik_medium_size);
    } else {
      if (this.productImages.first != null && this.productImages.first != "") {
        return this.productImages.first.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size);
      } else
        return noImagePlaceholder.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size);
    }
  }

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

  CollectionReference getCollectionRef() {
    return _subCategoriesCollRef;
  }

  String getID() {
    return this.uuid;
  }

  Future<List<ProductSubCategories>> getSubCategoriesForCategories(
      String categoryID) async {
    List<ProductSubCategories> categories = [];

    QuerySnapshot snap = await getCollectionRef()
        .where('category_id', isEqualTo: categoryID)
        .getDocuments();
    for (var j = 0; j < snap.documents.length; j++) {
      ProductSubCategories _c =
          ProductSubCategories.fromJson(snap.documents[j].data);
      categories.add(_c);
    }

    return categories;
  }

  Future<List<ProductSubCategories>> getSubCategoriesForIDs(
      String categoryID, List<String> ids) async {
    // handle empty params
    if (ids.isEmpty) return [];

    List<ProductSubCategories> categories = [];

    if (ids.length > 9) {
      int end = 0;
      for (int i = 0; i < ids.length; i = i + 9) {
        if (end + 9 > ids.length)
          end = ids.length;
        else
          end = end + 9;

        QuerySnapshot snap = await getCollectionRef()
            .where('category_id', isEqualTo: categoryID)
            .where('uuid', whereIn: ids.sublist(i, end))
            .getDocuments();
        for (var j = 0; j < snap.documents.length; j++) {
          ProductSubCategories _c =
              ProductSubCategories.fromJson(snap.documents[j].data);
          categories.add(_c);
        }
      }
    } else {
      QuerySnapshot snap = await getCollectionRef()
          .where('category_id', isEqualTo: categoryID)
          .where('uuid', whereIn: ids)
          .getDocuments();
      for (var j = 0; j < snap.documents.length; j++) {
        ProductSubCategories _c =
            ProductSubCategories.fromJson(snap.documents[j].data);
        categories.add(_c);
      }
    }

    categories.sort((a, b) => a.name.compareTo(b.name));

    return categories;
  }

  Future<List<ProductSubCategories>> getSearchables() async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('show_in_search', isEqualTo: true)
          .getDocuments();

      List<ProductSubCategories> categories = [];
      if (snap.documents.isNotEmpty) {
        for (var i = 0; i < snap.documents.length; i++) {
          ProductSubCategories _c =
              ProductSubCategories.fromJson(snap.documents[i].data);
          categories.add(_c);
        }
      }

      return categories;
    } catch (err) {
      throw err;
    }
  }
}
