// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';

import '../main.dart';
import '../mobile_pages/login_screen.dart';
import '../mobile_pages/social_login_screen.dart';
import '../model/workout_days_model.dart';
import '../model/static_model/default_exercise.dart';
import '../model/static_model/default_workout.dart';
import 'color_code.dart';
import 'tables_keys_values.dart';

ImageProvider customImageProvider({String? url, Uint8List? imageByte}) {
  if (imageByte != null) {
    return MemoryImage(imageByte);
  } else if (url != null && url != "" && url.startsWith("assets/default_data/default_image/")) {
    return AssetImage(url);
  } else if (url != null && url != "") {
    return NetworkImage(url);
  }
  if (StaticData.defaultPlaceHolder.startsWith("http")) {
    return NetworkImage(StaticData.defaultPlaceHolder);
  }
  return AssetImage(StaticData.defaultPlaceHolder);
}

/*
ImageProvider customPlaceHolderImageProvider({String? url, Uint8List? imageByte}) {
  if (imageByte != null) {
    return MemoryImage(imageByte);
  } else if (url != null && url != "" && url.startsWith("assets/default_data/default_image/")) {
    return AssetImage(url);
  } else if (url != null && url != "") {
    return NetworkImage(url);
  }
  if(StaticData.defaultPlaceHolder.startsWith("http")){
    return NetworkImage(StaticData.defaultPlaceHolder);
  }
  return AssetImage(StaticData.defaultPlaceHolder);
}
*/

Widget getPlaceHolder() {
  if (StaticData.defaultPlaceHolder.startsWith("http")) {
    return Image.network(StaticData.defaultPlaceHolder);
  }
  return Image.asset(StaticData.defaultPlaceHolder);
}

int getCurrentDateTime() {
  return DateTime.now().millisecondsSinceEpoch;
}

int getCurrentDateOnly() {
  var currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return DateTime.parse(currentDate).millisecondsSinceEpoch;
}

Future<void> updateRowFieldOfTable({required String tableName, required String key, required dynamic value}) async {
  QuerySnapshot query = await FirebaseFirestore.instance.collection(tableName).get();
  for (int i = 0; i < query.docs.length; i++) {
    await FirebaseFirestore.instance.collection(tableName).doc(query.docs[i].id).update({key: value});
    debugPrint("updateRowFieldOfTable : ${query.docs[i].id}");
  }
}

Future<void> deleteAllTableData({required String tableName, int excludeCount = 0}) async {
  QuerySnapshot query = await FirebaseFirestore.instance.collection(tableName).get();
  debugPrint("deleteAllTableData : ${query.docs.length}");

  for (int i = 0; i < (query.docs.length - excludeCount); i++) {
    await FirebaseFirestore.instance.collection(tableName).doc(query.docs[i].id).delete();
    debugPrint("deleteAllTableData : ${query.docs[i].id}");
  }
}

/// *********************************** Responsive Font / Size *******************************
final window = WidgetsBinding.instance.window;
Size size = window.physicalSize / window.devicePixelRatio;

/// This method is used to set padding/margin (for the left and Right side)
/// and width of the screen or widget according to the Viewport width.
double getHorizontalSize(double px) => px * (size.width / 375);

/// This method is used to set padding/margin (for the top and bottom side)
/// and height of the screen or widget according to the Viewport height.
double getVerticalSize(double px) {
  num statusBar = MediaQueryData.fromWindow(window).viewPadding.top;
  num screenHeight = size.height - statusBar;
  return px * (screenHeight / 812);
}

/// This method is used to set smallest px in image height and width.
double getSize(double px) {
  final height = getVerticalSize(px);
  final width = getHorizontalSize(px);

  if (height < width) {
    return height.toInt().toDouble();
  } else {
    return width.toInt().toDouble();
  }
}

/// This method is used to set text font size according to Viewport.
double getFontSize(double px) => getSize(px);

/// *********************************** Responsive Font / Size *******************************

