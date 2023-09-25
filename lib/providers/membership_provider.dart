import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/Utils/shared_preferences_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model/default_response.dart';
import '../model/attachment_list_item.dart';
import '../utils/file_upload_utils.dart';
import '../utils/tables_keys_values.dart';

class MembershipProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> membershipListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> popularMembership = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allMembershipListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> assignPackageMembership = <QueryDocumentSnapshot>[];
  String lastCreatedBy = "";

  Future<DefaultResponse> addMembershipFirebase(
      {required membershipName,
      required amount,
      required period,
      required classLimit,
      required memberLimit,
      required bool recurringPackage,
      required List<String> assignTrainer,
      required description,
      required File? profile,
      required createdBy,
      required String userRole,
      required List<AttachmentListItem>? membershipAttachment}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableMembership)
        .where(keyMembershipName, isEqualTo: membershipName)
        .where(keyCreatedBy, isEqualTo: createdBy)
        .get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.membership_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (profile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderMembership, fileImage: profile);
    }

    List<String> attachmentList = [];

    if (membershipAttachment != null && membershipAttachment.isNotEmpty) {
      for (var i = 0; i < membershipAttachment.length; i++) {
        if (membershipAttachment[i].attachment != null) {
          var attachment =
              await FileUploadUtils().uploadDocument(folderName: folderMembershipAttachment, fileDoc: membershipAttachment[i].attachment!);
          attachmentList.add(attachment);
        }
      }
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyMembershipName: membershipName,
      keyAmount: int.parse(amount),
      keyPeriod: int.parse(period),
      keyClassLimit: int.parse(classLimit),
      keyMemberLimit: int.parse(memberLimit),
      keyRecurringPackage: recurringPackage,
      keyDescription: description,
      keyProfile: profileURL,
      keyAttachment: attachmentList,
      keyCreatedBy: createdBy,
      keyUserRole: userRole,
      keyAssignedMembers: assignTrainer
    };


    await FirebaseFirestore.instance.collection(tableMembership).add(bodyMap).then((doc) {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.membership_added_successfully;
      defaultResponse.responseData = doc.id;
      /*FirebaseInterface().sendFirebaseNotification(userIdList: assignTrainer,title: "$membershipName package assigned", body: 'You have assign '
          '$membershipName package for $period days',
          type:
          notificationTrainerPackageAssign);*/
      getMembershipList(isRefresh: true, createdById: createdBy);
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> addTrainerMembershipFirebase(
      {required membershipName,
      required amount,
      required period,
      required bool recurringPackage,
      required description,
      required File? profile,
      required List<String> assignMember,
      required String createdBy,
      required String userRole,
      required List<AttachmentListItem>? membershipAttachment}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableMembership)
        .where(keyMembershipName, isEqualTo: membershipName)
        .where(keyCreatedBy, isEqualTo: createdBy)
        .get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.membership_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (profile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderMembership, fileImage: profile);
    }

    List<String> attachmentList = [];

    if (membershipAttachment != null && membershipAttachment.isNotEmpty) {
      for (var i = 0; i < membershipAttachment.length; i++) {
        if (membershipAttachment[i].attachment != null) {
          var attachment =
              await FileUploadUtils().uploadDocument(folderName: folderMembershipAttachment, fileDoc: membershipAttachment[i].attachment!);
          attachmentList.add(attachment);
        }
      }
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyMembershipName: membershipName,
      keyAmount: int.parse(amount),
      keyPeriod: int.parse(period),
      keyRecurringPackage: recurringPackage,
      keyDescription: description,
      keyProfile: profileURL,
      keyAttachment: attachmentList,
      keyCreatedBy: createdBy,
      keyAssignedMembers: assignMember,
      keyUserRole: userRole,
    };

    await FirebaseFirestore.instance.collection(tableMembership).add(bodyMap).then((doc) {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.membership_added_successfully;
      defaultResponse.responseData = doc.id;
      getMembershipList(isRefresh: true, createdById: createdBy);
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> updateMembership(
      {required membershipId,
      required membershipName,
      required amount,
      required period,
      required classLimit,
      required memberLimit,
      required bool recurringPackage,
      required description,
      required List<String> assignTrainer,
      required File? profile,
      required String currentUserId,
      required String userRole,
      required List<AttachmentListItem> membershipAttachment,
      required List<AttachmentListItem> removeAttachment,
      required String? imageUrl}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableMembership)
        .where(keyMembershipName, isEqualTo: membershipName)
        .where(keyCreatedBy, isEqualTo: currentUserId)
        .get();
    var currentDoc = query.docs.where((element) => element.id == membershipId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.membership_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (profile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderMembership, fileImage: profile);
    } else if (imageUrl != null) {
      profileURL = imageUrl;
    }
    List<String> attachmentList = [];

    if (membershipAttachment.isNotEmpty) {
      for (var i = 0; i < membershipAttachment.length; i++) {
        if (membershipAttachment[i].attachment != null) {
          var attachment =
              await FileUploadUtils().uploadDocument(folderName: folderMembershipAttachment, fileDoc: membershipAttachment[i].attachment!);
          attachmentList.add(attachment);
        } else if (membershipAttachment[i].attachmentNetwork != null) {
          attachmentList.add(membershipAttachment[i].attachmentNetwork!);
        }
      }
    }
    if (removeAttachment.isNotEmpty) {
      for (var i = 0; i < removeAttachment.length; i++) {
        if (removeAttachment[i].attachmentNetwork != null) {
          await FileUploadUtils().removeSingleFile(url: removeAttachment[i].attachmentNetwork);
        }
      }
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyMembershipName: membershipName,
      keyAmount: int.parse(amount),
      keyPeriod: int.parse(period),
      keyClassLimit: int.parse(classLimit),
      keyMemberLimit: int.parse(memberLimit),
      keyRecurringPackage: recurringPackage,
      keyDescription: description,
      keyProfile: profileURL,
      keyAssignedMembers: assignTrainer,
      keyAttachment: attachmentList,
      keyUserRole: userRole,
    };
    await FirebaseFirestore.instance
        .collection(tableMembership)
        .doc(membershipId)
        .update(
          bodyMap,
        )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.membership_updated_successfully;
     /* FirebaseInterface().sendFirebaseNotification(userIdList: assignTrainer,title: "$membershipName package assigned", body: 'You have assign '
          '$membershipName package for $period days',
          type:
          notificationMemberMembershipAssign);*/
      getMembershipList(createdById: currentUserId, isRefresh: true);
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> updateTrainerMembership(
      {required membershipId,
      required membershipName,
      required userRole,
      required amount,
      required period,
      required bool recurringPackage,
      required description,
      required File? profile,
      required List<String> assignMember,
      required String currentUserId,
      required List<AttachmentListItem> membershipAttachment,
      required List<AttachmentListItem> removeAttachment,
      required String? imageUrl}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableMembership)
        .where(keyMembershipName, isEqualTo: membershipName)
        .where(keyCreatedBy, isEqualTo: currentUserId)
        .get();
    var currentDoc = query.docs.where((element) => element.id == membershipId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.membership_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (profile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderMembership, fileImage: profile);
    } else if (imageUrl != null) {
      profileURL = imageUrl;
    }
    List<String> attachmentList = [];

    if (membershipAttachment.isNotEmpty) {
      for (var i = 0; i < membershipAttachment.length; i++) {
        if (membershipAttachment[i].attachment != null) {
          var attachment =
              await FileUploadUtils().uploadDocument(folderName: folderMembershipAttachment, fileDoc: membershipAttachment[i].attachment!);
          attachmentList.add(attachment);
        } else if (membershipAttachment[i].attachmentNetwork != null) {
          attachmentList.add(membershipAttachment[i].attachmentNetwork!);
        }
      }
    }
    if (removeAttachment.isNotEmpty) {
      for (var i = 0; i < removeAttachment.length; i++) {
        if (removeAttachment[i].attachmentNetwork != null) {
          await FileUploadUtils().removeSingleFile(url: removeAttachment[i].attachmentNetwork);
        }
      }
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyMembershipName: membershipName,
      keyAmount: int.parse(amount),
      keyPeriod: int.parse(period),
      keyRecurringPackage: recurringPackage,
      keyDescription: description,
      keyProfile: profileURL,
      keyUserRole: userRole,
      keyAssignedMembers: assignMember,
      keyAttachment: attachmentList
    };

    await FirebaseFirestore.instance
        .collection(tableMembership)
        .doc(membershipId)
        .update(
          bodyMap,
        )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.membership_updated_successfully;
      getMembershipList(createdById: currentUserId, isRefresh: true);
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<void> deleteMembership({required membershipId}) async {
    await FirebaseFirestore.instance.collection(tableMembership).doc(membershipId).delete();
    int index = membershipListItem.indexWhere((element) => element.id == membershipId);

    var profile = membershipListItem[index].get(keyProfile);
    List<String> attachmentList = List.castFrom(membershipListItem[index].get(keyAttachment) as List);

    await FileUploadUtils().removeSingleFile(url: profile);
    await FileUploadUtils().removeMultipleFile(urlList: attachmentList);

    if (index != -1) membershipListItem.removeAt(index);

    Fluttertoast.showToast(
        msg: AppLocalizations.of(navigatorKey.currentContext!)!.membership_deleted_successfully,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    notifyListeners();
  }

  Future<void> getMembershipList({bool isRefresh = false, required String createdById, String searchText = "", bool notify = true}) async {
    debugPrint("getMembershipList lastCreatedBy: $lastCreatedBy");
    debugPrint("getMembershipList currentUserId: $createdById");

    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if(userRole == userRoleMember){
      userRole = userRoleTrainer;
    }
    if(lastCreatedBy != createdById) {
      isRefresh = true;
      lastCreatedBy = createdById;
    }

    if (isRefresh) {
      membershipListItem.clear();
      allMembershipListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allMembershipListItem.isEmpty) {
          QuerySnapshot querySnapshot =
              await FirebaseFirestore.instance.collection(tableMembership)
                  .where(keyCreatedBy, isEqualTo: createdById)
                  .where(keyUserRole, isEqualTo: userRole)
                  .get();
          if (allMembershipListItem.isEmpty) {
            allMembershipListItem.addAll(querySnapshot.docs);
          }
        }
        membershipListItem.clear();
        for (var listItem in allMembershipListItem) {
          if (listItem[keyMembershipName] != null && listItem[keyMembershipName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            membershipListItem.add(listItem);
          }
        }
      } else if (membershipListItem.isEmpty) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(tableMembership)
            .where(keyCreatedBy, isEqualTo: createdById)
            .where(keyUserRole, isEqualTo: userRole)
            .get();

        membershipListItem.clear();
        membershipListItem.addAll(querySnapshot.docs);
        debugPrint("querySnapshot :${querySnapshot.size}");
      }
    } catch (e) {
      debugPrint("$e");
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> getPopularMembership({required String currentUserId}) async {
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if(userRole == userRoleMember){
      userRole = userRoleTrainer;
    }
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance.collection(tableMembership)
        .where(keyCreatedBy, isEqualTo: currentUserId)
    .where(keyUserRole, isEqualTo: userRole)
        .limit(3)
        .get();
    popularMembership.clear();

    popularMembership.addAll(querySnapshot.docs);
    debugPrint("getPopularMembership : ${popularMembership.length}");
    notifyListeners();
  }

  Future<void> getAssignMembershipList({required String membershipId}) async {
    debugPrint("getAssignMembership : $membershipId");
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if(userRole == userRoleMember){
      userRole = userRoleTrainer;
    }
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(tableMembership)
            .where(keyAssignedMembers, arrayContains: membershipId)
        .where(keyUserRole, isEqualTo: userRole)
            .get();
    assignPackageMembership.clear();
    assignPackageMembership.addAll(querySnapshot.docs);
    debugPrint("getAssignMembership : ${assignPackageMembership.length}");
    notifyListeners();
  }

  Future<String> getMembershipFromId({required String membershipId, required String currentUserId}) async {
    List<QueryDocumentSnapshot> membershipData = [];
    /*String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if(userRole == userRoleMember){
      userRole = userRoleTrainer;
    }*/
    try {
      if (membershipListItem.isEmpty || lastCreatedBy != currentUserId) {
        await getMembershipList(isRefresh: true, createdById: currentUserId);
        debugPrint("lastCreatedBy : $lastCreatedBy");
        lastCreatedBy = currentUserId;
      }
      membershipData = membershipListItem.where((element) => element.id == membershipId).toList();

      debugPrint("getMembershipFromId : ${membershipListItem.length}");
      debugPrint("getMembershipFromId : ${membershipData.length}");
    } catch (e) {
      debugPrint(e.toString());
    }
    return membershipData.isNotEmpty ? membershipData.first[keyMembershipName] : "";
  }

  Future<QueryDocumentSnapshot?> getMembershipDataFromId({required String membershipId, required String createdById}) async {
    List<QueryDocumentSnapshot> membershipData = [];

    try {
      if (membershipListItem.isEmpty || lastCreatedBy != createdById) {
        await getMembershipList(createdById: createdById, notify: false);
      }
      membershipData = membershipListItem.where((element) => element.id == membershipId).toList();

      debugPrint("getMembershipDataFromId : $membershipId");
      debugPrint("getMembershipDataFromId : ${membershipData.length}");
    } catch (e) {
      debugPrint(e.toString());
    }
    return membershipData.isNotEmpty ? membershipData.first : null;
  }

  Future<String> getMembershipListInSingleString({required List<String> membershipIdList, required String currentUserId}) async {
    var allMembershipString = "";
    if (membershipListItem.isEmpty) {
      await getMembershipList(isRefresh: true, createdById: currentUserId);
    }
    debugPrint("membershipListItem ${membershipListItem.length}");

    for (var i = 0; i < membershipIdList.length; i++) {
      debugPrint("all membership data ${membershipIdList[i]}");
      var membershipData = await getMembershipFromId(membershipId: membershipIdList[i], currentUserId: currentUserId);
      debugPrint("all membership data $membershipData");

      allMembershipString = allMembershipString + (membershipData.isNotEmpty ? "${allMembershipString.isNotEmpty ? ", " : ""}$membershipData" : "");
    }
    debugPrint('all Membership : $allMembershipString');
    return allMembershipString;
  }

  Future<DocumentSnapshot?> getSingleMembership({required membershipId}) async {
    var querySnapshot = await FirebaseFirestore.instance.collection(tableMembership)
        .doc(membershipId)
        .get();
    return querySnapshot.exists ? querySnapshot : null;
  }

void refreshList() {
    notifyListeners();
  }
}
