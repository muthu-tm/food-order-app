import 'package:chipchop_buyer/db/models/product_description.dart';
import 'package:chipchop_buyer/db/models/product_variants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
part 'products.g.dart';

@JsonSerializable(explicitToJson: true)
class Products extends Model {
  static CollectionReference _storeCollRef = Model.db.collection("products");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'product_type', nullable: false)
  String productType;
  @JsonKey(name: 'product_category', defaultValue: "")
  String productCategory;
  @JsonKey(name: 'product_sub_category', defaultValue: "")
  String productSubCategory;
  @JsonKey(name: 'brand_name', defaultValue: "")
  String brandName;
  @JsonKey(name: 'name', defaultValue: "")
  String name;
  @JsonKey(name: 'rating', defaultValue: 1)
  double rating;
  @JsonKey(name: 'total_ratings', defaultValue: 1)
  double totalRatings;
  @JsonKey(name: 'total_reviews', defaultValue: 1)
  int totalReviews;
  @JsonKey(name: 'short_details', defaultValue: "")
  String shortDetails;
  @JsonKey(name: 'store_uuid', defaultValue: "")
  String storeID;
  @JsonKey(name: 'store_name', defaultValue: "")
  String storeName;
  @JsonKey(name: 'orders')
  int orders;
  @JsonKey(name: 'image', defaultValue: "")
  String image;
  @JsonKey(name: 'product_images', defaultValue: [""])
  List<String> productImages;
  @JsonKey(name: 'product_description', defaultValue: [""])
  List<ProductDescription> productDescription;
  @JsonKey(name: 'variants', defaultValue: [""])
  List<ProductVariants> variants;
  @JsonKey(name: 'is_returnable', defaultValue: false)
  bool isReturnable;
  @JsonKey(name: 'return_within', defaultValue: false)
  int returnWithin;
  @JsonKey(name: 'is_replaceable', defaultValue: false)
  bool isReplaceable;
  @JsonKey(name: 'replace_within', defaultValue: false)
  int replaceWithin;
  @JsonKey(name: 'is_available')
  bool isAvailable;
  @JsonKey(name: 'is_deliverable')
  bool isDeliverable;
  @JsonKey(name: 'is_popular')
  bool isPopular;
  @JsonKey(name: 'keywords', defaultValue: [""])
  List<String> keywords;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  Products();

  List<String> getSmallProfilePicPath() {
    List<String> paths = [];

    for (var productImage in productImages) {
      if (productImage != null && productImage != "")
        paths.add(productImage.replaceFirst(
            firebase_storage_path, image_kit_path + ik_small_size));
    }

    return paths;
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

  factory Products.fromJson(Map<String, dynamic> json) =>
      _$ProductsFromJson(json);
  Map<String, dynamic> toJson() => _$ProductsToJson(this);

  CollectionReference getCollectionRef() {
    return _storeCollRef;
  }

  DocumentReference getDocumentReference(String uuid) {
    return _storeCollRef.document(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Stream<DocumentSnapshot> streamStoreData() {
    return getDocumentReference(getID()).snapshots();
  }

  String getProductImage() {
    if (image != null && image.trim() != "")
      return image.replaceFirst(
          firebase_storage_path, image_kit_path + ik_medium_size);
    else
      return no_image_placeholder.replaceFirst(
          firebase_storage_path, image_kit_path + ik_medium_size);
  }

  List<String> getProductImages() {
    if (this.productImages.isEmpty) {
      return [
        no_image_placeholder.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size)
      ];
    } else {
      if (this.productImages.first != null && this.productImages.first != "") {
        List<String> images = [];
        for (var img in this.productImages) {
          images.add(img.replaceFirst(
              firebase_storage_path, image_kit_path + ik_medium_size));
        }
        return images;
      } else
        return [
          no_image_placeholder.replaceFirst(
              firebase_storage_path, image_kit_path + ik_medium_size)
        ];
    }
  }

  Stream<QuerySnapshot> streamProducts(String storeID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<List<Products>> getProductsForStore(String storeID) async {
    try {
      List<Products> products = [];
      QuerySnapshot snap = await getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .getDocuments();
      for (var j = 0; j < snap.documents.length; j++) {
        Products _c = Products.fromJson(snap.documents[j].data);
        products.add(_c);
      }

      return products;
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamProductsForCategory(
      String storeID, String categoryID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('product_category', isEqualTo: categoryID)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<List<Products>> getProductsForCategories(
      List<String> ids, String categoryID) async {
    try {
      if (ids.isEmpty) return [];

      List<Products> products = [];

      if (ids.length > 9) {
        int end = 0;
        for (int i = 0; i < ids.length; i = i + 9) {
          if (end + 9 > ids.length)
            end = ids.length;
          else
            end = end + 9;

          QuerySnapshot snap = await getCollectionRef()
              .where('store_uuid', isEqualTo: storeID)
              .where('product_category', isEqualTo: categoryID)
              .getDocuments();
          for (var j = 0; j < snap.documents.length; j++) {
            Products _c = Products.fromJson(snap.documents[j].data);
            products.add(_c);
          }
        }
      } else {
        QuerySnapshot snap = await getCollectionRef()
            .where('store_uuid', isEqualTo: storeID)
            .where('product_category', isEqualTo: categoryID)
            .getDocuments();
        for (var j = 0; j < snap.documents.length; j++) {
          Products _c = Products.fromJson(snap.documents[j].data);
          products.add(_c);
        }
      }

      return products;
    } catch (err) {
      throw err;
    }
  }

  Future<List<Products>> getProductsForSubCategories(
      String storeID, String categoryID, String subCategoryID) async {
    try {
      List<Products> products = [];
      QuerySnapshot snap = await getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('product_category', isEqualTo: categoryID)
          .where('product_sub_category', isEqualTo: subCategoryID)
          .getDocuments();
      for (var j = 0; j < snap.documents.length; j++) {
        Products _c = Products.fromJson(snap.documents[j].data);
        products.add(_c);
      }

      return products;
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamProductsForSubCategory(
      String storeID, String categoryID, String subCategoryID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('product_category', isEqualTo: categoryID)
          .where('product_sub_category', isEqualTo: subCategoryID)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<Products> getByProductID(String uuid) async {
    try {
      DocumentSnapshot snap = await getCollectionRef().document(uuid).get();

      if (snap.exists) return Products.fromJson(snap.data);

      return null;
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamAvailableProducts(String storeID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('is_available', isEqualTo: true)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamUnAvailableProducts(String storeID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('is_available', isEqualTo: false)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamPopularProducts(String storeID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('is_popular', isEqualTo: true)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<List<Products>> getPopularProducts(List<String> ids) async {
    try {
      List<Products> products = [];

      if (ids.length > 9) {
        int end = 0;
        for (int i = 0; i < ids.length; i = i + 9) {
          if (end + 9 > ids.length)
            end = ids.length;
          else
            end = end + 9;

          QuerySnapshot snap = await getCollectionRef()
              .where('store_uuid', whereIn: ids.sublist(i, end))
              .where('is_popular', isEqualTo: true)
              .getDocuments();
          for (var j = 0; j < snap.documents.length; j++) {
            Products _p = Products.fromJson(snap.documents[j].data);
            products.add(_p);
          }
        }
      } else {
        QuerySnapshot snap = await getCollectionRef()
            .where('store_uuid', whereIn: ids)
            .where('is_popular', isEqualTo: true)
            .getDocuments();

        for (var j = 0; j < snap.documents.length; j++) {
          Products _p = Products.fromJson(snap.documents[j].data);
          products.add(_p);
        }
      }

      return products;
    } catch (err) {
      throw err;
    }
  }

  Future<List<Map<String, dynamic>>> getByNameRange(String searchKey) async {
    QuerySnapshot snap = await getCollectionRef()
        // .where('store_uuid', isEqualTo: storeID)
        .where('keywords', arrayContainsAny: searchKey.split(" "))
        .getDocuments();

    List<Map<String, dynamic>> pList = [];
    if (snap.documents.isNotEmpty) {
      snap.documents.forEach((p) {
        pList.add(p.data);
      });
    }

    return pList;
  }
}
