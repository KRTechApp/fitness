import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model/default_response.dart';
import '../utils/tables_keys_values.dart';

class SpecializationProvider with ChangeNotifier {

  List<QueryDocumentSnapshot> specializationList = <QueryDocumentSnapshot>[];


  Future<DefaultResponse> addSpecialization({required specialization}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance.collection(tableSpecialization).where(keySpecialization, isEqualTo: specialization).get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.specialization_already_exist;
      return defaultResponse;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keySpecialization: specialization,
    };

    await FirebaseFirestore.instance.collection(tableSpecialization).doc().set(bodyMap).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.specialization_added_successfully;
      getSpecializationList(isRefresh: true);
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<void> getSpecializationList({bool isRefresh = false, String searchText = ""}) async {
    if (isRefresh) {
      specializationList.clear();
    }
    try {
      if (specializationList.isEmpty) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(tableSpecialization).orderBy(keySpecialization).get();
        specializationList.clear();
        specializationList.addAll(querySnapshot.docs);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future<String> getSpecializationFromId({required String specializationId}) async {
    if (specializationList.isEmpty) {
      await getSpecializationList();
    }
    var specializationData = specializationList.where((element) => element.id == specializationId);
    debugPrint("specializationData : ${specializationData.length.toString()}");

    return specializationData.isNotEmpty ? specializationData.first[keySpecialization] : "";
  }

  Future<String> getSpecializationListInSingleString({required List<String> specializationIdList}) async {
    var allSpecializationString = "";
    for (var i = 0; i < specializationIdList.length; i++) {
      var specializationData = await getSpecializationFromId(specializationId: specializationIdList[i]);
      allSpecializationString =
          allSpecializationString + (specializationData.isNotEmpty ? "${allSpecializationString.isNotEmpty ? ", " : ""}$specializationData" : "");
    }

    return allSpecializationString;
  }

  void refreshList() {
    notifyListeners();
  }
}
