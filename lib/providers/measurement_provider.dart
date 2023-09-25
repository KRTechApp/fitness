import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model/default_response.dart';

class MeasurementProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> measurementListItem = <QueryDocumentSnapshot>[];

  Future<DefaultResponse> addMeasurement({
    required dateTimestamp,
    required double weight,
    required double height,
    required double chest,
    required double waist,
    required double thigh,
    required double arms,
    required trainerId,
    required currentId,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyCreatedAt: dateTimestamp,
      keyWeight: weight,
      keyHeight: height,
      keyChest: chest,
      keyWaist: waist,
      keyThigh: thigh,
      keyArms: arms,
      keyCreatedBy: currentId,
      keyTrainerId: trainerId,
    };
    await FirebaseFirestore.instance.collection(tableMeasurementHistory).doc().set(bodyMap).whenComplete(() async {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.measurement_added_successfully;
      await getMeasurement(currentUser: currentId);
}).catchError(
      (e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
      },
    );
    return defaultResponse;
  }

  Future<void> getMeasurement({required currentUser}) async {
    QuerySnapshot querySnapshot;

    querySnapshot = await FirebaseFirestore.instance
        .collection(tableMeasurementHistory)
        .where(keyCreatedBy, isEqualTo: currentUser)
        .get();
    debugPrint("querySnapshot ${querySnapshot.docs}");
    debugPrint("querySnapshot ${querySnapshot.size}");

    measurementListItem.clear();
    measurementListItem.addAll(querySnapshot.docs);
    debugPrint("querySnapshot ${querySnapshot.docs}");
    debugPrint("querySnapshot ${querySnapshot.size}");

    notifyListeners();
    debugPrint("measurementListItem ${measurementListItem.length}");
  }

  Future<DefaultResponse> updateMeasurement({
    required measurementId,
    required currentUser,
    required double weight,
    required double height,
    required double chest,
    required double waist,
    required double thigh,
    required double arms,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyWeight: weight,
      keyHeight: height,
      keyChest: chest,
      keyWaist: waist,
      keyThigh: thigh,
      keyArms: arms,
    };

    await FirebaseFirestore.instance
        .collection(tableMeasurementHistory)
        .doc(measurementId)
        .update(
          bodyMap,
        )
        .whenComplete(
      () async {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.measurement_update_successfully;
        await getMeasurement(currentUser: currentUser);
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
}
