import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crossfit_gym_trainer/model/trainer_modal.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utils/shared_preferences_manager.dart';
import '../main.dart';
import '../model/default_response.dart';
import '../utils/file_upload_utils.dart';
import '../utils/firebase_interface.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'payment_history_provider.dart';

class TrainerProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> trainerListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> ownTrainerListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allTrainerListItem = <QueryDocumentSnapshot>[];
  String lastCreatedBy = "";

  Future<DefaultResponse> addTrainerFirebase({
    required TrainerModal trainerModal,
    required BuildContext context,
    required String currentDate,
    required QueryDocumentSnapshot membershipDoc,
    required String currentUser,
    required bool isWhatsappNumber,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if (userRole == userRoleMember) {
      userRole = userRoleTrainer;
    }
    debugPrint("email ${trainerModal.email}");
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableUser)
        .where(Filter.or(Filter(keyEmail, isEqualTo: trainerModal.email), Filter(keyPhone, isEqualTo: trainerModal.mobileNumber)))
        .get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.email_or_mobile_number_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (trainerModal.profilePhotoFile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderTrainerProfile, fileImage: trainerModal.profilePhotoFile!);
    }
    List<String> attachmentList = [];

    if (trainerModal.attachment != null && trainerModal.attachment!.isNotEmpty) {
      for (var i = 0; i < trainerModal.attachment!.length; i++) {
        if (trainerModal.attachment![i].attachment != null) {
          var attachment =
              await FileUploadUtils().uploadDocument(folderName: folderTrainerAttachment, fileDoc: trainerModal.attachment![i].attachment!);
          attachmentList.add(attachment);
        }
      }
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyName: trainerModal.name,
      keyDateOfBirth: trainerModal.birthDate,
      keyGender: trainerModal.gender,
      keySpecialization: trainerModal.specialization,
      keyCurrentMembership: trainerModal.currentMembership,
      keyMembershipTimestamp: trainerModal.membershipTimestamp,
      keyEmail: trainerModal.email,
      keyPassword: trainerModal.password,
      keyCountryCode: trainerModal.countryCode,
      keyPhone: trainerModal.mobileNumber,
      keyWpCountryCode: trainerModal.wpCountryCode,
      keyWpPhone: trainerModal.whatsappNumber,
      keyProfile: profileURL,
      keyAttachment: attachmentList,
      keyUserRole: userRoleTrainer,
      keyAccountStatus: accountAllowed,
      keyAddress: "",
      keyAge: "",
      keyHeight: "",
      keyWeight: "",
      keyCurrentDate: currentDate,
      keyCreatedAt: getCurrentDateTime(),
      keyCreatedBy: currentUser,
      keyIsWhatsappNumber: isWhatsappNumber,
    };

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: trainerModal.email.toString(),
      password: trainerModal.password.toString(),
    );
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;

    await FirebaseFirestore.instance.collection(tableUser).doc(uid).set(bodyMap).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.trainer_added_successfully;

      String subject = 'Welcome to the Gym Trainer App';
      String plainText = 'Hi ${trainerModal.name},'
          '\n\nBy joining us, you’ve already taken the first step on your fitness journey and we couldn’t be happier to walk with you on the path to achieve your health and fitness goals!'
          '\n\n Thanks & Regards';
      String htmlText = '<p>Hi <b>${trainerModal.name}</b>,</p>'
          '<p>By joining us, you’ve already taken the first step on your fitness journey and we couldn’t be happier to walk with you on the path to achieve your health and fitness goals!</p>'
          '<p>Thanks & Regards</p>';

      FirebaseInterface()
          .sendEmailNotification(emailList: [trainerModal.email.toString()], subject: subject, plainText: plainText, htmlText: htmlText);
      getTrainerList(isRefresh: true);
    }).then((doc) async {
      Map<String, dynamic> paymentBodyMap = <String, dynamic>{
        keyInvoiceNo: '${StaticData.invoicePrefix}${DateTime.now().day}${getRandomBetween(min: 1000, max: 9999)}',
        keyUserId: uid,
        keyMembershipId: membershipDoc.id,
        keyMembershipName: membershipDoc[keyMembershipName],
        keyAmount: membershipDoc[keyAmount],
        keyPeriod: membershipDoc[keyPeriod],
        keyCreatedBy: membershipDoc[keyCreatedBy],
        keyCreatedAt: trainerModal.membershipTimestamp,
        keyPaymentStatus: paymentUnPaid,
        keyPaymentType: "",
        keyExtendDate: 0,
        keyUserRole: userRole,
      };
      FirebaseFirestore.instance.collection(tablePaymentHistory).add(paymentBodyMap);
      Provider.of<PaymentHistoryProvider>(context, listen: false).createdByPaymentHistory.clear();
      await FirebaseInterface().addDefaultData(context: context, trainerId: uid);
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<void> getTrainerList({bool isRefresh = false, String searchText = ""}) async {
    if (isRefresh) {
      trainerListItem.clear();
      allTrainerListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allTrainerListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(tableUser).where(keyUserRole, isEqualTo: userRoleTrainer).get();
          allTrainerListItem.clear();
          allTrainerListItem.addAll(querySnapshot.docs);
        }
        trainerListItem.clear();
        for (var listItem in allTrainerListItem) {
          if (listItem[keyName] != null && listItem[keyName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            trainerListItem.add(listItem);
          }
        }
      } else if (trainerListItem.isEmpty) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(tableUser).where(keyUserRole, isEqualTo: userRoleTrainer).get();

        trainerListItem.clear();
        trainerListItem.addAll(querySnapshot.docs);
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<void> deleteTrainer({required trainerId}) async {
    await FirebaseFirestore.instance.collection(tableUser).doc(trainerId).delete();
    int index = trainerListItem.indexWhere((element) => element.id == trainerId);
    var email = trainerListItem[index].get(keyEmail);
    var password = trainerListItem[index].get(keyPassword);
    debugPrint("profileprofileprofileprofileprofile$email");
    debugPrint("profileprofileprofileprofileprofile$password");
    List<String> attachmentList = List.castFrom(trainerListItem[index].get(keyAttachment) as List);
    // await FileUploadUtils().removeSingleFile(url: profile);
    await FileUploadUtils().removeMultipleFile(urlList: attachmentList);

    if (index != -1) trainerListItem.removeAt(index);
    // getTrainerList(isRefresh: true);
    await FirebaseInterface().deleteTrainerAllData(trainerId: trainerId);
    await FirebaseInterface().deleteUser(email, password);
    Fluttertoast.showToast(
        msg: AppLocalizations.of(navigatorKey.currentContext!)!.trainer_deleted_successfully,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    notifyListeners();
  }

  Future<DefaultResponse> assignMembershipToTrainer(
      {required BuildContext context,
      required List<String> selectedTrainerList,
      required List<String> alreadySelectedTrainerList,
      required List<String> unSelectedTrainerList,
      required dynamic membershipDoc}) async {
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if (userRole == userRoleMember) {
      userRole = userRoleTrainer;
    }
    debugPrint("Member Count: ${selectedTrainerList.length}");
    debugPrint("TrainerList : $selectedTrainerList");

    DefaultResponse defaultResponse = DefaultResponse();

    for (int i = 0; i < selectedTrainerList.length; i++) {
      if (!alreadySelectedTrainerList.contains(selectedTrainerList[i])) {
        var currentDateTime = getCurrentDateTime();

        await FirebaseFirestore.instance
            .collection(tableUser)
            .doc(selectedTrainerList[i])
            .set({keyCurrentMembership: membershipDoc.id, keyMembershipTimestamp: currentDateTime}, SetOptions(merge: true));

        Map<String, dynamic> paymentBodyMap = <String, dynamic>{
          keyInvoiceNo: '${StaticData.invoicePrefix}${DateTime.now().day}${getRandomBetween(min: 1000, max: 9999)}',
          keyUserId: selectedTrainerList[i],
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
    for (int i = 0; i < unSelectedTrainerList.length; i++) {
      await FirebaseFirestore.instance
          .collection(tableUser)
          .doc(unSelectedTrainerList[i])
          .set({keyCurrentMembership: "", keyMembershipTimestamp: null}, SetOptions(merge: true));
    }
    await FirebaseFirestore.instance
        .collection(tableMembership)
        .doc(membershipDoc.id)
        .set({keyMemberCount: selectedTrainerList.length, keyAssignedMembers: selectedTrainerList}, SetOptions(merge: true));
    defaultResponse.statusCode = onSuccess;
    defaultResponse.status = true;
    defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.package_assigned_successfully;
    FirebaseInterface().sendFirebaseNotification(
        userIdList: selectedTrainerList,
        title: "${membershipDoc[keyMembershipName]} assigned",
        body: 'You have assign '
            '${membershipDoc[keyMembershipName]} for ${membershipDoc[keyPeriod]} Days',
        type: notificationTrainerPackageAssign);
    List<String> emailList = [];
    for (int i = 0; i < selectedTrainerList.length; i++) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(tableUser).doc(selectedTrainerList[i]).get();
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
    FirebaseInterface().sendEmailNotification(emailList: emailList, subject: subject, plainText: plainText, htmlText: htmlText);
    return defaultResponse;
  }

  Future<DefaultResponse> updateTrainer({
    required trainerId,
    required TrainerModal trainerModal,
    required QueryDocumentSnapshot membershipDoc,
    required membershipUpdated,
    required String oldPassword,
    required bool isPasswordUpdate,
    required bool isWhatsappNumber,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if (userRole == userRoleMember) {
      userRole = userRoleTrainer;
    }

    QuerySnapshot query = await FirebaseFirestore.instance.collection(tableUser).where(keyEmail, isEqualTo: trainerModal.email).get();
    var currentDoc = query.docs.where((element) => element.id == trainerId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.trainer_already_exist;
      return defaultResponse;
    }

    String profileURL = "";
    if (trainerModal.profilePhotoFile != null && trainerModal.profilePhoto != null) {
      profileURL = await FileUploadUtils()
          .uploadAndUpdateImage(folderName: folderWorkoutCategory, fileImage: trainerModal.profilePhotoFile!, oldUrl: trainerModal.profilePhoto!);
    } else if (trainerModal.profilePhotoFile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderWorkoutCategory, fileImage: trainerModal.profilePhotoFile!);
    } else if (trainerModal.profilePhoto != null) {
      profileURL = trainerModal.profilePhoto!;
    }

    List<String> attachmentList = [];

    if (trainerModal.attachment != null && trainerModal.attachment!.isNotEmpty) {
      for (var i = 0; i < trainerModal.attachment!.length; i++) {
        if (trainerModal.attachment![i].attachment != null && trainerModal.attachment![i].attachmentNetwork != null) {
          var attachment = await FileUploadUtils().uploadAndUpdateDocument(
              folderName: folderTrainerAttachment,
              fileDoc: trainerModal.attachment![i].attachment!,
              oldUrl: trainerModal.attachment![i].attachmentNetwork!);
          attachmentList.add(attachment);
        } else if (trainerModal.attachment![i].attachment != null) {
          var attachment =
              await FileUploadUtils().uploadDocument(folderName: folderTrainerAttachment, fileDoc: trainerModal.attachment![i].attachment!);
          attachmentList.add(attachment);
        } else if (trainerModal.attachment![i].attachmentNetwork != null) {
          var attachment = trainerModal.attachment![i].attachmentNetwork!;
          attachmentList.add(attachment);
        }
      }
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyName: trainerModal.name,
      keyDateOfBirth: trainerModal.birthDate,
      keyGender: trainerModal.gender,
      keySpecialization: trainerModal.specialization,
      keyCurrentMembership: trainerModal.currentMembership,
      keyMembershipTimestamp: trainerModal.membershipTimestamp,
      keyEmail: trainerModal.email,
      if (isPasswordUpdate) keyPassword: trainerModal.password,
      keyCountryCode: trainerModal.countryCode,
      keyPhone: trainerModal.mobileNumber,
      keyWpCountryCode: trainerModal.wpCountryCode,
      keyWpPhone: trainerModal.whatsappNumber,
      keyProfile: profileURL,
      keyAttachment: attachmentList,
      keyIsWhatsappNumber: isWhatsappNumber,
    };
    await FirebaseFirestore.instance
        .collection(tableUser)
        .doc(trainerId)
        .update(
          bodyMap,
        )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.trainer_updated_successfully;
      if (membershipUpdated) {
        Map<String, dynamic> paymentBodyMap = <String, dynamic>{
          keyInvoiceNo: '${StaticData.invoicePrefix}${DateTime.now().day}${getRandomBetween(min: 1000, max: 9999)}',
          keyUserId: trainerId,
          keyMembershipId: membershipDoc.id,
          keyMembershipName: membershipDoc[keyMembershipName],
          keyAmount: membershipDoc[keyAmount],
          keyPeriod: membershipDoc[keyPeriod],
          keyCreatedBy: membershipDoc[keyCreatedBy],
          keyCreatedAt: trainerModal.membershipTimestamp,
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
      UserCredential? currentUser = await FirebaseAuth.instance.signInWithEmailAndPassword(password: oldPassword, email: trainerModal.email!);
      currentUser.user?.updatePassword(trainerModal.trainerPassword!);
      debugPrint('currentPassword : ${trainerModal.trainerPassword!}');
    }
    return defaultResponse;
  }

  Future<DefaultResponse> updateTrainerProfile({
    required trainerId,
    required TrainerModal trainerModal,
    required String address,
    required String name,
    required String state,
    required String city,
    required String pincode,
    required String countryShortName,
    required String countryCodeName,
    required String oldPassword,
    required bool isPasswordUpdate,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    final SharedPreferencesManager preference = SharedPreferencesManager();

    QuerySnapshot query = await FirebaseFirestore.instance.collection(tableUser).where(keyEmail, isEqualTo: trainerModal.email).get();
    var currentDoc = query.docs.where((element) => element.id == trainerId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.trainer_already_exist;
      return defaultResponse;
    }

    String profileURL = "";
    if (trainerModal.profilePhotoFile != null && trainerModal.profilePhoto != null) {
      profileURL = await FileUploadUtils()
          .uploadAndUpdateImage(folderName: folderWorkoutCategory, fileImage: trainerModal.profilePhotoFile!, oldUrl: trainerModal.profilePhoto!);
    } else if (trainerModal.profilePhotoFile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderWorkoutCategory, fileImage: trainerModal.profilePhotoFile!);
    } else if (trainerModal.profilePhoto != null) {
      profileURL = trainerModal.profilePhoto!;
    }
    preference.setValue(
      prefProfile,
      profileURL,
    );
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyDateOfBirth: trainerModal.birthDate,
      keySpecialization: trainerModal.specialization,
      if (isPasswordUpdate) keyPassword: trainerModal.password,
      keyCountryCode: trainerModal.countryCode,
      keyPhone: trainerModal.mobileNumber,
      keyProfile: profileURL,
      keyAddress: address,
      keyState: state,
      keyCity: city,
      keyCountrySortName: countryShortName,
      keyCountryCodeName: countryCodeName,
      keyZipCode: pincode,
      keyName: name,
    };
    await FirebaseFirestore.instance
        .collection(tableUser)
        .doc(trainerId)
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
      UserCredential? currentUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
        password: oldPassword,
        email: trainerModal.trainerEmail!,
      );
      currentUser.user?.updatePassword(trainerModal.trainerPassword!);
      debugPrint('currentPassword : $oldPassword');
    }
    return defaultResponse;
  }

  Future<DefaultResponse> updateAdminProfile({
    required userId,
    required String address,
    required String city,
    required String state,
    required String zipcode,
    required String email,
    required String name,
    required String oldEmail,
    required String mobileNumber,
    required String countryCode,
    required String? profilePhoto,
    File? profilePhotoFile,
    required String newPassword,
    required String currentPassword,
    required bool isPasswordUpdate,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance.collection(tableUser).where(keyEmail, isEqualTo: email).get();
    var currentDoc = query.docs.where((element) => element.id == userId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.user_already_exist;
      return defaultResponse;
    }

    String profileURL = "";
    if (profilePhotoFile != null && profilePhoto != null) {
      profileURL = await FileUploadUtils().uploadAndUpdateImage(folderName: folderWorkoutCategory, fileImage: profilePhotoFile, oldUrl: profilePhoto);
    } else if (profilePhotoFile != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderWorkoutCategory, fileImage: profilePhotoFile);
    } else if (profilePhoto != null) {
      profileURL = profilePhoto;
    }
    SharedPreferencesManager().setValue(prefProfile, profileURL);

    Map<String, dynamic> bodyMap = <String, dynamic>{
      if (isPasswordUpdate) keyPassword: newPassword,
      keyCountryCode: countryCode,
      keyPhone: mobileNumber,
      keyProfile: profileURL,
      keyAddress: address,
      keyCity: city,
      keyState: state,
      keyZipCode: zipcode,
      keyEmail: email,
      keyName: name,
    };

    await FirebaseFirestore.instance
        .collection(tableUser)
        .doc(userId)
        .update(
          bodyMap,
        )
        .whenComplete(() {
      debugPrint("updateAdminProfile : 1");
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.profile_update_successfully;
    }).catchError((e) {
      debugPrint("updateAdminProfile : 2");
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });

    bool emailUpdate = currentPassword.isNotEmpty && oldEmail != email;
    if (emailUpdate || isPasswordUpdate) {
      debugPrint("updateAdminProfile : 3");
      UserCredential? currentUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: oldEmail,
        password: currentPassword,
      );
      if (emailUpdate) {
        debugPrint("updateAdminProfile : 4");
        currentUser.user?.updateEmail(email);
      }
      if (isPasswordUpdate) {
        debugPrint("updateAdminProfile : 5");
        currentUser.user?.updatePassword(newPassword);
      }
    }
    debugPrint("updateAdminProfile : 6");
    return defaultResponse;
  }

  Future<DocumentSnapshot> getSingleTrainer({required userId}) async {
    var querySnapshot = await FirebaseFirestore.instance.collection(tableUser).doc(userId).get();
    return querySnapshot;
  }

  Future<DocumentSnapshot?> getTrainerFromId({required String memberId, required String createdBy}) async {
    List<QueryDocumentSnapshot> trainerData = [];

    try {
      if (ownTrainerListItem.isEmpty || lastCreatedBy != createdBy) {
        await getOwnTrainer(createdBy: createdBy);
        debugPrint("lastCreatedBy : $lastCreatedBy");
        lastCreatedBy = createdBy;
      }
      trainerData = ownTrainerListItem.where((element) => element.id == memberId).toList();

      debugPrint("getMembershipFromId : ${ownTrainerListItem.length}");
      debugPrint("getMembershipFromId : ${trainerData.length}");
    } catch (e) {
      debugPrint(e.toString());
    }
    return trainerData.isNotEmpty ? trainerData.first : null;
  }

  Future<List<QueryDocumentSnapshot>> getOwnTrainer({required String createdBy}) async {
    lastCreatedBy = createdBy;
    ownTrainerListItem.clear();
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(tableUser)
        .where(keyCreatedBy, isEqualTo: createdBy)
        .where(keyUserRole, isEqualTo: userRoleTrainer)
        .get();
    ownTrainerListItem.addAll(querySnapshot.docs);
    notifyListeners();
    debugPrint("ownTrainerListItem : ${ownTrainerListItem.length}");
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getAllTrainerList() async {
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance.collection(tableUser).where(keyUserRole, isEqualTo: userRoleTrainer).get();
    debugPrint("TrainerList querySnapshot ${querySnapshot.size}");
    return querySnapshot.docs;
  }

  /// *************************************Trainer Setting *******************************************

  // add strip payment Method
  Future<DefaultResponse> addPayment({
    required String trainerId,
    required String? paymentType,
    required String? secretKey,
    required String? publishableKey,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(tableUser).doc(trainerId).get();
    if (documentSnapshot.exists && getDocumentValue(key: keyPaymentType, documentSnapshot: documentSnapshot) == paymentType) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.payment_type_already_selected;
      return defaultResponse;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyPaymentType: paymentType,
      keySecretKey: secretKey,
      keyPublishable: publishableKey,
    };

    await FirebaseFirestore.instance.collection(tableUser).doc(trainerId).set(bodyMap, SetOptions(merge: true)).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.payment_type_added_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  // add paypal payment method
  Future<DefaultResponse> addPayPal({
    required String trainerId,
    required String? paymentType,
    required String? secretKey,
    required String? clientId,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(tableUser).doc(trainerId).get();
    if (documentSnapshot.exists && getDocumentValue(key: keyPaymentType, documentSnapshot: documentSnapshot) == paymentType) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.payment_type_already_selected;
      return defaultResponse;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyPaymentType: paymentType,
      keyPaypalSecretKey: secretKey,
      keyPaypalClientId: clientId,
    };

    await FirebaseFirestore.instance.collection(tableUser).doc(trainerId).set(bodyMap, SetOptions(merge: true)).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.payment_type_added_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  // add Cash-offline payment method
  Future<DefaultResponse> addCashPayment({
    required String trainerId,
    required String? paymentType,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(tableUser).doc(trainerId).get();
    if (documentSnapshot.exists && getDocumentValue(key: keyPaymentType, documentSnapshot: documentSnapshot) == paymentType) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.payment_type_already_selected;
      return defaultResponse;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyPaymentType: paymentType,
    };

    await FirebaseFirestore.instance.collection(tableUser).doc(trainerId).set(bodyMap, SetOptions(merge: true)).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.payment_type_added_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> updateTrainerByKeyValue({
    required trainerId,
    required String key,
    required dynamic value,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    debugPrint("default response : $trainerId");

    Map<String, dynamic> bodyMap = <String, dynamic>{
      key: value,
    };

    await FirebaseFirestore.instance.collection(tableUser).doc(trainerId).set(bodyMap, SetOptions(merge: true)).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.setting_update_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }
}