int getWorkoutTotalTime({required WorkoutDaysModel workoutDaysModel}) {
  int totalTime = 0;

  if (workoutDaysModel.exerciseDataList != null) {
    for (int i = 0; i < workoutDaysModel.exerciseDataList!.length; i++) {
      // exerciseList[i].set1
      int set =
          int.parse(workoutDaysModel.exerciseDataList![i].exerciseDataSet!.isEmpty ? "0" : workoutDaysModel.exerciseDataList![i].exerciseDataSet!);
      int sec =
          int.parse(workoutDaysModel.exerciseDataList![i].exerciseDataSec!.isEmpty ? "0" : workoutDaysModel.exerciseDataList![i].exerciseDataSec!);
      // int reps = int.parse(exerciseList[i].exerciseDataReps!);
      int rest =
          int.parse(workoutDaysModel.exerciseDataList![i].exerciseDataRest!.isEmpty ? "0" : workoutDaysModel.exerciseDataList![i].exerciseDataRest!);

      totalTime = totalTime + ((set * sec) + (rest * set));
    } // 3 * 60  + 30 * 3
  }
  return totalTime;
}

List<ExerciseDataItem> getExerciseList(
    {required List<ExerciseList> exerciseList, required List<WorkoutData> tempDataList, required String categoryId}) {
  List<ExerciseDataItem> selectExerciseList = [];

  for (int i = 0; i < tempDataList.length; i++) {
    String exerciseId = exerciseList.firstWhere((element) => element.exerciseId == tempDataList[i].exerciseId).docExerciseId!;
    selectExerciseList.add(ExerciseDataItem(
      categoryId: categoryId,
      dayList: tempDataList[i].dayList,
      exerciseId: exerciseId,
      reps: tempDataList[i].reps,
      rest: tempDataList[i].rest,
      sec: tempDataList[i].sec,
      set: tempDataList[i].set,
    ));
  }
  return selectExerciseList;
}

List<ExerciseDataItem> getDayByExercise({required String day, WorkoutDaysModel? workoutDaysModel}) {
  List<ExerciseDataItem> exerciseDataList = [];
  if (workoutDaysModel != null && workoutDaysModel.exerciseDataList != null && workoutDaysModel.exerciseDataList!.isNotEmpty) {
    for (int i = 0; i < workoutDaysModel.exerciseDataList!.length; i++) {
      if (workoutDaysModel.exerciseDataList![i].dayList != null && workoutDaysModel.exerciseDataList![i].dayList!.contains(day)) {
        exerciseDataList.add(workoutDaysModel.exerciseDataList![i]);
      }
    }
  }
  return exerciseDataList;
}

dynamic getDocumentValue({required DocumentSnapshot documentSnapshot, required String key, dynamic defaultValue = ""}) {
  if (documentSnapshot.exists && (documentSnapshot.data() as Map<String, dynamic>).containsKey(key)) {
    return documentSnapshot[key];
  } else {
    return defaultValue;
  }
}

dynamic getDocumentQuerySnapshotValue({required QuerySnapshot querySnapshot, required String key, dynamic defaultValue = "", int index = 0}) {
  debugPrint(
      'check Condition ${querySnapshot.docs.isNotEmpty} ${querySnapshot.docs.length > index} ${(querySnapshot.docs[index].data() as Map<String, dynamic>).containsKey(key)}');
  if (querySnapshot.docs.isNotEmpty &&
      querySnapshot.docs.length > index &&
      (querySnapshot.docs[index].data() as Map<String, dynamic>).containsKey(key)) {
    return querySnapshot.docs[index][key];
  } else {
    return defaultValue;
  }
}

String getFileNameFromFirebaseURL(String url) {
  RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
  //This Regex won't work if you remove ?alt...token
  var matches = regExp.allMatches(url);

  var match = matches.elementAt(0);
  debugPrint(Uri.decodeFull(match.group(2)!));
  return Uri.decodeFull(match.group(2)!);
}

