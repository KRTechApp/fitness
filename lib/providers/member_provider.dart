import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/model/default_response.dart';
import 'package:crossfit_gym_trainer/model/user_modal.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utils/shared_preferences_manager.dart';
import '../main.dart';
import '../utils/file_upload_utils.dart';
import '../utils/firebase_interface.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'payment_history_provider.dart';

class MemberProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> myMemberListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> memberListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allMemberListItem = <QueryDocumentSnapshot>[];
  String lastCreatedBy = "";

  /*Add New member in trainer account*/
  Future<DefaultResponse> addMember(
      {required UserModal userModal,
      File? profile,
      goal,
      required BuildContext context,
      required String currentDate,
      required QueryDocumentSnapshot membershipDoc,
      required String currentUser,
      required String wpCountryCode,
      required String wpNumber,
      required bool isWhatsappNumber}) async {
    DefaultResponse defaultResponse = DefaultResponse();
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if(userRole == userRoleMember){
      userRole = userRoleTrainer;
    }

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableUser)
        .where(
            Filter.or(Filter(keyEmail, isEqualTo: userModal.email), Filter(keyPhone, isEqualTo: userModal.phoneNumber)))
        .get();
    debugPrint('queryLength ${query.size}');
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.email_or_mobile_number_already_exist;
      debugPrint('query.docs.length${query.docs.length}');
      return defaultResponse;
    }
    String profileURL = "";
    if (profile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderMemberProfile, fileImage: profile);
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyEmail: userModal.email,
      keyPassword: userModal.password,
      keyGender: userModal.gender,
      keyAge: userModal.age,
      keyHeight: userModal.height,
      keyWeight: userModal.weight,
      keyName: userModal.name,
      keyCurrentMembership: userModal.currentMembership,
      keyMembershipTimestamp: userModal.membershipTimestamp,
      keyCountryCode: userModal.countryCode,
      keyPhone: userModal.phoneNumber,
      keyDateOfBirth: userModal.birthDate,
      keyAddress: userModal.address,
      keyGoal: goal,
      keyAccountStatus: accountAllowed,
      keyWpCountryCode: wpCountryCode,
      keyWpPhone: wpNumber,
      keyUserRole: userRoleMember,
      keyProfile: profileURL,
      keyCurrentDate: currentDate,
      keyCreatedBy: currentUser,
      keyCreatedAt: getCurrentDateTime(),
      keyMemberId: '${StaticData.memberIdPrefix}${DateTime.now().day}${getRandomBetween(min: 1000, max: 9999)}',
      keyIsWhatsappNumber: isWhatsappNumber,
    };

    bool userCreated = true;
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: userModal.email.toString(),
      password: userModal.password.toString(),
    )
        .catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
      userCreated = false;
      return e;
    });
    if (!userCreated) {
      return defaultResponse;
    }
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;

    await FirebaseFirestore.instance.collection(tableUser).doc(uid).set(bodyMap).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.member_added_successfully;
      /*FirebaseInterface().sendFirebaseNotification(userIdList: assignTrainer,title: "${membershipDoc[keyMembershipName]} package assigned", body: 'You have assign '
          '${membershipDoc[keyMembershipName]} package for ${membershipDoc[keyPeriod]} days',
          type:
          notificationTrainerPackageAssign);*/
      String subject = 'Welcome to the Gym Trainer App';
      String plainText = 'Hi ${userModal.name},'
          '\n\nBy joining us, you’ve already taken the first step on your fitness journey and we couldn’t be happier to walk with you on the path to achieve your health and fitness goals!'
          '\n\n Thanks & Regards';
      String htmlText = '<p>Hi <b>${userModal.name}</b>,</p>'
          '<p>By joining us, you’ve already taken the first step on your fitness journey and we couldn’t be happier to walk with you on the path to achieve your health and fitness goals!</p>'
          '<p>Thanks & Regards</p>';

      FirebaseInterface().sendEmailNotification(
          emailList: [userModal.email.toString()], subject: subject, plainText: plainText, htmlText: htmlText);
      getMemberOfTrainer(
        createdById: currentUser,
        searchText: "",
        isRefresh: true,
      );
      Provider.of<PaymentHistoryProvider>(context, listen: false).createdByPaymentHistory.clear();
    }).then((doc) async {
      /*Generate payment log in firebase using assigned membership*/
      Map<String, dynamic> paymentBodyMap = <String, dynamic>{
        keyInvoiceNo: '${StaticData.invoicePrefix}${DateTime.now().day}${getRandomBetween(min: 1000, max: 9999)}',
        keyUserId: uid,
        keyMembershipId: membershipDoc.id,
        keyMembershipName: membershipDoc[keyMembershipName],
        keyAmount: membershipDoc[keyAmount],
        keyPeriod: membershipDoc[keyPeriod],
        keyCreatedBy: membershipDoc[keyCreatedBy],
        keyCreatedAt: userModal.membershipTimestamp,
        keyPaymentStatus: paymentUnPaid,
        keyPaymentType: "",
        keyExtendDate: 0,
        keyUserRole: userRole,
      };
      await FirebaseFirestore.instance.collection(tablePaymentHistory).add(paymentBodyMap);

      /*Assign free membership to member*/
      var querySnapshot = await FirebaseFirestore.instance
          .collection(tableWorkout)
          .where(keyCreatedBy, isEqualTo: currentUser)
          .where(keyWorkoutType, isEqualTo: workoutTypeFree)
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        await FirebaseFirestore.instance.collection(tableWorkout).doc(querySnapshot.docs[i].id).update({
          keySelectedMember: FieldValue.arrayUnion([uid]),
          keyMemberCount: querySnapshot.docs.length
        });
      }
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  //For Member detail Update
  Future<DefaultResponse> updateMember({
    required String memberId,
    required File? profile,
    required String name,
    required String email,
    required String oldPassword,
    required bool isPasswordUpdate,
    required String newPassword,
    required String phone,
    required String phoneCountryCode,
    required String whatsappCountryCode,
    required String whatsappPhone,
    required String gender,
    required int dateofBirth,
    required String age,
    required String height,
    required String weight,
    required String address,
    required String goal,
    required String currentMembership,
    required int membershipTimestamp,
    required membershipUpdated,
    required String? imageUrl,
    required QueryDocumentSnapshot membershipDoc,
    required bool isWhatsappNumber,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if(userRole == userRoleMember){
      userRole = userRoleTrainer;
    }
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tableUser).where(keyEmail, isEqualTo: email).get();
    var currentDoc = query.docs.where((element) => element.id == memberId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.member_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (profile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderMemberProfile, fileImage: profile);
    } else if (imageUrl != null) {
      profileURL = imageUrl;
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyProfile: profileURL,
      keyName: name,
      keyEmail: email,
      if (isPasswordUpdate) keyPassword: newPassword,
      keyCountryCode: phoneCountryCode,
      keyPhone: phone,
      keyWpCountryCode: whatsappCountryCode,
      keyWpPhone: whatsappPhone,
      keyGender: gender,
      keyDateFormat: dateofBirth,
      keyAge: age,
      keyHeight: height,
      keyWeight: weight,
      keyAddress: address,
      keyGoal: goal,
      keyCurrentMembership: currentMembership,
      keyMembershipTimestamp: membershipTimestamp,
      keyIsWhatsappNumber: isWhatsappNumber,
    };
    await FirebaseFirestore.instance
        .collection(tableUser)
        .doc(memberId)
        .update(
          bodyMap,
        )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.member_update_successfully;

      if (membershipUpdated) {
        Map<String, dynamic> paymentBodyMap = <String, dynamic>{
          keyInvoiceNo: '${StaticData.invoicePrefix}${DateTime.now().day}${getRandomBetween(min: 1000, max: 9999)}',
          keyUserId: memberId,
          keyMembershipId: membershipDoc.id,
          keyMembershipName: membershipDoc[keyMembershipName],
          keyAmount: membershipDoc[keyAmount],
          keyPeriod: membershipDoc[keyPeriod],
          keyCreatedBy: membershipDoc[keyCreatedBy],
          keyCreatedAt: membershipTimestamp,
          keyPaymentStatus: paymentUnPaid,
          keyPaymentType: "",
          keyExtendDate: 0,
          keyUserRole: userRole,
        };
        FirebaseFirestore.instance.collection(tablePaymentHistory).add(paymentBodyMap);
      }
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });

    if (isPasswordUpdate) {
      UserCredential? currentUser =
          await FirebaseAuth.instance.signInWithEmailAndPassword(password: oldPassword, email: email);
      currentUser.user?.updatePassword(newPassword);
      debugPrint('currentPassword : $newPassword');
    }
    return defaultResponse;
  }

  Future<void> getMemberList({bool isRefresh = false, String searchText = ""}) async {
    if (isRefresh) {
      memberListItem.clear();
      allMemberListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allMemberListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableUser)
              .where(keyUserRole, isEqualTo: userRoleMember)
              .get();
          allMemberListItem.clear();
          allMemberListItem.addAll(querySnapshot.docs);
        }
        memberListItem.clear();
        for (var listItem in allMemberListItem) {
          if (listItem[keyName] != null &&
              listItem[keyName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            memberListItem.add(listItem);
          }
        }
        debugPrint("getTrainerList allMemberListItem :${allMemberListItem.length}");
      } else if (memberListItem.isEmpty) {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection(tableUser).where(keyUserRole, isEqualTo: userRoleMember).get();
        memberListItem.clear();
        memberListItem.addAll(querySnapshot.docs);
      }
    } catch (e) {
      debugPrint("$e");
    }
    debugPrint("getmemberListItem :${memberListItem.length}");
    notifyListeners();
  }

  Future<void> deleteMember({required memberId}) async {
    await FirebaseFirestore.instance.collection(tableUser).doc(memberId).delete();
    int index = memberListItem.indexWhere((element) => element.id == memberId);
    if (index != -1) memberId.removeAt(index);
    notifyListeners();
  }

  Future<void> getFilterMemberList({required String currentUserId, required bool orderBy}) async {
    memberListItem.clear();
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(tableUser)
        .where(keyCreatedBy, isEqualTo: currentUserId)
        .orderBy(keyCreatedAt, descending: orderBy)
        .get();
    memberListItem.addAll(querySnapshot.docs);
    debugPrint('ID: $currentUserId');
    notifyListeners();
  }

  Future<DocumentSnapshot?> getMemberFromId({required String userId, required String createdById}) async {
    List<QueryDocumentSnapshot> memberData = [];

    try {
      if (myMemberListItem.isEmpty || lastCreatedBy != createdById) {
        await getMemberOfTrainer(createdById: createdById);
      }
      memberData = myMemberListItem.where((element) => element.id == userId).toList();
    } catch (e) {
      debugPrint(e.toString());
    }
    return memberData.isNotEmpty ? memberData.first : null;
  }

  Future<void> getMemberOfTrainer({required String createdById, bool isRefresh = false, String searchText = ""}) async {
    bool orderBy = false;
    debugPrint("getMemberOfTrainer lastCreatedBy : $lastCreatedBy");
    debugPrint("getMemberOfTrainer createdById : $createdById");
    if (lastCreatedBy != createdById) {
      isRefresh = true;
      lastCreatedBy = createdById;
    }
    String key = keyMembershipTimestamp;
    if (StaticData.orderBy == "old_first") {
      key = keyMembershipTimestamp;
      orderBy = false;
    } else if (StaticData.orderBy == "az") {
      key = keyName;
      orderBy = false;
    } else if (StaticData.orderBy == "za") {
      key = keyName;
      orderBy = true;
    } else {
      key = keyMembershipTimestamp;
      orderBy = true;
    }
    debugPrint("orderBy :$orderBy key :$key");
    if (isRefresh) {
      myMemberListItem.clear();
      allMemberListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allMemberListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableUser)
              .where(keyCreatedBy, isEqualTo: createdById)
              .where(keyUserRole, isEqualTo: userRoleMember)
              .orderBy(key, descending: orderBy)
              .get();
          allMemberListItem.clear();
          allMemberListItem.addAll(querySnapshot.docs);
          debugPrint('allMemberListItem1${querySnapshot.docs.length}');
        }
        myMemberListItem.clear();
        for (var listItem in allMemberListItem) {
          if (listItem[keyName] != null &&
              listItem[keyName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            myMemberListItem.add(listItem);
          }
        }
      } else {
        QuerySnapshot querySnapshot;
        if (myMemberListItem.isEmpty) {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableUser)
              .where(keyCreatedBy, isEqualTo: createdById)
              .where(keyUserRole, isEqualTo: userRoleMember)
              .orderBy(key, descending: orderBy)
              .get();
          myMemberListItem.clear();
          myMemberListItem.addAll(querySnapshot.docs);
          debugPrint('allMemberListItem2${querySnapshot.docs.length}');
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<DocumentSnapshot> getSelectedMember({required memberId}) async {
    var querySnapshot = await FirebaseFirestore.instance.collection(tableUser).doc(memberId).get();
    return querySnapshot;
  }

  Future<DefaultResponse> updateDataByKeyValue({
    required userId,
    required String key,
    required dynamic value,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    debugPrint("default response : $userId");

    Map<String, dynamic> bodyMap = <String, dynamic>{
      key: value,
    };

    await FirebaseFirestore.instance
        .collection(tableUser)
        .doc(userId)
        .update(
          bodyMap,
        )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.user_updated_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> assignMembershipToMember(
      {required List<String> selectedMemberList,
      required List<String> alreadySelectedMemberList,
      required List<String> unSelectedMemberList,
      required dynamic membershipDoc}) async {
    DefaultResponse defaultResponse = DefaultResponse();
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if(userRole == userRoleMember){
      userRole = userRoleTrainer;
    }

    for (int i = 0; i < selectedMemberList.length; i++) {
      if (!alreadySelectedMemberList.contains(selectedMemberList[i])) {
        var currentDateTime = getCurrentDateTime();
        debugPrint('selectedMemberList :${selectedMemberList.length}');
        debugPrint('currentDateTime :$currentDateTime');

        await FirebaseFirestore.instance.collection(tableUser).doc(selectedMemberList[i]).set(
            {keyCurrentMembership: membershipDoc.id, keyMembershipTimestamp: currentDateTime}, SetOptions(merge: true));
        debugPrint('currentDateTime :$currentDateTime');

        Map<String, dynamic> paymentBodyMap = <String, dynamic>{
          keyInvoiceNo: '${StaticData.invoicePrefix}${DateTime.now().day}${getRandomBetween(min: 1000, max: 9999)}',
          keyUserId: selectedMemberList[i],
          keyMembershipId: membershipDoc.id,
          keyMembershipName: membershipDoc[keyMembershipName],
          keyAmount: membershipDoc[keyAmount],
          keyPeriod: membershipDoc[keyPeriod],
          keyCreatedBy: membershipDoc[keyCreatedBy],
          keyCreatedAt: currentDateTime,
          keyPaymentStatus: paymentUnPaid,
          keyPaymentType: "",
          keyExtendDate: 0,
          keyUserRole: userRole,
        };
        await FirebaseFirestore.instance.collection(tablePaymentHistory).add(paymentBodyMap);
      }
    }
    for (int i = 0; i < unSelectedMemberList.length; i++) {
      await FirebaseFirestore.instance
          .collection(tableUser)
          .doc(unSelectedMemberList[i])
          .set({keyCurrentMembership: "", keyMembershipTimestamp: null}, SetOptions(merge: true));
    }
    await FirebaseFirestore.instance.collection(tableMembership).doc(membershipDoc.id).set(
        {keyMemberCount: selectedMemberList.length, keyAssignedMembers: selectedMemberList}, SetOptions(merge: true));
    defaultResponse.statusCode = onSuccess;
    defaultResponse.status = true;
    defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.membership_assigned_successfully;
    FirebaseInterface().sendFirebaseNotification(
        userIdList: selectedMemberList,
        title: "${membershipDoc[keyMembershipName]} package assigned",
        body: 'You have assign '
            '${membershipDoc[keyMembershipName]} package for ${membershipDoc[keyPeriod]} days',
        type: notificationMemberMembershipAssign);
    List<String> emailList = [];
    for (int i = 0; i < selectedMemberList.length; i++) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection(tableUser).doc(selectedMemberList[i]).get();
      String email = getDocumentValue(documentSnapshot: userDoc, key: keyEmail, defaultValue: "");
      if (email.isNotEmpty) {
        emailList.add(email);
      }
    }
    String subject = 'Gym Membership Assignment';
    String plainText = 'Hello,'
        '\n\nWe are pleased to inform you that your ${membershipDoc[keyMembershipName]} membership has been successfully assigned.'
        '\nGet ready to embark on an incredible fitness journey with us!'
        '\nPlease visit our facility to collect your membership card and gain access to our state-of-the-art equipment and expert guidance.'
        '\nWe look forward to helping you achieve your fitness goals!'
        '\n\nBest regards,'
        '\n\nGym Trainer App';
    String htmlText = '<p>Hello,</p>'
        '<p>We are pleased to inform you that your ${membershipDoc[keyMembershipName]} membership has been successfully assigned.</p>'
        '<p>Get ready to embark on an incredible fitness journey with us!</p>'
        '<p>Please visit our facility to collect your membership card and gain access to our state-of-the-art equipment and expert guidance.</p>'
        '<p>We look forward to helping you achieve your fitness goals!</p>'
        '<p>Best regards,</p>'
        '<p>Gym Trainer App</p>';
    FirebaseInterface()
        .sendEmailNotification(emailList: emailList, subject: subject, plainText: plainText, htmlText: htmlText);
    return defaultResponse;
  }

  Future<DefaultResponse> matchUserAndPassword({
    required String userId,
    required String password,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    var documentSnapshot = await FirebaseFirestore.instance.collection(tableUser).doc(userId).get();

    if (documentSnapshot[keyPassword] == password) {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.user_password_matched;
    } else {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.user_password_not_matched;
    }
    return defaultResponse;
  }

  Future<DefaultResponse> updateMemberProfile({
    required userId,
    required String address,
    required String countryCode,
    required int dateOfBirth,
    required String phone,
    required String goal,
    required String age,
    required String weight,
    required String height,
    required String email,
    required String name,
    required String city,
    required String pincode,
    required String state,
    required String? oldUrl,
    required File? profile,
    required String currentPassword,
    required String newPassword,
    required String countryShortName,
    required String countryCodeName,
    required bool isPasswordUpdate,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    final SharedPreferencesManager preference = SharedPreferencesManager();

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tableUser).where(keyEmail, isEqualTo: email).get();
    var currentDoc = query.docs.where((element) => element.id == userId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.member_already_exist;
      return defaultResponse;
    }

    String profileURL = "";
    if (profile != null) {
      profileURL = await FileUploadUtils()
          .uploadAndUpdateImage(folderName: folderMemberProfile, fileImage: profile, oldUrl: oldUrl!);
    } else if (profile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderMemberProfile, fileImage: profile);
    } else if (oldUrl != null) {
      profileURL = oldUrl;
    }
    preference.setValue(
      prefProfile,
      profileURL,
    );
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyDateOfBirth: dateOfBirth,
      keyPhone: phone,
      if (isPasswordUpdate) keyPassword: newPassword,
      keyCountryCode: countryCode,
      keyName: name,
      keyAddress: address,
      keyGoal: goal,
      keyCity: city,
      keyAge: age,
      keyWeight: weight,
      keyHeight: height,
      keyState: state,
      keyZipCode: pincode,
      keyCountrySortName: countryShortName,
      keyCountryCodeName: countryCodeName,
      keyProfile: profileURL,
    };
    await FirebaseFirestore.instance
        .collection(tableUser)
        .doc(userId)
        .update(
          bodyMap,
        )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.profile_update_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });

    if (isPasswordUpdate) {
      UserCredential? currentUser =
          await FirebaseAuth.instance.signInWithEmailAndPassword(password: currentPassword, email: email);
      currentUser.user?.updatePassword(newPassword);
      debugPrint('currentPassword : $currentPassword');
    }
    return defaultResponse;
  }
}
