import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model/default_response.dart';
import '../utils/file_upload_utils.dart';
import '../utils/firebase_interface.dart';
import '../utils/utils_methods.dart';

class WorkoutProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> workoutListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allWorkoutListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> selectedMemberWorkout = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> selectedMemberWorkoutLimit = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> popularWorkout = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> addByTrainerWorkoutList = <QueryDocumentSnapshot>[];

  Future<DefaultResponse> addWorkout(
      {required String workoutTitle,
      required String workoutFor,
      required int workoutDuration,
      required String workoutData,
      required int exerciseCount,
      required String createdById,
      required String workoutType,
      required String classScheduleId,
      required List<String> membershipId,
      required File? profile,
      required int totalTime}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableWorkout)
        .where(keyWorkoutTitle, isEqualTo: workoutTitle)
        .where(keyCreatedBy, isEqualTo: createdById)
        .get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.workout_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (profile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderWorkout, fileImage: profile);
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyWorkoutTitle: workoutTitle,
      keyWorkoutFor: workoutFor,
      keyDuration: workoutDuration,
      keyWorkoutData: workoutData,
      keyExerciseCount: exerciseCount,
      keyCreatedBy: createdById,
      keyWorkoutType: workoutType,
      keyMembershipId: membershipId,
      keyProfile: profileURL,
      keyTotalWorkoutTime: totalTime,
      keyClassScheduleId: classScheduleId,
      keyCreatedAt: getCurrentDateTime(),
    };

    await FirebaseFirestore.instance.collection(tableWorkout).add(bodyMap).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.workout_added_successfully;
      getWorkoutList(isRefresh: true, currentUserId: createdById);
      getWorkoutOfTrainer(currentUserId: createdById);
      getThreeWorkoutForCreatedBy(createdBy: createdById);
    }).then((doc) async {
      List<String> memberList = [];
      if (workoutType == workoutTypeFree) {
        var querySnapshot =
            await FirebaseFirestore.instance.collection(tableUser).where(keyCreatedBy, isEqualTo: createdById).get();
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          memberList.add(querySnapshot.docs[i].id);
        }
      } else if (membershipId.isNotEmpty) {
        for (int i = 0; i < membershipId.length; i++) {
          var querySnapshot = await FirebaseFirestore.instance
              .collection(tableUser)
              .where(keyCurrentMembership, isEqualTo: membershipId[i])
              .get();
          for (int j = 0; j < querySnapshot.docs.length; j++) {
            if (!memberList.contains(querySnapshot.docs[j].id)) {
              memberList.add(querySnapshot.docs[j].id);
            }
          }
        }
      }
      await FirebaseFirestore.instance
          .collection(tableWorkout)
          .doc(doc.id)
          .update({keySelectedMember: FieldValue.arrayUnion(memberList), keyMemberCount: memberList.length});
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<void> getWorkoutList({bool isRefresh = false, String searchText = "", required String currentUserId}) async {
    if (isRefresh) {
      workoutListItem.clear();
    }
    try {
      QuerySnapshot querySnapshot;
      if (workoutListItem.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection(tableWorkout)
            .where(keyCreatedBy, isEqualTo: currentUserId)
            .get();
        workoutListItem.addAll(querySnapshot.docs);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future<DefaultResponse> assignWorkoutForMember({
    required String memberId,
    required List<String> selectWorkoutList,
    required List<String> alreadySelectedWorkoutList,
    required List<String> unSelectedWorkoutList,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    defaultResponse.statusCode = onSuccess;
    defaultResponse.status = true;
    defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.assigned_workout_successfully;

    debugPrint("selectWorkoutList : $selectWorkoutList");
    debugPrint("alreadySelectedWorkoutList : $alreadySelectedWorkoutList");
    debugPrint("unSelectedWorkoutList : $unSelectedWorkoutList");
    for (int i = 0; i < selectWorkoutList.length; i++) {
      if (!alreadySelectedWorkoutList.contains(selectWorkoutList[i])) {
        debugPrint('SelectedWorkoutList : ${selectWorkoutList[i]}');
        await FirebaseFirestore.instance.collection(tableWorkout).doc(selectWorkoutList[i]).update({
          keySelectedMember: FieldValue.arrayUnion([memberId])
        }).whenComplete(() async {
          defaultResponse.statusCode = onSuccess;
          defaultResponse.status = true;
          defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.assigned_workout_successfully;
          FirebaseInterface().sendFirebaseNotification(
              userIdList: [memberId],
              title: "Workout assigned",
              body: 'You have assign Workout',
              type: notificationWorkoutAssign);

          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(tableUser).doc(memberId).get();
          String email = getDocumentValue(documentSnapshot: userDoc, key: keyEmail, defaultValue: "");

          String subject = 'Gym Workout Assignment';
          String plainText = 'Dear,'
              '\n\nI hope this email finds you well.Attached to this email, you will find your personalized workout plan for the gym.'
              '\nThis plan is tailored to your fitness goals and current level of fitness, so be sure to follow it closely to see the best results.'
              '\n\nThank you,';
          String htmlText = '<p>Dear,</p>'
              '<p>I hope this email finds you well.Attached to this email, you will find your personalized workout plan for the gym.</p>'
              '<p>This plan is tailored to your fitness goals and current level of fitness, so be sure to follow it closely to see the best results.</p>'
              '<p>Thank you,</p>';
          debugPrint("qwertyuio");

          FirebaseInterface()
              .sendEmailNotification(emailList: [email], subject: subject, plainText: plainText, htmlText: htmlText);
        }).catchError((e) {
          defaultResponse.statusCode = onFailed;
          defaultResponse.status = false;
          defaultResponse.message = e.toString();
        });
      }
    }
    for (int i = 0; i < unSelectedWorkoutList.length; i++) {
      await FirebaseFirestore.instance.collection(tableWorkout).doc(unSelectedWorkoutList[i]).update({
        keySelectedMember: FieldValue.arrayRemove([memberId])
      }).whenComplete(() async {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.assigned_workout_successfully;
        DocumentSnapshot workoutDoc =
            await FirebaseFirestore.instance.collection(tableWorkout).doc(unSelectedWorkoutList[i]).get();
        FirebaseInterface().sendFirebaseNotification(
            userIdList: [memberId],
            title: "Removed from workout",
            body: 'Your has been removed from ${workoutDoc[keyWorkoutTitle]}',
            type: notificationWorkoutUnAssign);
        debugPrint("MEMBER ID : ${[memberId]}");
        List<String> emailList = [];
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(tableUser).doc(memberId).get();
        String email = getDocumentValue(documentSnapshot: userDoc, key: keyEmail, defaultValue: "");
        if (email.isNotEmpty) {
          emailList.add(email);
        }

        String subject = ' ${workoutDoc[keyWorkoutTitle]} Removed from Gym Package';
        String plainText = 'Dear,'
            '\n\nWe hope this email finds you well. We would like to inform you that effective immediately, we have removed the workout feature from our gym package.'
            '\nWe apologize for any inconvenience this may cause and assure you that we are constantly striving to enhance our services.'
            '\n\nIf you have any questions or require further assistance, please don not hesitate to contact our customer support team. Thank you for your understanding.'
            '\n\nBest regards,';
        '\nGym Trainer';
        String htmlText = '<p>Dear,</p>'
            '<p>We hope this email finds you well. We would like to inform you that effective immediately, we have removed the workout feature from our gym package.</p>'
            '<p>We apologize for any inconvenience this may cause and assure you that we are constantly striving to enhance our services.</p>'
            '<p>If you have any questions or require further assistance, please don not hesitate to contact our customer support team. Thank you for your understanding.</p>'
            '<p>Best regards,</p>';
        '<p>Gym Trainer</p>';
        debugPrint("qwertyuio");

        FirebaseInterface()
            .sendEmailNotification(emailList: emailList, subject: subject, plainText: plainText, htmlText: htmlText);
      }).catchError((e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
      });
    }
    return defaultResponse;
  }

  Future<DefaultResponse> updateWorkoutMember(
      {required String workoutId,
      required List<String> selectMemberList,
      required List<String> unselectMemberList,
      required memberCount,
      required String currentUserId}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keySelectedMember: selectMemberList,
      keyMemberCount: memberCount,
    };

    debugPrint("updateWorkoutMember :  $bodyMap");
    DocumentSnapshot workoutDoc = await FirebaseFirestore.instance.collection(tableWorkout).doc(workoutId).get();
    await FirebaseFirestore.instance
        .collection(tableWorkout)
        .doc(workoutId)
        .update(
          bodyMap,
        )
        .whenComplete(() async {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.workout_updated_successfully;
      debugPrint("SelectMember$selectMemberList");
      debugPrint("UnSelectMember${unselectMemberList.length}");
      FirebaseInterface().sendFirebaseNotification(
          userIdList: selectMemberList,
          title: "Workout assigned",
          body: 'You have assign Workout',
          type: notificationWorkoutAssign);
      debugPrint("UnselectMember$unselectMemberList");

      FirebaseInterface().sendFirebaseNotification(
          userIdList: unselectMemberList,
          title: "Removed from workout",
          body: 'Your has been removed from ${workoutDoc[keyWorkoutTitle]}',
          type: notificationWorkoutUnAssign);

      List<String> emailList = [];
      for (int i = 0; i < selectMemberList.length; i++) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection(tableUser).doc(selectMemberList[i]).get();
        String email = getDocumentValue(documentSnapshot: userDoc, key: keyEmail, defaultValue: "");
        if (email.isNotEmpty) {
          emailList.add(email);
          debugPrint("emailList : ${emailList.length}");
        }
      }
      String subject = 'Gym Workout Assigned';
      String plainText = 'Dear,'
          '\n\nI hope this email finds you well.Attached to this email, you will find your personalized workout plan for the gym.'
          '\nThis plan is tailored to your fitness goals and current level of fitness, so be sure to follow it closely to see the best results.'
          '\n\nThank you,';
      String htmlText = '<p>Dear,</p>'
          '<p>I hope this email finds you well.Attached to this email, you will find your personalized workout plan for the gym.</p>'
          '<p>This plan is tailored to your fitness goals and current level of fitness, so be sure to follow it closely to see the best results.</p>'
          '<p>Thank you,</p>';
      debugPrint("emailList11 : ${emailList.length}");

      FirebaseInterface()
          .sendEmailNotification(emailList: emailList, subject: subject, plainText: plainText, htmlText: htmlText);

      List<String> emailList1 = [];
      for (int i = 0; i < unselectMemberList.length; i++) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection(tableUser).doc(unselectMemberList[i]).get();
        String email = getDocumentValue(documentSnapshot: userDoc, key: keyEmail, defaultValue: "");
        if (email.isNotEmpty) {
          emailList1.add(email);
        }
      }
      String subject1 = 'Important Update - Workout Removed from Gym Package';
      String plainText1 = 'Dear,'
          '\n\nWe hope this email finds you well. We would like to inform you that effective immediately, we have removed the workout feature from our gym package.'
          '\nWe apologize for any inconvenience this may cause and assure you that we are constantly striving to enhance our services.'
          "\nIf you have any questions or require further assistance, please don't hesitate to contact our customer support team. Thank you for your understanding."
          '\n\nThank you,';
      String htmlText1 = '<p>Dear,</p>'
          '<p>We hope this email finds you well. We would like to inform you that effective immediately, we have removed the workout feature from our gym package.</p>'
          '<p>We apologize for any inconvenience this may cause and assure you that we are constantly striving to enhance our services.</p>'
          "<p>If you have any questions or require further assistance, please don't hesitate to contact our customer support team. Thank you for your understanding.</p>"
          '<p>Thank you,</p>';
      debugPrint("qwertyuio");

      FirebaseInterface()
          .sendEmailNotification(emailList: emailList1, subject: subject1, plainText: plainText1, htmlText: htmlText1);

      getPopularWorkout();
      getThreeWorkoutForCreatedBy(createdBy: currentUserId);
      getWorkoutOfTrainer(currentUserId: currentUserId);
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<void> getWorkoutForSelectedMember(
      {required String selectedMemberId, bool isRefresh = false, String searchText = ""}) async {
    if (isRefresh) {
      selectedMemberWorkout.clear();
      allWorkoutListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (selectedMemberWorkout.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableWorkout)
              .orderBy(keyWorkoutType, descending: true)
              .where(keySelectedMember, arrayContains: selectedMemberId)
              .get();
          allWorkoutListItem.clear();
          allWorkoutListItem.addAll(querySnapshot.docs);
          debugPrint('allMemberListItem1${querySnapshot.docs.length}');
        }
        selectedMemberWorkout.clear();
        for (var listItem in allWorkoutListItem) {
          if (listItem[keyExerciseTitle] != null &&
              listItem[keyExerciseTitle].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            selectedMemberWorkout.add(listItem);
          }
        }
      } else {
        QuerySnapshot querySnapshot;
        if (selectedMemberWorkout.isEmpty) {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableWorkout)
              .orderBy(keyWorkoutType, descending: true)
              .where(keySelectedMember, arrayContains: selectedMemberId)
              .get();
          selectedMemberWorkout.clear();
          selectedMemberWorkout.addAll(querySnapshot.docs);
          debugPrint('allMemberListItem2${querySnapshot.docs.length}');
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
    /*selectedMemberWorkout.clear();
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(tableWorkout)
        .where(keySelectedMember, arrayContains: selectedMemberId)
        .get();
    debugPrint('Print Id: $selectedMemberId');
    selectedMemberWorkout.addAll(querySnapshot.docs);
    debugPrint('selectedCategoryExercise: ${selectedMemberWorkout.length}');*/
    notifyListeners();
  }

  Future<void> getThreeWorkoutForSelectedMember({required String selectedMemberId}) async {
    selectedMemberWorkoutLimit.clear();
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(tableWorkout)
        .where(keySelectedMember, arrayContains: selectedMemberId)
        .limit(3)
        .get();
    debugPrint('Print Id: $selectedMemberId');
    selectedMemberWorkoutLimit.addAll(querySnapshot.docs);
    debugPrint('selectedCategoryExercise: ${selectedMemberWorkout.length}');
    notifyListeners();
  }

  Future<void> getThreeWorkoutForCreatedBy({required String createdBy}) async {
    selectedMemberWorkout.clear();
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(tableWorkout)
        .where(keyCreatedBy, isEqualTo: createdBy)
        .limit(3)
        .get();
    debugPrint('Print Id: $createdBy');
    selectedMemberWorkout.addAll(querySnapshot.docs);
    debugPrint('selectedCategoryExercise: ${selectedMemberWorkout.length}');
    notifyListeners();
  }

  Future<void> getPopularWorkout() async {
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(tableWorkout)
        .orderBy(keyMemberCount, descending: true)
        .limit(5)
        .get();
    popularWorkout.clear();
    popularWorkout.addAll(querySnapshot.docs);
    debugPrint("Size : ${popularWorkout.length}");
    notifyListeners();
  }

  Future<DefaultResponse> updateWorkoutData({
    required String workoutId,
    required String workoutData,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyWorkoutData: workoutData,
    };

    await FirebaseFirestore.instance
        .collection(tableWorkout)
        .doc(workoutId)
        .update(
          bodyMap,
        )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.workout_updated_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DocumentSnapshot?> getSingleWorkout({required String workoutId}) async {
    if (workoutId.isEmpty) {
      debugPrint("workout id is empty");
      return null;
    }
    debugPrint("workout id : $workoutId");
    var querySnapshot = await FirebaseFirestore.instance.collection(tableWorkout).doc(workoutId).get();
    return querySnapshot;
  }

  Future<void> getWorkoutOfTrainer({required String currentUserId}) async {
    addByTrainerWorkoutList.clear();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(tableWorkout)
        .orderBy(keyWorkoutType, descending: true)
        .orderBy(keyCreatedAt, descending: true)
        .where(keyCreatedBy, isEqualTo: currentUserId)
        .get();
    addByTrainerWorkoutList.addAll(querySnapshot.docs);
    debugPrint('getWorkoutOfTrainer : $currentUserId');
    debugPrint('Workout Length ${querySnapshot.docs.length}');
    notifyListeners();
  }

  Future<void> getAllTrainerWorkout() async {
    popularWorkout.clear();
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(tableWorkout)
        .orderBy(keyMemberCount, descending: true)
        .limit(10)
        .get();
    popularWorkout.addAll(querySnapshot.docs);
    debugPrint('popularWorkout : ${popularWorkout.length}');
    notifyListeners();
  }

  Future<void> deleteWorkout({required workoutId}) async {
    await FirebaseFirestore.instance.collection(tableWorkout).doc(workoutId).delete();
    int index = addByTrainerWorkoutList.indexWhere((element) => element.id == workoutId);

    var profile = addByTrainerWorkoutList[index].get(keyProfile);
    await FileUploadUtils().removeSingleFile(url: profile);

    if (index != -1) addByTrainerWorkoutList.removeAt(index);

    Fluttertoast.showToast(
        msg: AppLocalizations.of(navigatorKey.currentContext!)!.workout_deleted_successfully,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    notifyListeners();
  }

  Future<DefaultResponse> updateWorkout(
      {required String workoutId,
      required File? profile,
      required String? oldImageUrl,
      required String workoutTitle,
      required int duration,
      required int exerciseCount,
      required String workoutType,
      required String currentUserId,
      required String workoutFor,
      required String workoutData,
      required String classScheduleId,
      required List<String> membershipId,
      required int totalTime}) async {
    DefaultResponse defaultResponse = DefaultResponse();
    String profileURL = "";
    if (profile != null && oldImageUrl != null) {
      profileURL = await FileUploadUtils()
          .uploadAndUpdateImage(folderName: folderWorkoutCategory, fileImage: profile, oldUrl: oldImageUrl);
    } else if (profile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderWorkoutCategory, fileImage: profile);
    } else if (oldImageUrl != null) {
      profileURL = oldImageUrl;
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyDuration: duration,
      keyProfile: profileURL,
      keyWorkoutTitle: workoutTitle,
      keyWorkoutData: workoutData,
      keyWorkoutFor: workoutFor,
      keyWorkoutType: workoutType,
      keyMembershipId: membershipId,
      keyExerciseCount: exerciseCount,
      keyTotalWorkoutTime: totalTime,
      keyClassScheduleId: classScheduleId,
    };

    await FirebaseFirestore.instance
        .collection(tableWorkout)
        .doc(workoutId)
        .update(bodyMap)
        .whenComplete(() async {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.workout_updated_successfully;
      getWorkoutOfTrainer(currentUserId: currentUserId);
      getPopularWorkout();

      List<String> memberList = [];
      if (workoutType == workoutTypeFree) {
        var querySnapshot =
            await FirebaseFirestore.instance.collection(tableUser).where(keyCreatedBy, isEqualTo: currentUserId).get();
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          memberList.add(querySnapshot.docs[i].id);
        }
      } else if (membershipId.isNotEmpty) {
        for (int i = 0; i < membershipId.length; i++) {
          var querySnapshot = await FirebaseFirestore.instance
              .collection(tableUser)
              .where(keyCurrentMembership, isEqualTo: membershipId[i])
              .get();
          for (int j = 0; j < querySnapshot.docs.length; j++) {
            if (!memberList.contains(querySnapshot.docs[j].id)) {
              memberList.add(querySnapshot.docs[j].id);
            }
          }
        }
      }
      await FirebaseFirestore.instance
          .collection(tableWorkout)
          .doc(workoutId)
          .update({keySelectedMember: FieldValue.arrayUnion(memberList), keyMemberCount: memberList.length});
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> assignWorkoutToMember(
      {required String workoutId, required List<String> selectedMemberList}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    if (workoutId.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.workout_is_empty;
      return defaultResponse;
    }
    await FirebaseFirestore.instance
        .collection(tableWorkout)
        .doc(workoutId)
        .update({keySelectedMember: FieldValue.arrayUnion(selectedMemberList)}).whenComplete(() async {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.assigned_workout_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }
}
