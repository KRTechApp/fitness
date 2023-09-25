import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/global_search_model.dart';
import '../utils/tables_keys_values.dart';

class GlobalSearchProvider with ChangeNotifier {
  List<GlobalSearchModel> globalSearchList = <GlobalSearchModel>[];
  List<QueryDocumentSnapshot> membershipListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allMembershipListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> trainerListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allTrainerListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> memberListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allMemberListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> workoutListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allWorkoutListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> exerciseListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allExerciseListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> classListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allClassListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> workoutCategoryListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allWorkoutCategoryListItem = <QueryDocumentSnapshot>[];

  Future<void> getGlobalSearchList(
      {bool isRefresh = false, required String currentUserId, required String searchText}) async {
    if (searchText.isEmpty) {
      globalSearchList.clear();
      notifyListeners();
      return;
    }
    await getMembershipList(isRefresh: isRefresh, currentUserId: currentUserId, searchText: searchText);
    await getTrainerList(isRefresh: isRefresh, searchText: searchText);
    await getPopularWorkout(isRefresh: isRefresh, searchText: searchText);
    globalSearchList.clear();
    for (int i = 0; i < trainerListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: trainerListItem[i], type: "trainer"));
    }
    for (int i = 0; i < membershipListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: membershipListItem[i], type: "membership"));
    }
    for (int i = 0; i < workoutListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: workoutListItem[i], type: "workout"));
    }

    notifyListeners();
  }

  Future<void> getMemberGlobalSearchList(
      {bool isRefresh = false, required String selectedMemberId, required String searchText}) async {
    if (searchText.isEmpty) {
      globalSearchList.clear();
      notifyListeners();
      return;
    }
    await getWorkoutListForMember(selectedMemberId: selectedMemberId, isRefresh: isRefresh, searchText: searchText);
    await getClassListForMember(selectedMemberId: selectedMemberId, isRefresh: isRefresh, searchText: searchText);
    await getExerciseListForMember(selectedMemberId: selectedMemberId, isRefresh: isRefresh, searchText: searchText);
    await getWorkoutCategoryListForMember(createdBy: selectedMemberId, isRefresh: isRefresh, searchText: searchText);
    globalSearchList.clear();
    for (int i = 0; i < workoutListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: workoutListItem[i], type: "memberWorkout"));
    }

    for (int i = 0; i < classListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: classListItem[i], type: "memberClass"));
    }

    for (int i = 0; i < exerciseListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: exerciseListItem[i], type: "memberExercise"));
    }
    for (int i = 0; i < workoutCategoryListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: workoutCategoryListItem[i], type: "memberWorkoutCategory"));
    }
    notifyListeners();
  }

  Future<void> getTrainerGlobalSearchList(
      {bool isRefresh = false, required String currentUserId, required String searchText}) async {
    if (searchText.isEmpty) {
      globalSearchList.clear();
      notifyListeners();
      return;
    }
    await getMembershipList(isRefresh: isRefresh, currentUserId: currentUserId, searchText: searchText);
    await getMemberList(isRefresh: isRefresh, currentUserId: currentUserId, searchText: searchText);
    await getWorkoutList(isRefresh: isRefresh, currentUserId: currentUserId, searchText: searchText);
    await getExerciseList(isRefresh: isRefresh, currentUserId: currentUserId, searchText: searchText);
    globalSearchList.clear();

    for (int i = 0; i < membershipListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: membershipListItem[i], type: "membership"));
    }
    for (int i = 0; i < memberListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: memberListItem[i], type: "member"));
    }
    for (int i = 0; i < workoutListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: workoutListItem[i], type: "workout"));
    }
    for (int i = 0; i < exerciseListItem.length; i++) {
      globalSearchList.add(GlobalSearchModel(queryDocument: exerciseListItem[i], type: "exercise"));
    }

    notifyListeners();
  }

  Future<void> getMembershipList(
      {bool isRefresh = false, required String currentUserId, String searchText = ""}) async {
    if (isRefresh) {
      membershipListItem.clear();
      allMembershipListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allMembershipListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableMembership)
              .where(keyCreatedBy, isEqualTo: currentUserId)
              .get();
          if (allMembershipListItem.isEmpty) {
            allMembershipListItem.addAll(querySnapshot.docs);
          }
        }
        membershipListItem.clear();
        for (var listItem in allMembershipListItem) {
          if (listItem[keyMembershipName] != null &&
              listItem[keyMembershipName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            membershipListItem.add(listItem);
            debugPrint('memberListItemSize:${memberListItem.length}');
          }
        }
      } else {
        membershipListItem.clear();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getWorkoutList({bool isRefresh = false, required String currentUserId, String searchText = ""}) async {
    if (isRefresh) {
      workoutListItem.clear();
      allWorkoutListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allWorkoutListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableWorkout)
              .where(keyCreatedBy, isEqualTo: currentUserId)
              .get();
          if (allWorkoutListItem.isEmpty) {
            allWorkoutListItem.addAll(querySnapshot.docs);
          }
        }
        workoutListItem.clear();
        for (var listItem in allWorkoutListItem) {
          if (listItem[keyWorkoutTitle] != null &&
              listItem[keyWorkoutTitle].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            workoutListItem.add(listItem);
            debugPrint('workoutListItem:${workoutListItem.length}');
          }
        }
      } else {
        workoutListItem.clear();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getExerciseList({bool isRefresh = false, required String currentUserId, String searchText = ""}) async {
    if (isRefresh) {
      exerciseListItem.clear();
      allExerciseListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allExerciseListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableExercise)
              .where(keyCreatedBy, isEqualTo: currentUserId)
              .get();
          if (allExerciseListItem.isEmpty) {
            allExerciseListItem.addAll(querySnapshot.docs);
          }
        }
        exerciseListItem.clear();
        for (var listItem in allExerciseListItem) {
          if (listItem[keyExerciseTitle] != null &&
              listItem[keyExerciseTitle].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            exerciseListItem.add(listItem);
            debugPrint('exerciseListItem:${exerciseListItem.length}');
          }
        }
      } else {
        exerciseListItem.clear();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getTrainerList({bool isRefresh = false, String searchText = ""}) async {
    if (isRefresh) {
      trainerListItem.clear();
      allTrainerListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allTrainerListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableUser)
              .where(keyUserRole, isEqualTo: userRoleTrainer)
              .get();
          if (allTrainerListItem.isEmpty) {
            allTrainerListItem.addAll(querySnapshot.docs);
          }
        }
        trainerListItem.clear();
        for (var listItem in allTrainerListItem) {
          if (listItem[keyName] != null &&
              listItem[keyName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            trainerListItem.add(listItem);
            debugPrint('trainerListItem:${trainerListItem.length}');
          }
        }
      } else {
        trainerListItem.clear();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getMemberList({bool isRefresh = false, required String currentUserId, String searchText = ""}) async {
    if (isRefresh) {
      memberListItem.clear();
      allMemberListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allMemberListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableUser)
              .where(keyCreatedBy, isEqualTo: currentUserId)
              .get();
          if (allMemberListItem.isEmpty) {
            allMemberListItem.addAll(querySnapshot.docs);
          }
        }
        memberListItem.clear();
        for (var listItem in allMemberListItem) {
          if (listItem[keyName] != null &&
              listItem[keyName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            memberListItem.add(listItem);
            debugPrint('memberListItem: ${memberListItem.length}');
          }
        }
      } else {
        memberListItem.clear();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getWorkoutListForMember(
      {bool isRefresh = false, required String selectedMemberId, String searchText = ""}) async {
    if (isRefresh) {
      workoutListItem.clear();
      allWorkoutListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allWorkoutListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableWorkout)
              .where(keySelectedMember, arrayContains: selectedMemberId)
              .get();
          if (allWorkoutListItem.isEmpty) {
            allWorkoutListItem.addAll(querySnapshot.docs);
          }
        }
        workoutListItem.clear();
        for (var listItem in allWorkoutListItem) {
          if (listItem[keyWorkoutTitle] != null &&
              listItem[keyWorkoutTitle].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            workoutListItem.add(listItem);
            debugPrint('memberWorkoutListItemSize:${workoutListItem.length}');
          }
        }
      } else {
        workoutListItem.clear();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getClassListForMember(
      {bool isRefresh = false, required String selectedMemberId, String searchText = ""}) async {
    if (isRefresh) {
      classListItem.clear();
      allClassListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allClassListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableClass)
              .where(keySelectedMember, arrayContains: selectedMemberId)
              .get();
          if (allClassListItem.isEmpty) {
            allClassListItem.addAll(querySnapshot.docs);
          }
        }
        classListItem.clear();
        for (var listItem in allClassListItem) {
          if (listItem[keyClassName] != null &&
              listItem[keyClassName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            classListItem.add(listItem);
            debugPrint('classListItemSize:${classListItem.length}');
          }
        }
      } else {
        classListItem.clear();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getExerciseListForMember(
      {bool isRefresh = false, required String selectedMemberId, String searchText = ""}) async {
    if (isRefresh) {
      exerciseListItem.clear();
      allExerciseListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allExerciseListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableClass)
              .where(keySelectedMember, arrayContains: selectedMemberId)
              .get();
          if (allExerciseListItem.isEmpty) {
            allExerciseListItem.addAll(querySnapshot.docs);
          }
        }
        exerciseListItem.clear();
        for (var listItem in allExerciseListItem) {
          if (listItem[keyExerciseTitle] != null &&
              listItem[keyExerciseTitle].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            exerciseListItem.add(listItem);
            debugPrint('ExerciseListItemSize:${exerciseListItem.length}');
          }
        }
      } else {
        exerciseListItem.clear();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getWorkoutCategoryListForMember(
      {bool isRefresh = false, required String createdBy, String searchText = ""}) async {
    if (isRefresh) {
      workoutCategoryListItem.clear();
      allWorkoutCategoryListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allWorkoutCategoryListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableWorkoutCategory)
              .orderBy(keyWorkoutCategoryTitle)
              .where(keyCreatedBy, isEqualTo: createdBy)
              .get();
          if (allWorkoutCategoryListItem.isEmpty) {
            allWorkoutCategoryListItem.addAll(querySnapshot.docs);
          }
        }
        workoutCategoryListItem.clear();
        for (var listItem in allWorkoutCategoryListItem) {
          if (listItem[keyWorkoutCategoryTitle] != null &&
              listItem[keyWorkoutCategoryTitle].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            workoutCategoryListItem.add(listItem);
            debugPrint('workoutCategoryListItemSize:${workoutCategoryListItem.length}');
          }
        }
      } else {
        workoutCategoryListItem.clear();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getPopularWorkout({bool isRefresh = false, String searchText = ""}) async {
    if (isRefresh) {
      workoutListItem.clear();
      allWorkoutListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allWorkoutListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableWorkout)
              .orderBy(keyMemberCount, descending: true)
              .limit(10)
              .get();
          if (allWorkoutListItem.isEmpty) {
            allWorkoutListItem.addAll(querySnapshot.docs);
          }
        }
        workoutListItem.clear();
        for (var listItem in allWorkoutListItem) {
          if (listItem[keyWorkoutTitle] != null &&
              listItem[keyWorkoutTitle].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            workoutListItem.add(listItem);
            debugPrint('workoutListItem:${workoutListItem.length}');
          }
        }
      } else {
        workoutListItem.clear();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }
}