logoutDialog({required BuildContext context}) {
  var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;
  SharedPreferencesManager preferencesManager = SharedPreferencesManager();
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.01,
              ),
              Container(
                  padding: const EdgeInsets.all(10),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: ColorCode.mainColor.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: ColorCode.mainColor,
                    size: 35,
                  )
                  // SvgPicture.asset('assets/images/Delate.svg'),
                  ),
              SizedBox(
                height: height * 0.02,
              ),
              Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.are_you_sure_want_to_logout,
                  style: TextStyle(color: ColorCode.backgroundColor, fontSize: getFontSize(17), fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
              // Text((documentSnapshot[keyName] ?? "") + '?', style: GymStyle.inputTextBold),
              SizedBox(
                height: height * 0.03,
              ),
              Row(
                children: [
                  Container(
                    width: width * 0.3,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: ColorCode.mainColor,
                        width: 2,
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        // trainerProvider.deleteTrainer(trainerId: documentSnapshot.id);
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cancel.toUpperCase(),
                        style: TextStyle(
                            color: ColorCode.mainColor,
                            fontSize: getFontSize(16),
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.04,
                  ),
                  Container(
                    width: width * 0.3,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () async {
                        var isRemember = await preferencesManager.getValue(keyRemember, false);
                        var userId = await preferencesManager.getValue(keyUserId, "");
                        FirebaseFirestore.instance.collection(tableUser).doc(userId).update({keyFirebaseToken: ""});
                        if (isRemember) {
                          var email = await preferencesManager.getValue(keyEmail, "");
                          var pass = await preferencesManager.getValue(keyPassword, "");
                          preferencesManager.clear();
                          preferencesManager.setValue(keyEmail, email);
                          preferencesManager.setValue(keyPassword, pass);
                          preferencesManager.setValue(keyRemember, isRemember);
                        } else {
                          preferencesManager.clear();
                        }
                        isExpired = false;
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                            return const LoginScreen();
                          }), (route) => false);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.log_out.toUpperCase(),
                        style: TextStyle(
                            color: ColorCode.white,
                            fontSize: getFontSize(16),
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
}

Widget customMarquee({double height = 20, required double width, required String text, required TextStyle textStyle}) {
  return SizedBox(
    width: width,
    height: height,
    child: willTextOverflow(text: text, maxWidth: width, style: textStyle)
        ? Marquee(
            text: text,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 50.0,
            velocity: 20.0,
            pauseAfterRound: const Duration(seconds: 1),
            accelerationDuration: const Duration(seconds: 2),
            accelerationCurve: Curves.linear,
            decelerationDuration: const Duration(milliseconds: 200),
            decelerationCurve: Curves.easeOut,
            style: textStyle)
        : Text(text, style: textStyle),
  );
}

bool willTextOverflow({required String text, required TextStyle style, required double maxWidth}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: ui.TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: maxWidth);

  return textPainter.didExceedMaxLines;
}

int getRandomBetween({required int min, required int max}) {
  return min + Random().nextInt(max - min);
}

hideKeyboard() {
  debugPrint("Focus Mode hide");
  FocusManager.instance.primaryFocus?.unfocus();
  TextEditingController().clear();
}

String getCurrency({required String currencyName, bool isAdmin = true}) {
  String currency = isAdmin ? StaticData.currentCurrency : StaticData.currentTrainerCurrency;

  switch (currencyName) {
    case "Indian Rupee":
      currency = "₹";
      if (isAdmin) {
        StaticData.currentCurrencyName = "INR";
        StaticData.currentCurrencyCountry = "IN";
      } else {
        StaticData.currentTrainerCurrencyName = "INR";
        StaticData.currentTrainerCurrencyCountry = "IN";
      }
      break;
    case "U.S.Dollar":
      currency = "\$";
      if (isAdmin) {
        StaticData.currentCurrencyName = "USD";
        StaticData.currentCurrencyCountry = "US";
      } else {
        StaticData.currentTrainerCurrencyName = "USD";
        StaticData.currentTrainerCurrencyCountry = "US";
      }
      break;
    case "Euro":
      currency = "€";
      if (isAdmin) {
        StaticData.currentCurrencyName = "EUR";
        StaticData.currentCurrencyCountry = "EU";
      } else {
        StaticData.currentTrainerCurrencyName = "EUR";
        StaticData.currentTrainerCurrencyCountry = "EU";
      }
      break;
  }
  debugPrint("currencyName : $currencyName");
  debugPrint("currency : $currency");
  debugPrint("currentCurrencyName : ${StaticData.currentCurrencyName}");
  debugPrint("currentCurrencyCountry : ${StaticData.currentCurrencyCountry}");

  return currency;
}

String getPaymentType({required String selectedPayment}) {
  String paymentType = StaticData.paymentType;
  switch (selectedPayment) {
    case "Cash-Offline":
      paymentType = paymentCash;
      break;
    case "PayPal":
      paymentType = paymentTypePayPal;
      break;
    case "Stripe":
      paymentType = paymentTypeStripe;
      break;
  }
  return paymentType;
}

String getPaymentTitle({required String paymentType}) {
  String paymentTitle = StaticData.paymentType;
  switch (paymentType) {
    case paymentCash:
      paymentTitle = "Cash-Offline";
      break;
    case paymentTypePayPal:
      paymentTitle = "PayPal";
      break;
    case paymentTypeStripe:
      paymentTitle = "Stripe";
      break;
  }
  return paymentTitle;
}

String getSelectedDay(QueryDocumentSnapshot documentSnapshot) {
  var dayListString = "";
  List<int> selectDayList = [];
  selectDayList = List.castFrom(documentSnapshot.get(keySelectedDays) as List);
  // debugPrint("selected day list : $selectDayList");
  for (var i = 0; i < selectDayList.length; i++) {
    dayListString = dayListString +
        (getDay(
          selectDayList[i],
        ).isNotEmpty
            ? "${dayListString.isNotEmpty ? " | " : ""}${getDay(
                selectDayList[i],
              )}"
            : "");
  }
  return dayListString;
}

