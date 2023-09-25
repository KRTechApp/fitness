import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/Utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model/default_response.dart';

class PaymentHistoryProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> paymentHistoryItemList = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allPaymentHistoryItemList = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> packagePaymentHistoryItemList = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> paymentExpenseHistoryItemList = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> createdByPaymentHistory = <QueryDocumentSnapshot>[];

  var lastUserId = "";
  var lastCreatedBy = "";

  Future<void> getPaymentHistory(
      {required String status,
      required String currentUserId,
      required bool sortByCreated,
      bool isRefresh = false,
      String searchText = ""}) async {
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if (userRole == userRoleMember) {
      userRole = userRoleTrainer;
    }
    if (lastUserId != currentUserId) {
      isRefresh = true;
      lastUserId = currentUserId;
    }
    if (isRefresh) {
      packagePaymentHistoryItemList.clear();
      allPaymentHistoryItemList.clear();
    }
    if (status.isNotEmpty) {
      packagePaymentHistoryItemList.clear();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(tablePaymentHistory)
          .where(keyUserId, isEqualTo: currentUserId)
          .where(keyPaymentStatus, isEqualTo: status)
          .where(keyUserRole, isEqualTo: userRole)
          .orderBy(keyCreatedAt, descending: sortByCreated)
          .get();
      debugPrint('userId : $currentUserId');
      debugPrint('paymentStatus : $status');
      debugPrint('userRole : $userRole');
      debugPrint('CreatedAt : $sortByCreated');
      packagePaymentHistoryItemList.addAll(querySnapshot.docs);
    } else {
      packagePaymentHistoryItemList.clear();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(tablePaymentHistory)
          .where(keyUserId, isEqualTo: currentUserId)
          // .where(keyUserRole, isEqualTo: userRole)
          .orderBy(keyCreatedAt, descending: sortByCreated)
          .get();
      debugPrint('userId : $currentUserId');
      debugPrint('paymentStatus : $status');
      debugPrint('userRole : $userRole');
      debugPrint('CreatedAt : $sortByCreated');
      packagePaymentHistoryItemList.addAll(querySnapshot.docs);
      debugPrint('paymentHistoryItemList Length: ${querySnapshot.docs.length}');
    }
    packagePaymentHistoryItemList.removeWhere((element) {
      if (!((element.data() as Map<String, dynamic>).containsKey(keyDeletedBy))) {
        return false;
      }
      return (element.data() as Map<String, dynamic>).containsKey(keyDeletedBy) &&
          List.castFrom(element.get(keyDeletedBy) as List).contains(currentUserId);
    });

    allPaymentHistoryItemList.removeWhere((element) {
      if (!((element.data() as Map<String, dynamic>).containsKey(keyDeletedBy))) {
        return false;
      }
      return (element.data() as Map<String, dynamic>).containsKey(keyDeletedBy) &&
          List.castFrom(element.get(keyDeletedBy) as List).contains(currentUserId);
    });
    debugPrint('final paymentHistoryItemList : ${packagePaymentHistoryItemList.length}');

    notifyListeners();
  }

  Future<void> getCreatedPaymentHistory(
      {required String currentUserId, required bool sortByCreated, required String status}) async {
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if (userRole == userRoleMember) {
      userRole = userRoleTrainer;
    }
    paymentHistoryItemList.clear();
    if (status.isNotEmpty) {
      paymentHistoryItemList.clear();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(tablePaymentHistory)
          .where(keyCreatedBy, isEqualTo: currentUserId)
          .where(keyUserRole, isEqualTo: userRole)
          .where(keyPaymentStatus, isEqualTo: status)
          .orderBy(keyCreatedAt, descending: sortByCreated)
          .get();
      paymentHistoryItemList.addAll(querySnapshot.docs);
      debugPrint('getCreatedPaymentHistory1 ${paymentHistoryItemList.length}');
    } else {
      paymentHistoryItemList.clear();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(tablePaymentHistory)
          .where(keyCreatedBy, isEqualTo: currentUserId)
          .where(keyUserRole, isEqualTo: userRole)
          .orderBy(keyCreatedAt, descending: sortByCreated)
          .get();
      paymentHistoryItemList.addAll(querySnapshot.docs);
      debugPrint('getCreatedPaymentHistory2 ${paymentHistoryItemList.length}');
    }
    debugPrint('currentUserId : $currentUserId');
    paymentHistoryItemList.removeWhere((element) {
      if (!((element.data() as Map<String, dynamic>).containsKey(keyDeletedBy))) {
        return false;
      }
      return (element.data() as Map<String, dynamic>).containsKey(keyDeletedBy) &&
          List.castFrom(element.get(keyDeletedBy) as List).contains(currentUserId);
    });
    notifyListeners();
  }

  Future<void> getMemberPayment({required String currentUserId}) async {
    paymentHistoryItemList.clear();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(tablePaymentHistory)
        .where(keyUserId, isEqualTo: currentUserId)
        .get();
    paymentHistoryItemList.addAll(querySnapshot.docs);
    debugPrint('getMemberPayment ${paymentHistoryItemList.length}');
    paymentHistoryItemList.removeWhere((element) {
      if (!((element.data() as Map<String, dynamic>).containsKey(keyDeletedBy))) {
        return false;
      }
      return (element.data() as Map<String, dynamic>).containsKey(keyDeletedBy) &&
          List.castFrom(element.get(keyDeletedBy) as List).contains(currentUserId);
    });
    notifyListeners();
  }

  Future<void> deletePayment({required paymentId}) async {
    var currentUserId = await SharedPreferencesManager().getValue(keyUserId, "");
    await FirebaseFirestore.instance.collection(tablePaymentHistory).doc(paymentId).update({
      keyDeletedBy: FieldValue.arrayUnion([currentUserId])
    });
    // await FirebaseFirestore.instance.collection(tablePaymentHistory).doc(paymentId).delete();
    int index = paymentHistoryItemList.indexWhere((element) => element.id == paymentId);
    if (index != -1) paymentHistoryItemList.removeAt(index);
    getPaymentHistory(
      currentUserId: currentUserId,
      sortByCreated: true,
      status: '',
      isRefresh: true,
    );
    Fluttertoast.showToast(
        msg: AppLocalizations.of(navigatorKey.currentContext!)!.invoice_deleted_successfully,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    notifyListeners();
  }

  Future<DefaultResponse> updatePaymentStatus(
      {required String paymentId,
      required String paymentStatus,
      required String currentUserId,
      required bool sortByCreated,
      required int extendedDays,
      required String status}) async {
    DefaultResponse defaultResponse = DefaultResponse();
    Map<String, dynamic> bodyMap = <String, dynamic>{keyPaymentStatus: paymentStatus, keyExtendDate: extendedDays};
    await FirebaseFirestore.instance
        .collection(tablePaymentHistory)
        .doc(paymentId)
        .update(bodyMap)
        .whenComplete(() async {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.status_updated_successfully;
      await getCreatedPaymentHistory(currentUserId: currentUserId, sortByCreated: sortByCreated, status: status);
      debugPrint('updatePaymentStatus: $currentUserId $sortByCreated');
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<void> getPaymentHistoryByCreated({required String createdBy, bool isRefresh = false}) async {
    String userRole = await SharedPreferencesManager().getValue(prefUserRole, userRoleMember);
    if (userRole == userRoleMember) {
      userRole = userRoleTrainer;
    }
    debugPrint("getPaymentHistoryByCreated lastCreatedBy :  $lastCreatedBy");
    debugPrint("getPaymentHistoryByCreated createdBy :  $createdBy");
    if (lastCreatedBy != createdBy) {
      isRefresh = true;
      lastCreatedBy = createdBy;
    }
    if (isRefresh) {
      createdByPaymentHistory.clear();
    }

    if (createdByPaymentHistory.isEmpty) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(tablePaymentHistory)
          .where(keyCreatedBy, isEqualTo: createdBy)
          .where(keyUserRole, isEqualTo: userRole)
          .get();
      createdByPaymentHistory.clear();
      createdByPaymentHistory.addAll(querySnapshot.docs);
      debugPrint("getPaymentHistoryByCreated : ${createdByPaymentHistory.length}");
    }
  }

  Future<QueryDocumentSnapshot?> getMyPaymentById(
      {required String membershipId,
      required String createdBy,
      required int createdAt,
      required String createdFor}) async {
    List<QueryDocumentSnapshot> paymentHistoryData = [];

    try {
      if (createdByPaymentHistory.isEmpty || lastCreatedBy != createdBy) {
        await getPaymentHistoryByCreated(createdBy: createdBy);
      }
      paymentHistoryData = createdByPaymentHistory
          .where((element) =>
              element[keyMembershipId] == membershipId &&
              element[keyCreatedBy] == createdBy &&
              element[keyUserId] == createdFor &&
              element[keyCreatedAt] == createdAt)
          .toList();

      debugPrint("getMyPaymentById : $membershipId");
      debugPrint("getMyPaymentById : ${paymentHistoryData.length}");
    } catch (e) {
      debugPrint(e.toString());
    }
    return paymentHistoryData.isNotEmpty ? paymentHistoryData.first : null;
  }

  Future<DefaultResponse> addSubCollection(
      {required paymentDocId,
      required paymentStatus,
      required paymentId,
      required paymentAmount,
      required paymentRecivedAmount,
      required paymentCountry,
      required paymentCourrency,
      required paymentBrand,
      required paymentType,
      required paymentCardCountry,
      required cardLast4,
      required paymentEmail,
      required paymentRecept,
      required clientSecretId,
      required createdAt}) async {
    DefaultResponse defaultResponse = DefaultResponse();
    var querySnapshot = FirebaseFirestore.instance.collection(tablePaymentHistory).doc(paymentDocId);

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyPaymentId: paymentId,
      keyPaymentStatus: paymentStatus,
      keyPaymentAmount: paymentAmount,
      keyPaymentRecivedAmount: paymentRecivedAmount,
      keyPaymentCountry: paymentCountry,
      keyPaymentCourrency: paymentCourrency,
      keyPaymentBrand: paymentBrand,
      keyPaymentType: paymentType,
      keyPaymentCardCountry: paymentCardCountry,
      keyCardLast4: cardLast4,
      keyPaymentEmail: paymentEmail,
      keyPaymentRecept: paymentRecept,
      keyClientSecretId: clientSecretId,
      keyCreatedAt: createdAt,
    };
    await querySnapshot.collection(tablePaymentData).add(bodyMap).whenComplete(() async {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.payment_success;
      debugPrint('PaymentMessage :${defaultResponse.message}');

      Map<String, dynamic> updateBodyMap = <String, dynamic>{
        keyPaymentStatus: paymentPaid,
        keyPaymentType: paymentTypeStripe,
      };
      await FirebaseFirestore.instance
          .collection(tablePaymentHistory)
          .doc(paymentDocId)
          .set(updateBodyMap, SetOptions(merge: true));
    });
    return defaultResponse;
  }

  Future<QueryDocumentSnapshot?> getSingleSubTableDocument({required paymentDocId}) async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection("$tablePaymentHistory/$paymentDocId/$tablePaymentData").get();

    return querySnapshot.docs.toList().isNotEmpty ? querySnapshot.docs.first : null;
  }

  Future<DefaultResponse> addSubCollectionForPaypal(
      {required paymentDocId,
      required paymentStatus,
      required paymentId,
      required paymentPayerId,
      required totalAmount,
      required paymentCourrency,
      required paymentEmail,
      required membershipName,
      required createdAt}) async {
    DefaultResponse defaultResponse = DefaultResponse();
    var querySnapshot = FirebaseFirestore.instance.collection(tablePaymentHistory).doc(paymentDocId);

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyPaymentId: paymentId,
      keyPaymentStatus: paymentStatus,
      keyPayerId: paymentPayerId,
      keyPaymentAmount: totalAmount,
      keyCreatedAt: createdAt,
      keyPaymentCourrency: paymentCourrency,
      keyPaymentEmail: paymentEmail,
      keyMembershipName: membershipName,
    };
    await querySnapshot.collection(tablePaymentData).add(bodyMap).whenComplete(() async {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.payment_success;
      debugPrint('PaymentMessage :${defaultResponse.message}');

      Map<String, dynamic> updateBodyMap = <String, dynamic>{
        keyPaymentStatus: paymentPaid,
        keyPaymentType: paymentTypeStripe,
      };
      await FirebaseFirestore.instance
          .collection(tablePaymentHistory)
          .doc(paymentDocId)
          .set(updateBodyMap, SetOptions(merge: true));
    });
    return defaultResponse;
  }

  Future<DefaultResponse> updateAdminDocument({
    required String envatoEmail,
    required String envatoKey,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    var querySnapshot =
        await FirebaseFirestore.instance.collection(tableUser).where(keyUserRole, isEqualTo: userRoleAdmin).get();
    if(querySnapshot.docs.isNotEmpty){

      Map<String, dynamic> updateBodyMap = <String, dynamic>{
        keyClientEmail: envatoEmail,
        keyEnventoPurchaseKey: envatoKey,
      };

      await FirebaseFirestore.instance
          .collection(tableUser)
          .doc(querySnapshot.docs.first.id)
          .set(updateBodyMap, SetOptions(merge: true))
          .whenComplete(() async {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.envento_purchase_successfully;
        debugPrint('updateAdminDocument 1');
      }).catchError((e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
        debugPrint('updateAdminDocument 2');
      });
    }else{
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.admin_not_found;
      debugPrint('updateAdminDocument 3');
    }
    return defaultResponse;
  }
}
