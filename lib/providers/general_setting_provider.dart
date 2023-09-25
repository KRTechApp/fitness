import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model/default_response.dart';
import '../utils/file_upload_utils.dart';
import '../utils/tables_keys_values.dart';

class SettingProvider with ChangeNotifier {

  QueryDocumentSnapshot? generalSettingItem;

  Future<DefaultResponse> addSetting({
    required String? gymName,
    required String? startingYear,
    required String? gymAddress,
    required String? mobileNumber,
    required String? gymEmail,
    required File? gymLogo,
    required String? imageUrl,
    required String memberPrefix,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(tableGeneralSetting).where(keyGymName, isEqualTo: gymName).get();

    if (querySnapshot.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.gym_already_exist;
      return defaultResponse;
    }

    String profileURL = "";
    if (gymLogo != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderWorkoutCategory, fileImage: gymLogo);
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyGymName: gymName,
      keyStartingYear: startingYear,
      keyAddress: gymAddress,
      keyPhone: mobileNumber,
      keyEmail: gymEmail,
      keyProfile: profileURL,
      keyMemberPrefix: memberPrefix,
    };

    await FirebaseFirestore.instance.collection(tableGeneralSetting).doc().set(bodyMap).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.gym_added_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> addMeasurement({
    required String? weight,
    required String? height,
    required String? chest,
    required String? waist,
    required String? thigh,
    required String? arms,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(tableGeneralSetting).get();

    if (querySnapshot.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.measurement_already_exist;
      return defaultResponse;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyWeight: weight,
      keyHeight: height,
      keyChest: chest,
      keyWaist: waist,
      keyThigh: thigh,
      keyArms: arms,
    };

    await FirebaseFirestore.instance.collection(tableGeneralSetting).doc().set(bodyMap).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.measurement_added_successfully;
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> updateSetting({
    required settingId,
    required String? gymName,
    required String? startingYear,
    required String? gymAddress,
    required String? mobileNumber,
    required String? gymEmail,
    required File? gymLogo,
    required String? imageUrl,
    required String memberPrefix,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tableGeneralSetting).where(keyGymName, isEqualTo: gymName).get();
    var currentDoc = query.docs.where((element) => element.id == settingId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.gym_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (gymLogo != null && imageUrl != null) {
      profileURL = await FileUploadUtils()
          .uploadAndUpdateImage(folderName: folderWorkoutCategory, fileImage: gymLogo, oldUrl: imageUrl);
    } else if (gymLogo != null) {
      profileURL = await FileUploadUtils().uploadImage(folderName: folderWorkoutCategory, fileImage: gymLogo);
    } else if (imageUrl != null) {
      profileURL = imageUrl;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyGymName: gymName,
      keyStartingYear: startingYear,
      keyAddress: gymAddress,
      keyPhone: mobileNumber,
      keyEmail: gymEmail,
      keyProfile: profileURL,
      keyMemberPrefix: memberPrefix,
    };

    await FirebaseFirestore.instance
        .collection(tableGeneralSetting)
        .doc(settingId)
        .update(
          bodyMap,
        )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.setting_update_successfully;
      getSettingsList();
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> updateMeasurement({
    required settingId,
    required String? weight,
    required String? height,
    required String? chest,
    required String? waist,
    required String? thigh,
    required String? arms,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance.collection(tableGeneralSetting).get();
    var currentDoc = query.docs.where((element) => element.id == settingId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.general_setting_table_not_found;
      return defaultResponse;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyWeight: weight,
      keyHeight: height,
      keyChest: chest,
      keyWaist: waist,
      keyThigh: thigh,
      keyArms: arms,
    };

    await FirebaseFirestore.instance
        .collection(tableGeneralSetting)
        .doc(settingId)
        .update(
          bodyMap,
        )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.measurement_update_successfully;
      getSettingsList();
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> updateSettingByKeyValue({
    required settingId,
    required String key,
    required dynamic value,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    debugPrint("default response : $settingId");

    Map<String, dynamic> bodyMap = <String, dynamic>{
      key: value,
    };

    if (settingId == null) {
      await FirebaseFirestore.instance.collection(tableGeneralSetting).doc().set(bodyMap).whenComplete(() {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.setting_added_successfully;
      }).catchError((e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
      });
      return defaultResponse;
    } else {
      await FirebaseFirestore.instance
          .collection(tableGeneralSetting)
          .doc(settingId)
          .update(
            bodyMap,
          )
          .whenComplete(() {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.setting_update_successfully;
        getSettingsList();
      }).catchError((e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
      });
      return defaultResponse;
    }
  }


  Future<void> getSettingsList() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(tableGeneralSetting).get();
      if (querySnapshot.docs.isNotEmpty) {
        generalSettingItem = querySnapshot.docs.first;
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<DefaultResponse> addPayPal({
    required String? paymentType,
    required String? secretKey,
    required String? clientId,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection(tableGeneralSetting).where(keyPaymentType, isEqualTo: paymentType).get();

    if (querySnapshot.docs.isNotEmpty) {
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

    await FirebaseFirestore.instance.collection(tableGeneralSetting).doc().set(bodyMap).whenComplete(() {
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

  Future<DefaultResponse> addPayment({
    required String? paymentType,
    required String? secretKey,
    required String? publishableKey,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection(tableGeneralSetting).where(keyPaymentType, isEqualTo: paymentType).get();

    if (querySnapshot.docs.isNotEmpty) {
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

    await FirebaseFirestore.instance.collection(tableGeneralSetting).doc().set(bodyMap).whenComplete(() {
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

  Future<DefaultResponse> updatePayPal({
    required settingId,
    required String? paymentType,
    required String? secretKey,
    required String? clientId,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query =
    await FirebaseFirestore.instance.collection(tableGeneralSetting).where(keyPaymentType, isEqualTo: paymentType).get();
    var currentDoc = query.docs.where((element) => element.id == settingId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.payment_type_already_exist;
      return defaultResponse;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyPaypalSecretKey: secretKey,
      keyPaypalClientId: clientId,
      keyPaymentType: paymentType,
    };

    await FirebaseFirestore.instance
        .collection(tableGeneralSetting)
        .doc(settingId)
        .update(
      bodyMap,
    )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.setting_update_successfully;
      getSettingsList();
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> updatePayment({
    required settingId,
    required String? paymentType,
    required String? secretKey,
    required String? publishableKey,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query =
    await FirebaseFirestore.instance.collection(tableGeneralSetting).where(keyPaymentType, isEqualTo: paymentType).get();
    var currentDoc = query.docs.where((element) => element.id == settingId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.payment_type_already_exist;
      return defaultResponse;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keySecretKey: secretKey,
      keyPublishable: publishableKey,
      keyPaymentType: paymentType,
    };

    await FirebaseFirestore.instance
        .collection(tableGeneralSetting)
        .doc(settingId)
        .update(
      bodyMap,
    )
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.setting_update_successfully;
      getSettingsList();
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> updateEmailSetting({
    required settingId,
    required String emailFrom,
    required String domain,
    required String emailName,
    required String smtpServer,
    required String smtpServerPort,
    required String loginEmail,
    required String smtpPassword,
    required String apikey,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance.collection(tableGeneralSetting).get();
    var currentDoc = query.docs.where((element) => element.id == settingId);

    if (currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.please_added_general_setting_details;
      return defaultResponse;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyEmailFrom: emailFrom,
      keyDomain: domain,
      keyEmailName: emailName,
      keySMTPServer: smtpServer,
      keySMTPServerPort: smtpServerPort,
      keyLoginEmail: loginEmail,
      keySMTPPassword: smtpPassword,
      keySendinBlueApi: apikey,
    };

    await FirebaseFirestore.instance
        .collection(tableGeneralSetting)
        .doc(settingId)
        .set(bodyMap, SetOptions(merge: true))
        .whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.sendblue_details_updated_successfully;
      getSettingsList();
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }
}