String getDay(int index) {
  switch (index) {
    case 0:
      return "Su";
    case 1:
      return "Mo";
    case 2:
      return "Tu";
    case 3:
      return "We";
    case 4:
      return "Th";
    case 5:
      return "Fr";
    case 6:
      return "Sa";
  }
  return "Sunday";
}

String getErrorMessage({required String errorType}) {
  String errorMessage = errorType;
  switch (errorType) {
    case "net::ERR_INTERNET_DISCONNECTED":
      errorMessage = "Please check your internet connection.";
      break;
    case "net::ERR_TIMED_OUT":
      errorMessage = "Time out!! please try again.";
      break;
  }

  return errorMessage;
}

void setPaymentMethodAndKeys({required DocumentSnapshot documentSnapshot, bool isAdmin = true}) {
  if (isAdmin) {
    StaticData.currentCurrency = getCurrency(
        currencyName: getDocumentValue(documentSnapshot: documentSnapshot, key: keySelectedCurrency, defaultValue: "U.S.Dollar"), isAdmin: isAdmin);

    StaticData.stripeSecretKey = getDocumentValue(documentSnapshot: documentSnapshot, key: keySecretKey, defaultValue: StaticData.stripeSecretKey);
    StaticData.stripePublishableKey =
        getDocumentValue(documentSnapshot: documentSnapshot, key: keyPublishable, defaultValue: StaticData.stripePublishableKey);
    Stripe.publishableKey = StaticData.stripePublishableKey;
    Stripe.merchantIdentifier = StaticData.stripeMerchantKey;

    StaticData.paypalClientId = getDocumentValue(documentSnapshot: documentSnapshot, key: keyPaypalClientId, defaultValue: StaticData.paypalClientId);
    StaticData.paypalSecretKey =
        getDocumentValue(documentSnapshot: documentSnapshot, key: keyPaypalSecretKey, defaultValue: StaticData.paypalSecretKey);
    StaticData.paymentType = getDocumentValue(documentSnapshot: documentSnapshot, key: keyPaymentType, defaultValue: StaticData.paymentType);
  } else {
    StaticData.currentTrainerCurrency = getCurrency(
        currencyName: getDocumentValue(documentSnapshot: documentSnapshot, key: keySelectedCurrency, defaultValue: "U.S.Dollar"), isAdmin: isAdmin);

    StaticData.stripeTrainerSecretKey =
        getDocumentValue(documentSnapshot: documentSnapshot, key: keySecretKey, defaultValue: StaticData.stripeTrainerSecretKey);
    StaticData.stripeTrainerPublishableKey =
        getDocumentValue(documentSnapshot: documentSnapshot, key: keyPublishable, defaultValue: StaticData.stripeTrainerPublishableKey);
    Stripe.publishableKey = StaticData.stripeTrainerPublishableKey;
    Stripe.merchantIdentifier = StaticData.stripeMerchantKey;


    StaticData.paypalTrainerClientId =
        getDocumentValue(documentSnapshot: documentSnapshot, key: keyPaypalClientId, defaultValue: StaticData.paypalTrainerClientId);
    StaticData.paypalTrainerSecretKey =
        getDocumentValue(documentSnapshot: documentSnapshot, key: keyPaypalSecretKey, defaultValue: StaticData.paypalTrainerSecretKey);
    StaticData.paymentTrainerType =
        getDocumentValue(documentSnapshot: documentSnapshot, key: keyPaymentType, defaultValue: StaticData.paymentTrainerType);
  }
  Stripe.instance.applySettings();
}

bool checkRtl({required String currentLanguage}) {
  bool isRtl = false;
  if(currentLanguage == "ar" || currentLanguage == "fa" || currentLanguage == "ur"){
    isRtl = true;
  }else{
    isRtl = false;
  }
  return isRtl;
}


