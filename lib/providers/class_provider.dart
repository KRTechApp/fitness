import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/default_response.dart';
import '../utils/firebase_interface.dart';
import '../utils/static_data.dart';
import '../utils/utils_methods.dart';

class ClassProvider with ChangeNotifier {
  // TrainerModal trainerModal = TrainerModal();
  List<QueryDocumentSnapshot> classListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allClassListItem = <QueryDocumentSnapshot>[];

  Future<DefaultResponse> addClassFirebase({
    required className,
    required startDate,
    required endDate,
    required startTime,
    required endTime,
    required classType,
    required userId,
    required selectedDays,
    required selectedMember,
    required virtualClassLink,
    required workoutId,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableClass)
        .where(keyClassName, isEqualTo: className)
        .where(keyCreatedBy, isEqualTo: userId)
        .get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.class_already_exist;
      return defaultResponse;
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyClassName: className,
      keyStartDate: startDate,
      keyEndDate: endDate,
      keyStartTime: startTime,
      keyEndTime: endTime,
      keyClassType: classType,
      keyCreatedBy: userId,
      keySelectedDays: selectedDays,
      keySelectedMember: selectedMember,
      keyVirtualClassLink: virtualClassLink,
      keyWorkoutId: workoutId,
    };

    await FirebaseFirestore.instance.collection(tableClass).doc().set(bodyMap).whenComplete(
      () async {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.class_add_successfully;
        var sd = DateFormat(StaticData.currentDateFormat).format(DateTime.fromMillisecondsSinceEpoch(startDate));
        var ed = DateFormat(StaticData.currentDateFormat).format(DateTime.fromMillisecondsSinceEpoch(endDate));
        debugPrint('check date formate $sd and $ed');
        FirebaseInterface().sendFirebaseNotification(
            userIdList: selectedMember,
            title: "$className assigned",
            body: 'You have assign '
                '$className for $sd To $ed',
            type: notificationClassAssign);
        List<String> emailList = [];
        for (int i = 0; i < selectedMember.length; i++) {
          DocumentSnapshot userDoc =
              await FirebaseFirestore.instance.collection(tableUser).doc(selectedMember[i]).get();
          String email = getDocumentValue(documentSnapshot: userDoc, key: keyEmail, defaultValue: "");
          if (email.isNotEmpty) {
            emailList.add(email);
          }
        }
        String subject = 'Class Assign - Gym App - [$sd/$startTime]';
        String plainText = 'Dear,'
            '\n\nI would like to reserve a spot for the $className class on $sd at $startTime.'
            '\n\nThank you,';
        String htmlText = '<p>Dear,</p>'
            '<p>I would like to reserve a spot for the $className class on $sd at $startTime.</p>'
            '<p>Thank you,</p>';

        FirebaseInterface()
            .sendEmailNotification(emailList: emailList, subject: subject, plainText: plainText, htmlText: htmlText);
        getSearchTrainerClassList(currentUserId: userId, isRefresh: true);
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

  Future<DefaultResponse> updateClass({
    required classId,
    required className,
    required startDate,
    required endDate,
    required startTime,
    required endTime,
    required classType,
    required userId,
    required selectedDays,
    required selectedMember,
    required virtualClassLink,
    required workoutId,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tableClass).where(keyClassName, isEqualTo: className).get();
    var currentDoc = query.docs.where((element) => element.id == classId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.class_already_exist;
      return defaultResponse;
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyClassName: className,
      keyStartDate: startDate,
      keyEndDate: endDate,
      keyStartTime: startTime,
      keyEndTime: endTime,
      keyClassType: classType,
      keyCreatedBy: userId,
      keySelectedDays: selectedDays,
      keySelectedMember: selectedMember,
      keyVirtualClassLink: virtualClassLink,
      keyWorkoutId: workoutId,
    };

    await FirebaseFirestore.instance
        .collection(tableClass)
        .doc(classId)
        .update(
          bodyMap,
        )
        .whenComplete(
      () async {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.class_update_successfully;

        /*  int sd = startDate;
        int ed = startDate;
        var st = DateTime.fromMillisecondsSinceEpoch(sd);
        var et = DateTime.fromMillisecondsSinceEpoch(ed);
*/
        var sd = DateFormat(StaticData.currentDateFormat).format(DateTime.fromMillisecondsSinceEpoch(startDate));
        var ed = DateFormat(StaticData.currentDateFormat).format(DateTime.fromMillisecondsSinceEpoch(endDate));
        debugPrint('check date formate $sd and $ed');
        FirebaseInterface().sendFirebaseNotification(
            userIdList: selectedMember,
            title: "$className assigned",
            body: 'You have assign '
                '$className for $sd To $ed',
            type: notificationClassAssign);
        debugPrint("13245678");
        List<String> emailList = [];
        for (int i = 0; i < selectedMember.length; i++) {
          DocumentSnapshot userDoc =
              await FirebaseFirestore.instance.collection(tableUser).doc(selectedMember[i]).get();
          String email = getDocumentValue(documentSnapshot: userDoc, key: keyEmail, defaultValue: "");
          if (email.isNotEmpty) {
            emailList.add(email);
          }
        }
        debugPrint("9876543");

        String subject = 'Class Assign - Gym App - [$sd/$startTime]';
        String plainText = 'Dear,'
            '\n\nI would like to reserve a spot for the $className class on $sd at $startTime.'
            '\n\nThank you,';
        String htmlText = '<p>Dear,</p>'
            '<p>I would like to reserve a spot for the $className class on $sd at $startTime.</p>'
            '<p>Thank you,</p>';
        debugPrint("qwertyuio");

        FirebaseInterface()
            .sendEmailNotification(emailList: emailList, subject: subject, plainText: plainText, htmlText: htmlText);
        getSearchTrainerClassList(currentUserId: userId, isRefresh: true);
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

  Future<void> deleteClass({required classId}) async {
    int index;
    await FirebaseFirestore.instance
        .collection(tableClass)
        .doc(classId)
        .delete()
        .whenComplete(
          () => {
            index = classListItem.indexWhere((element) => element.id == classId),
            if (index != -1) classListItem.removeAt(index),
            Fluttertoast.showToast(
                msg: AppLocalizations.of(navigatorKey.currentContext!)!.class_deleted_successfully,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0),
            notifyListeners(),
          },
        )
        .catchError(
      (e) {
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      },
    );
  }

  Future<void> getClassByUser({required userId, bool isRefresh = false, String searchText = ""}) async {
    if (isRefresh) {
      classListItem.clear();
      allClassListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allClassListItem.isEmpty) {
          var querySnapshot = await FirebaseFirestore.instance
              .collection(tableClass)
              .where(keySelectedMember, arrayContains: userId)
              .get();
          if (allClassListItem.isEmpty) {
            allClassListItem.addAll(querySnapshot.docs);
            debugPrint('allClassListItem Size1${querySnapshot.size}');
          }
        }
        classListItem.clear();
        for (var listItem in allClassListItem) {
          if (listItem[keyClassName] != null &&
              listItem[keyClassName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            classListItem.add(listItem);
          }
        }
      } else {
        QuerySnapshot querySnapshot;
        if (classListItem.isNotEmpty) {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableClass)
              .where(keySelectedMember, arrayContains: userId)
              .get();
        } else {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableClass)
              .where(keySelectedMember, arrayContains: userId)
              .get();
        }
        classListItem.clear();
        classListItem.addAll(querySnapshot.docs);
        debugPrint('allClassListItem Size2${querySnapshot.size}');
      }
    } catch (e) {
      debugPrint("$e");
    }
    /* var querySnapshot =
        await FirebaseFirestore.instance.collection(tableClass)
            .where(keySelectedMember, arrayContains: userId).get();
    debugPrint("classListItem.length $userId");
    debugPrint("classListItem.length ${querySnapshot.size}");

    classListItem.clear();
    classListItem.addAll(querySnapshot.docs);
    debugPrint("classListItem.length ${querySnapshot.docs.length}");*/

    notifyListeners();
  }

  Future<void> getSearchTrainerClassList(
      {bool isRefresh = false, required String currentUserId, String searchText = ""}) async {
    if (isRefresh) {
      classListItem.clear();
      allClassListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allClassListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableClass)
              .where(keyCreatedBy, isEqualTo: currentUserId)
              .get();
          if (allClassListItem.isEmpty) {
            allClassListItem.addAll(querySnapshot.docs);
            debugPrint('allClassListItem Size1${querySnapshot.size}');
          }
        }
        classListItem.clear();
        for (var listItem in allClassListItem) {
          if (listItem[keyClassName] != null &&
              listItem[keyClassName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            classListItem.add(listItem);
          }
        }
      } else {
        QuerySnapshot querySnapshot;
        if (classListItem.isNotEmpty) {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableClass)
              .where(keyCreatedBy, isEqualTo: currentUserId)
              .get();
        } else {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableClass)
              .where(keyCreatedBy, isEqualTo: currentUserId)
              .get();
        }
        classListItem.clear();
        classListItem.addAll(querySnapshot.docs);
        debugPrint('allClassListItem Size2${querySnapshot.size}');
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<DefaultResponse> assignClassToMember(
      {required String classScheduleId, required List<String> selectedMemberList}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    if (classScheduleId.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.class_schedule_id_is_empty;
      return defaultResponse;
    }
    await FirebaseFirestore.instance
        .collection(tableClass)
        .doc(classScheduleId)
        .update({keySelectedMember: FieldValue.arrayUnion(selectedMemberList)}).whenComplete(() async {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.class_Assigned_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }
}
