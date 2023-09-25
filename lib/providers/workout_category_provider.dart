import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model/default_response.dart';
import '../utils/file_upload_utils.dart';

class WorkoutCategoryProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> workoutCategoryItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allWorkoutCategoryItem =
      <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> myWorkoutCategoryItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> popularWorkoutCategories =
      <QueryDocumentSnapshot>[];
  String lastCreatedBy = "";

  Future<DefaultResponse> addWorkoutCategory(
      {required String createdBy,
      required String workoutCategoryTitle,
      File? categoryImage}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableWorkoutCategory)
        .where(keyWorkoutCategoryTitle, isEqualTo: workoutCategoryTitle)
        .where(keyCreatedBy, isEqualTo: createdBy)
        .get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message =
          AppLocalizations.of(navigatorKey.currentContext!)!
              .workout_category_already_exist;
      return defaultResponse;
    }

    String profileURL = "";
    if (categoryImage != null) {
      profileURL = await FileUploadUtils().uploadImage(
          folderName: folderWorkoutCategory, fileImage: categoryImage);
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyCreatedBy: createdBy,
      keyWorkoutCategoryTitle: workoutCategoryTitle,
      keyProfile: profileURL
    };

    await FirebaseFirestore.instance
        .collection(tableWorkoutCategory)
        .doc()
        .set(bodyMap)
        .whenComplete(
      () {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message =
            AppLocalizations.of(navigatorKey.currentContext!)!
                .workout_category_added_successfully;
        getWorkoutCategoryList(
          isRefresh: true,
          createdBy: createdBy,
        );
      },
    ).catchError(
      (e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
      },
    );
    return defaultResponse;
  }

  Future<void> deleteCategory({required categoryId}) async {
    await FirebaseFirestore.instance
        .collection(tableWorkoutCategory)
        .doc(categoryId)
        .delete();
    int index =
        workoutCategoryItem.indexWhere((element) => element.id == categoryId);
    if (index != -1) workoutCategoryItem.removeAt(index);
    Fluttertoast.showToast(
        msg: AppLocalizations.of(navigatorKey.currentContext!)!
            .workout_category_deleted_successfully,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    notifyListeners();
  }

  Future<DefaultResponse> updateCategory(
      {required String createdBy,
      required categoryId,
      required title,
      required File? profile,
      required String? imageUrl}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableWorkoutCategory)
        .where(keyWorkoutCategoryTitle, isEqualTo: title)
        .get();
    var currentDoc = query.docs.where((element) => element.id == categoryId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message =
          AppLocalizations.of(navigatorKey.currentContext!)!
              .workout_category_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (profile != null && imageUrl != null) {
      profileURL = await FileUploadUtils().uploadAndUpdateImage(
          folderName: folderWorkoutCategory,
          fileImage: profile,
          oldUrl: imageUrl);
    } else if (profile != null) {
      profileURL = await FileUploadUtils()
          .uploadImage(folderName: folderWorkoutCategory, fileImage: profile);
    } else if (imageUrl != null) {
      profileURL = imageUrl;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyCreatedBy: createdBy,
      keyWorkoutCategoryTitle: title,
      keyProfile: profileURL
    };

    await FirebaseFirestore.instance
        .collection(tableWorkoutCategory)
        .doc(categoryId)
        .update(
          bodyMap,
        )
        .whenComplete(
      () {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message =
            AppLocalizations.of(navigatorKey.currentContext!)!
                .workout_category_updated_successfully;
        getWorkoutCategoryList(isRefresh: true, createdBy: createdBy);
      },
    ).catchError(
      (e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
      },
    );
    return defaultResponse;
  }

  Future<void> getWorkoutCategoryList(
      {bool isRefresh = false,
      String searchText = "",
      required String createdBy}) async {
    if (isRefresh) {
      workoutCategoryItem.clear();
    }
    try {
      if (workoutCategoryItem.isEmpty) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(tableWorkoutCategory)
            .orderBy(keyWorkoutCategoryTitle)
            .where(keyCreatedBy, isEqualTo: createdBy)
            .get();
        workoutCategoryItem.addAll(querySnapshot.docs);
        debugPrint('workoutCategoryItem Size : ${workoutCategoryItem.length}');
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<void> getPopularWorkoutCategoryList(
      {bool isRefresh = false, String searchText = ""}) async {
    if (isRefresh) {
      popularWorkoutCategories.clear();
    }
    try {
      if (popularWorkoutCategories.isEmpty) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(tableWorkoutCategory)
            .orderBy(keyWorkoutCategoryTitle)
            .limit(5)
            .get();
        popularWorkoutCategories.addAll(querySnapshot.docs);
        debugPrint('workoutCategoryItem Size : ${workoutCategoryItem.length}');
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<DocumentSnapshot> getCategoryById({required categoryId}) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection(tableWorkoutCategory)
        .doc(categoryId)
        .get();
    return querySnapshot;
  }

  Future<void> getSearchMyWorkoutCategory(
      {bool isRefresh = false,
      required List<String> workoutCategoryIdList,
      String searchText = "",
      required String createdBy}) async {
    if (isRefresh) {
      myWorkoutCategoryItem.clear();
      allWorkoutCategoryItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allWorkoutCategoryItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableWorkoutCategory)
              .where(keyCreatedBy, isEqualTo: createdBy)
              .get();
          if (allWorkoutCategoryItem.isEmpty) {
            for (int i = 0; i < querySnapshot.docs.length; i++) {
              if (workoutCategoryIdList.contains(querySnapshot.docs[i].id)) {
                allWorkoutCategoryItem.add(querySnapshot.docs[i]);
              }
            }
          }
        }
        myWorkoutCategoryItem.clear();
        for (var listItem in allWorkoutCategoryItem) {
          if (listItem[keyWorkoutCategoryTitle] != null &&
              listItem[keyWorkoutCategoryTitle]
                  .trim()
                  .toLowerCase()
                  .contains(searchText.trim().toLowerCase())) {
            myWorkoutCategoryItem.add(listItem);
          }
        }
      } else {
        if (myWorkoutCategoryItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableWorkoutCategory)
              .where(keyCreatedBy, isEqualTo: createdBy)
              .get();
          for (int i = 0; i < querySnapshot.docs.length; i++) {
            if (workoutCategoryIdList.contains(querySnapshot.docs[i].id)) {
              myWorkoutCategoryItem.add(querySnapshot.docs[i]);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<void> getMyWorkoutCategory(
      {bool isRefresh = false,
      required String createdBy,
      String searchText = ""}) async {
    lastCreatedBy = createdBy;
    if (isRefresh) {
      myWorkoutCategoryItem.clear();
      allWorkoutCategoryItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allWorkoutCategoryItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableWorkoutCategory)
              .where(keyCreatedBy, isEqualTo: createdBy)
              .get();
          if (allWorkoutCategoryItem.isEmpty) {
            allWorkoutCategoryItem.addAll(querySnapshot.docs);
          }
        }
        myWorkoutCategoryItem.clear();
        for (var listItem in allWorkoutCategoryItem) {
          if (listItem[keyWorkoutCategoryTitle] != null &&
              listItem[keyWorkoutCategoryTitle]
                  .trim()
                  .toLowerCase()
                  .contains(searchText.trim().toLowerCase())) {
            myWorkoutCategoryItem.add(listItem);
          }
        }
      } else {
        if (myWorkoutCategoryItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableWorkoutCategory)
              .where(keyCreatedBy, isEqualTo: createdBy)
              .get();
          myWorkoutCategoryItem.addAll(querySnapshot.docs);
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<QueryDocumentSnapshot?> findWorkoutById(
      {required String categoryId, required String createdBy}) async {
    if (categoryId.isEmpty) {
      return null;
    }

    if (myWorkoutCategoryItem.isEmpty || lastCreatedBy != createdBy) {
      await getMyWorkoutCategory(isRefresh: true, createdBy: createdBy);
      debugPrint("lastCreatedBy : $lastCreatedBy");
      lastCreatedBy = createdBy;
    }
    var workoutCategoryData =
        myWorkoutCategoryItem.where((element) => element.id == categoryId);
    debugPrint("findWorkoutById :${myWorkoutCategoryItem.length}");
    debugPrint("findWorkoutById :${workoutCategoryData.length}");

    return workoutCategoryData.isNotEmpty ? workoutCategoryData.first : null;
  }
}
