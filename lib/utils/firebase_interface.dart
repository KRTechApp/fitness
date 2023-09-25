// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/model/exercise_model.dart';
import 'package:crossfit_gym_trainer/model/user_modal.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../admin_screen/admin_dashboard_screen.dart';
import '../main.dart';
import '../member_screen/dashboard_screen.dart';
import '../model/default_response.dart';
import '../model/workout_days_model.dart';
import '../model/static_model/default_exercise.dart';
import '../model/static_model/default_workout.dart';
import '../model/static_model/default_workout_category.dart';
import '../trainer_screen/trainer_dashboard_screen.dart';
import 'file_upload_utils.dart';
import 'shared_preferences_manager.dart';
import 'show_progress_dialog.dart';
import 'static_data.dart';
import 'tables_keys_values.dart';
import 'utils_methods.dart';
import 'validate_utils.dart';

class FirebaseInterface {
  late FirebaseFirestore fireStore;
  // final facebookLogin = FacebookLogin(debug: true);
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', "https://www.googleapis.com/auth/userinfo.profile"],
  );

  FirebaseInterface() {
    fireStore = FirebaseFirestore.instance;
  }

  Future<DefaultResponse> loginUserFirebase(
      {required String emailOrMobile, required String password, required String firebaseToken}) async {
    bool isMobile = isNumeric(emailOrMobile);
    DefaultResponse defaultResponse = DefaultResponse();
    QuerySnapshot querySnapshot =
        await fireStore.collection(tableUser).where(isMobile ? keyPhone : keyEmail, isEqualTo: emailOrMobile).get();
    if (querySnapshot.docs.isNotEmpty &&
        querySnapshot.docs[0].get(isMobile ? keyPhone : keyEmail) == emailOrMobile &&
        querySnapshot.docs[0].get(keyPassword) == password) {
      if (querySnapshot.docs[0].get(keyAccountStatus) == accountRequested) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = "Please contact to Admin for account approval";
      } else {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = "User Login Successfully";
        defaultResponse.responseData = querySnapshot.docs[0];
        await fireStore.collection(tableUser).doc(querySnapshot.docs[0].id).update({
          keyFirebaseToken: firebaseToken,
        });
      }
    } else {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "Please enter valid email and password";
    }
    return defaultResponse;
  }

  Future<DefaultResponse> getUserEmailOrMobile({required String emailOrMobile}) async {
    bool isMobile = isNumeric(emailOrMobile);
    DefaultResponse defaultResponse = DefaultResponse();
    QuerySnapshot querySnapshot =
        await fireStore.collection(tableUser).where(isMobile ? keyPhone : keyEmail, isEqualTo: emailOrMobile).get();
    if (querySnapshot.docs.isNotEmpty && querySnapshot.docs[0].get(isMobile ? keyPhone : keyEmail) == emailOrMobile) {
      if (querySnapshot.docs[0].get(keyAccountStatus) == accountRequested) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = "Please contact to Admin for account approval";
      } else {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = "User Login Successfully";
        defaultResponse.responseData = querySnapshot.docs[0];
      }
    } else {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "Please enter valid email/mobile and password";
    }
    return defaultResponse;
  }

  Future<DefaultResponse> loginUserFromIdFirebase({required String id, required String firebaseToken}) async {
    DefaultResponse defaultResponse = DefaultResponse();
    DocumentSnapshot documentSnapshot = await fireStore.collection(tableUser).doc(id).get();

    if (documentSnapshot.exists) {
      if (documentSnapshot.get(keyAccountStatus) == accountRequested) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = "Please contact to Admin for account approval";
      } else {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = "User Login Successfully";
        defaultResponse.responseData = documentSnapshot;
        await fireStore.collection(tableUser).doc(documentSnapshot.id).update({
          keyFirebaseToken: firebaseToken,
        });
      }
    } else {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "Please enter valid email and password";
    }
    return defaultResponse;
  }

  Future<DefaultResponse> registerUserFirebase(
      {required UserModal userModal, required File? profile, required currentDate, required goal}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await fireStore.collection(tableUser).where(keyEmail, isEqualTo: userModal.email).get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "User Email Already Exist";
      return defaultResponse;
    }
    QuerySnapshot query2 =
        await fireStore.collection(tableUser).where(keyPhone, isEqualTo: userModal.phoneNumber).get();
    if (query2.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "User Mobile Number Already Exist";
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
      keyCountryCode: userModal.countryCode,
      keyPhone: userModal.phoneNumber,
      keyDateOfBirth: userModal.birthDate,
      keyAddress: userModal.address,
      keyGoal: goal,
      keyAccountStatus: accountRequested,
      keyUserRole: userRoleMember,
      keyProfile: profileURL,
      keyCurrentDate: currentDate,
    };

    await fireStore.collection(tableUser).doc().set(bodyMap).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = "User Register Successfully";
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> defaultAdminCreate({
    required BuildContext context,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await fireStore.collection(tableUser).where(keyUserRole, isEqualTo: userRoleAdmin).get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "Admin Already Exist";
      return defaultResponse;
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyEmail: "admin@gmail.com",
      keyPassword: "admin123",
      keyGender: "male",
      keyAge: "25",
      keyHeight: "170",
      keyWeight: "70",
      keyName: "Admin".firstCapitalize(),
      keyCountryCode: "91",
      keyPhone: "9876543210",
      keyWpCountryCode: "91",
      keyWpPhone: "9876543210",
      keyDateOfBirth: getCurrentDateTime(),
      keyAddress: "Ahmedabad",
      keyCity: "Ahmedabad",
      keyState: "Gujarat",
      keyZipCode: "382481",
      keyCountry: "India",
      keyProfile: "",
      keyAccountStatus: accountAllowed,
      keyUserRole: userRoleAdmin,
      keyCurrentDate: "",
      keySpecialization: [],
    };
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: "admin@gmail.com",
      password: "admin123",
    );
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;

    await FirebaseFirestore.instance.collection(tableUser).doc(uid).set(bodyMap).whenComplete(() async {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = "Admin Register Successfully";

      await FirebaseInterface().addDefaultData(context: context, trainerId: uid);
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> resetPasswordFirebase(
      {required String emailOrMobile, required newPassword, required String type}) async {
    DefaultResponse defaultResponse = DefaultResponse();
    QuerySnapshot query;

    if (type == "mobile") {
      query = await fireStore.collection(tableUser).where(keyPhone, isEqualTo: emailOrMobile).get();
    } else {
      query = await fireStore.collection(tableUser).where(keyEmail, isEqualTo: emailOrMobile).get();
    }
    if (query.docs.isNotEmpty &&
        (query.docs[0].get(keyEmail) == emailOrMobile || query.docs[0].get(keyPhone) == emailOrMobile)) {
      await fireStore
          .collection(tableUser)
          .doc(query.docs[0].id)
          .set({keyPassword: newPassword}, SetOptions(merge: true));
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = "Update Password Successfully";
      defaultResponse.responseData = query.docs[0];
    } else {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "User not found";
    }
    return defaultResponse;
  }

  Future<DefaultResponse> checkEmailOrMobileExist({required String emailOrMobile, required String type}) async {
    DefaultResponse defaultResponse = DefaultResponse();
    QuerySnapshot querySnapshot;

    if (type == "mobile") {
      querySnapshot = await fireStore.collection(tableUser).where(keyPhone, isEqualTo: emailOrMobile).get();
    } else {
      querySnapshot = await fireStore.collection(tableUser).where(keyEmail, isEqualTo: emailOrMobile).get();
    }
    if (querySnapshot.docs.isNotEmpty &&
        (querySnapshot.docs[0].get(keyEmail) == emailOrMobile ||
            querySnapshot.docs[0].get(keyPhone) == emailOrMobile)) {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = "User Exists";
      defaultResponse.responseData = querySnapshot.docs[0];
    } else {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "User Not Found";
    }
    return defaultResponse;
  }

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
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await fireStore.collection(tableClass).where(keyClassName, isEqualTo: className).get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "Class Already Exist";
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
      keyVirtualClassLink: virtualClassLink
    };

    await fireStore.collection(tableClass).doc().set(bodyMap).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = "Class added Successfully";
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });
    return defaultResponse;
  }

  Future<DefaultResponse> addExercise({required ExerciseModel exerciseProvider, required selectCategory}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await fireStore
        .collection(tableExercise)
        .where(keyExerciseTitle, isEqualTo: exerciseProvider.exerciseTitle)
        .get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "Exercise Already Exist";
      return defaultResponse;
    }
    String profileURL = "";
    String videoURL = "";
    if (exerciseProvider.imageFile != null || exerciseProvider.exerciseImageFile != null) {
      if (exerciseProvider.imageFile != null) {
        profileURL = await FileUploadUtils()
            .uploadImage(folderName: folderExerciseImage, fileImage: exerciseProvider.imageFile!);
      }
      if (exerciseProvider.exerciseImageFile != null) {
        videoURL = await FileUploadUtils()
            .uploadVideo(folderName: folderExerciseVideo, fileVideo: exerciseProvider.exerciseImageFile!);
      }
      Map<String, dynamic> bodyMap = <String, dynamic>{
        keyExerciseTitle: exerciseProvider.exerciseTitle,
        keyDescription: exerciseProvider.description,
        keyExerciseDetailImage: videoURL,
        keyYoutubeLink: exerciseProvider.youtubeLink,
        keyNotes: exerciseProvider.notes,
        keyProfile: profileURL,
        keyCategoryId: selectCategory,
      };

      await fireStore.collection(tableExercise).doc().set(bodyMap).whenComplete(() {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = "Exercise added Successfully";
      }).catchError((e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
      });
    }
    return defaultResponse;
  }

  Future<void> addDefaultData({required BuildContext context, required String trainerId}) async {
    try {
      final List<String> workoutLevel = ['BEGINNER', 'INTERMEDIATE', 'ADVANCE'];

      var defaultBundle = DefaultAssetBundle.of(context);

      DefaultWorkoutCategory workoutCategory = DefaultWorkoutCategory.fromJson(
          json.decode(await defaultBundle.loadString("assets/default_data/workout_category.json")));
      DefaultExercise exercise =
          DefaultExercise.fromJson(json.decode(await defaultBundle.loadString("assets/default_data/exercise.json")));
      DefaultWorkout workout =
          DefaultWorkout.fromJson(json.decode(await defaultBundle.loadString("assets/default_data/workout.json")));

      for (int i = 0; i < workoutCategory.workoutCategoryList!.length; i++) {
        Map<String, dynamic> bodyMap = <String, dynamic>{
          keyCreatedBy: trainerId,
          keyWorkoutCategoryTitle: workoutCategory.workoutCategoryList![i].title,
          keyProfile: workoutCategory.workoutCategoryList![i].profile
        };
        var doc = await FirebaseFirestore.instance.collection(tableWorkoutCategory).add(bodyMap);
        workoutCategory.workoutCategoryList![i].setDocId = doc.id;

        for (int j = 0; j < exercise.exerciseList!.length; j++) {
          if (exercise.exerciseList![j].categoryId == workoutCategory.workoutCategoryList![i].id) {
            Map<String, dynamic> exerciseBodyMap = <String, dynamic>{
              keyExerciseTitle: exercise.exerciseList![j].exerciseTitle,
              keyDescription: exercise.exerciseList![j].description,
              keyExerciseDetailImage: "",
              keyYoutubeLink: exercise.exerciseList![j].youtubeLink ?? "",
              keyNotes: "",
              keyProfile: exercise.exerciseList![j].profile,
              keyCategoryId: workoutCategory.workoutCategoryList![i].docId,
              keyCreatedBy: trainerId,
            };
            var doc = await FirebaseFirestore.instance.collection(tableExercise).add(exerciseBodyMap);
            exercise.exerciseList![j].setDocExerciseId = doc.id;
          }
        }

        WorkoutDaysModel workoutDaysModel = WorkoutDaysModel(
            exerciseDataList: getExerciseList(
                exerciseList: exercise.exerciseList!,
                tempDataList: workout.workoutList![i].workoutData!,
                categoryId: workoutCategory.workoutCategoryList![i].docId!));

        Map<String, dynamic> workoutBodyMap = <String, dynamic>{
          keyWorkoutTitle: workout.workoutList![i].workoutTitle,
          keyWorkoutFor: workoutLevel[Random().nextInt(workoutLevel.length)],
          keyDuration: Random().nextInt(4) + 2,
          keyWorkoutData: jsonEncode(workoutDaysModel),
          keyExerciseCount: workoutDaysModel.exerciseDataList!.length,
          keyCreatedBy: trainerId,
          keyWorkoutType: workoutTypeFree,
          keyMembershipId: [],
          keyClassScheduleId: "",
          keyProfile: workout.workoutList![i].profile,
          keyTotalWorkoutTime: getWorkoutTotalTime(workoutDaysModel: workoutDaysModel),
          keyCreatedAt: getCurrentDateTime(),
        };
        await FirebaseFirestore.instance.collection(tableWorkout).add(workoutBodyMap);
      }
    } catch (e) {
      debugPrint("addDefaultData : $e");
    }
  }

  Future<void> deleteTrainerAllData({required String trainerId}) async {
    var workoutList =
        await FirebaseFirestore.instance.collection(tableWorkout).where(keyCreatedBy, isEqualTo: trainerId).get();
    for (int i = 0; i < workoutList.docs.length; i++) {
      await FirebaseFirestore.instance.collection(tableWorkout).doc(workoutList.docs[i].id).update({
        keySelectedMember: FieldValue.arrayRemove([trainerId])
      });
      await FirebaseFirestore.instance.collection(tableWorkout).doc(workoutList.docs[i].id).delete();
      var profile = workoutList.docs[i].get(keyProfile);
      await FileUploadUtils().removeSingleFile(url: profile);
    }

    var workoutCategoryList = await FirebaseFirestore.instance
        .collection(tableWorkoutCategory)
        .orderBy(keyWorkoutCategoryTitle)
        .where(keyCreatedBy, isEqualTo: trainerId)
        .get();
    for (int i = 0; i < workoutCategoryList.docs.length; i++) {
      await FirebaseFirestore.instance.collection(tableWorkoutCategory).doc(workoutCategoryList.docs[i].id).delete();

      var profile = workoutCategoryList.docs[i].get(keyProfile);
      await FileUploadUtils().removeSingleFile(url: profile);
    }

    var exerciseList =
        await FirebaseFirestore.instance.collection(tableExercise).where(keyCreatedBy, isEqualTo: trainerId).get();
    for (int i = 0; i < exerciseList.docs.length; i++) {
      await FirebaseFirestore.instance.collection(tableExercise).doc(exerciseList.docs[i].id).delete();

      var profile = exerciseList.docs[i].get(keyProfile);
      await FileUploadUtils().removeSingleFile(url: profile);
    }

    var classList =
        await FirebaseFirestore.instance.collection(tableClass).where(keyCreatedBy, isEqualTo: trainerId).get();

    for (int i = 0; i < classList.docs.length; i++) {
      await FirebaseFirestore.instance.collection(tableClass).doc(classList.docs[i].id).delete();
    }

    var membershipList =
        await FirebaseFirestore.instance.collection(tableMembership).where(keyCreatedBy, isEqualTo: trainerId).get();

    for (int i = 0; i < membershipList.docs.length; i++) {
      await FirebaseFirestore.instance.collection(tableMembership).doc(membershipList.docs[i].id).delete();
      var profile = membershipList.docs[i].get(keyProfile);
      await FileUploadUtils().removeSingleFile(url: profile);
    }

    var memberList =
        await FirebaseFirestore.instance.collection(tableUser).where(keyCreatedBy, isEqualTo: trainerId).get();

    for (int i = 0; i < memberList.docs.length; i++) {
      await FirebaseFirestore.instance.collection(tableUser).doc(memberList.docs[i].id).delete();
      var profile = memberList.docs[i].get(keyProfile);
      await FileUploadUtils().removeSingleFile(url: profile);
      var workoutHistoryList = await FirebaseFirestore.instance
          .collection(tableWorkoutHistory)
          .where(keyCreatedBy, isEqualTo: memberList.docs[i].id)
          .get();
      for (int j = 0; j < workoutHistoryList.docs.length; j++) {
        await FirebaseFirestore.instance.collection(tableWorkoutHistory).doc(workoutHistoryList.docs[j].id).delete();
      }
    }

    var paymentInvoiceList = await FirebaseFirestore.instance
        .collection(tablePaymentHistory)
        .where(keyCreatedBy, isEqualTo: trainerId)
        .get();

    for (int i = 0; i < paymentInvoiceList.docs.length; i++) {
      await FirebaseFirestore.instance.collection(tablePaymentHistory).doc(paymentInvoiceList.docs[i].id).delete();
    }

    var paymentExpenseList =
        await FirebaseFirestore.instance.collection(tablePaymentHistory).where(keyUserId, isEqualTo: trainerId).get();
    for (int i = 0; i < paymentExpenseList.docs.length; i++) {
      await FirebaseFirestore.instance.collection(tablePaymentHistory).doc(paymentExpenseList.docs[i].id).delete();
    }
  }

  Future<DefaultResponse> googleLoginUserFirebase({required String email}) async {
    DefaultResponse defaultResponse = DefaultResponse();
    QuerySnapshot querySnapshot = await fireStore.collection(tableUser).where(keyEmail, isEqualTo: email).get();
    debugPrint('querySnapshot${querySnapshot.size}');
    debugPrint('querySnapshot${querySnapshot.docs}');
    if (querySnapshot.docs.isNotEmpty) {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = "User Login Successfully";
      defaultResponse.responseData = querySnapshot.docs[0];
    } else {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = "User not found";
    }
    debugPrint('message${defaultResponse.message}');
    debugPrint('responseData${defaultResponse.responseData}');
    debugPrint('status${defaultResponse.status}');
    debugPrint('statusCode${defaultResponse.statusCode}');
    debugPrint('defaultResponse$defaultResponse');

    return defaultResponse;
  }

  Future<void> sendFirebaseNotification({
    required List<String> userIdList,
    required String title,
    required String type,
    required String body,
  }) async {
    List<String> firebaseTokenList = [];
    if (StaticData.adminNotification) {
      for (int i = 0; i < userIdList.length; i++) {
        DocumentSnapshot userDoc = await fireStore.collection(tableUser).doc(userIdList[i]).get();
        String fcmToken = getDocumentValue(documentSnapshot: userDoc, key: keyFirebaseToken, defaultValue: "");
        bool notification = getDocumentValue(documentSnapshot: userDoc, key: keyNotification, defaultValue: true);
        if (fcmToken.isNotEmpty && notification) {
          firebaseTokenList.add(fcmToken);
        }
      }
    }
    if (firebaseTokenList.isEmpty) {
      debugPrint('sendFirebaseNotification : Firebase token not found');
      return;
    }
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    Map<String, String> headers = <String, String>{
      'content-type': 'application/json',
      'authorization': 'key=${StaticData.firebaseKey}',
    };
    var bodyMap = {
      'data': {'title': title, 'body': body, 'type': type},
      'registration_ids': firebaseTokenList
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(bodyMap),
    );

    debugPrint('sendFirebaseNotification : $url');
    debugPrint('sendFirebaseNotification : $headers');
    debugPrint('sendFirebaseNotification : $bodyMap');
    debugPrint('sendFirebaseNotification : ${response.statusCode}');
    debugPrint('sendFirebaseNotification : ${response.body}');
  }

  Future<void> sendEmailNotification({
    required List<String> emailList,
    required String subject,
    required String plainText,
    required String htmlText,
  }) async {
    if (StaticData.sendinblueSMTPServer == "" || StaticData.sendinblueSMTPServerPort == "" || StaticData.sendinblueSMTPPassword == "") {
      debugPrint("sendinblueSMTPServer :${StaticData.sendinblueSMTPServer}");
      debugPrint("sendinblueSMTPServerPort: ${StaticData.sendinblueSMTPServerPort}");
      debugPrint("sendinblueSMTPPassword : ${StaticData.sendinblueSMTPPassword}");
      return;
    }
    debugPrint("sendEmailNotification");
    if (emailList.isEmpty) {
      debugPrint('Email Empty : Email Not Found');
      debugPrint('sendinBlue Password : ${StaticData.sendinblueSMTPPassword}');
      debugPrint('sendinBlue Email : ${StaticData.sendinblueEmail}');
      debugPrint('sendinBlue SMTPServerPort : ${StaticData.sendinblueSMTPServerPort}');
      debugPrint('sendinBlue EmailFrom : ${StaticData.sendinblueEmailFrom}');
      debugPrint('sendinBlue EmailName : ${StaticData.sendinblueEmailName}');
      return;
    }
    try {
      // Check is already sign up

      final client = SmtpClient(StaticData.sendinblueDomain, isLogEnabled: true);
      try {
        await client.connectToServer(StaticData.sendinblueSMTPServer, int.parse(StaticData.sendinblueSMTPServerPort), isSecure: false);
        await client.ehlo();
        if (client.serverInfo.supportsAuth(AuthMechanism.plain)) {
          await client.authenticate(StaticData.sendinblueEmail, StaticData.sendinblueSMTPPassword, AuthMechanism.plain);
        } else if (client.serverInfo.supportsAuth(AuthMechanism.login)) {
          await client.authenticate(StaticData.sendinblueEmail, StaticData.sendinblueSMTPPassword, AuthMechanism.login);
        } else {
          return;
        }
        List<MailAddress> listOfEmail = [];
        if (StaticData.adminEmailNotification) {
          for (int i = 0; i < emailList.length; i++) {
            QuerySnapshot userDoc =
                await fireStore.collection(tableUser).where(keyEmail, isEqualTo: emailList[i]).get();
            debugPrint('userId : ${userDoc.docs.length}');
            bool emailNotification =
                getDocumentQuerySnapshotValue(querySnapshot: userDoc, key: keyEmailNotification, defaultValue: true);
            debugPrint('Notification$emailNotification');
            if (emailNotification) {
              listOfEmail.add(MailAddress(StaticData.sendinblueEmailName, emailList[i]));
              debugPrint('Notification123$emailNotification');
            }
            debugPrint('Notification456$emailNotification');
          }
        }
        debugPrint('Email Verification: ${StaticData.sendinblueEmailName + StaticData.sendinblueEmailFrom}');

        final builder = MessageBuilder.prepareMultipartAlternativeMessage(
          plainText: plainText,
          htmlText: htmlText,
        )
          ..from = [MailAddress(StaticData.sendinblueEmailName, StaticData.sendinblueEmailFrom)]
          ..to = listOfEmail
          ..subject = '${StaticData.sendinblueEmailName} - $subject';
        final mimeMessage = builder.buildMimeMessage();
        final sendResponse = await client.sendMessage(mimeMessage);
        debugPrint('message sent: ${sendResponse.isOkStatus}');
      } on SmtpException catch (e) {
        debugPrint('SMT P failed with $e');
      }
    } catch (e) {
      debugPrint(e.toString());
      if (e.toString().contains('invalid') || e.toString().contains('code') || e.toString().contains('verification')) {
        Fluttertoast.showToast(msg: e.toString());
      } else if (e.toString().contains('messaging/unsupported-browser')) {
        Fluttertoast.showToast(msg: 'This Browser does not supported Firebase Messaging');
      }
    }
  }

  Future<bool> deleteUser(String email, String password) async {
    /*debugPrint("${email}deleteUser");
    debugPrint("${password}deleteUser");
    UserCredential? currentUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    currentUser.user?.delete();*/
    debugPrint("deleteUseremail : $email");
    debugPrint("deleteUserpassword : $password");
    try {
      User? user = FirebaseAuth.instance.currentUser!;
      AuthCredential credentials = EmailAuthProvider.credential(email: email, password: password);
      debugPrint("deleteUser : $user");
      UserCredential result = await user.reauthenticateWithCredential(credentials); // called from database class
      await result.user?.delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<void> signupWithGoogle(BuildContext context) async {
    ShowProgressDialog progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      progressDialog.show();
      if (googleSignInAccount.email.isNotEmpty) {
        debugPrint("googleSignInAccount.email : ${googleSignInAccount.email}");
        await signOutWithGoogle();
        if (context.mounted) {
          progressDialog.hide();
          socialLogin(googleSignInAccount.email, context);
        }
      } else {
        progressDialog.hide();
        if (context.mounted) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.email_not_matched,
              toastLength: Toast.LENGTH_LONG,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    }
  }

  Future<void> signupWithApple(BuildContext context) async {
    ShowProgressDialog progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
        clientId: iosBundleId,

        redirectUri:
            // For web your redirect URI needs to be the host of the "current page",
            // while for Android you will be using the API server that redirects back into your app via a deep link
            Uri.parse('https://www.niftysol.com/'),
      ),
      // TODO: Remove these if you have no need for them
     /* nonce: 'example-nonce',
      state: 'example-state',*/
    );

    // ignore: avoid_print
    debugPrint(
      credential.toString(),
    );
    debugPrint("authorizationCode: ${credential.authorizationCode}");
    debugPrint("identityToken: ${credential.identityToken ?? ""}");
    debugPrint("email: ${credential.email ?? ""}");

    if (credential.identityToken != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(credential.identityToken!);
      var email = decodedToken["email"];
      debugPrint(email);
      debugPrint(credential.identityToken);
      progressDialog.show();
      await signOutWithApple();
      if (context.mounted) {
        progressDialog.hide();
        socialLogin(email, context);
      }
    } else {
      progressDialog.hide();
      if (context.mounted) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.something_want_to_wrong,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  Future<void> signOutWithGoogle() async {
    // Sign out with google
    await googleSignIn.signOut();
  }

  Future<void> signOutWithApple() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /*Future<void> loginWithFacebook(BuildContext context) async {
    ShowProgressDialog progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);

    await facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    progressDialog.show();
    // var profile = await plugin.getUserProfile();
    final token = await facebookLogin.accessToken;
    if (token != null && token.permissions.contains(FacebookPermission.email.name)) {
      var email = await facebookLogin.getUserEmail();
      facebookLogin.logOut();
      if (context.mounted) {
        socialLogin(email, context);
      }
    } else {
      progressDialog.hide();
      if(context.mounted){
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.email_not_matched,
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }*/

  Future<void> socialLogin(String? email, BuildContext context) async {
    ShowProgressDialog progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    final SharedPreferencesManager preference = SharedPreferencesManager();

    if (email == null) {
      progressDialog.hide();
      Fluttertoast.showToast(
          msg: "Email not found",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    DefaultResponse defaultResponse = await getUserEmailOrMobile(emailOrMobile: email);

    if (defaultResponse.status == false) {
      Fluttertoast.showToast(
          msg: defaultResponse.message!,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      progressDialog.hide();
      return;
    }
    User? currentUser;
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: defaultResponse.responseData[keyEmail],
      password: defaultResponse.responseData[keyPassword],
    )
        .then(
      (auth) {
        currentUser = auth.user;
        googleLoginUserFirebase(email: email).then((defaultResponse) {
          progressDialog.hide();
          if (defaultResponse.status!) {
            preference.setValue(prefIsLogin, true);
            preference.setValue(
              prefName,
              defaultResponse.responseData[keyName],
            );
            preference.setValue(
              prefEmail,
              defaultResponse.responseData[keyEmail],
            );
            preference.setValue(
              prefPassword,
              defaultResponse.responseData[keyPassword],
            );
            preference.setValue(
              prefAddress,
              defaultResponse.responseData[keyAddress],
            );
            preference.setValue(
              prefAge,
              defaultResponse.responseData[keyAge],
            );
            preference.setValue(
              prefCountryCode,
              defaultResponse.responseData[keyCountryCode],
            );
            preference.setValue(
              prefPhone,
              defaultResponse.responseData[keyPhone],
            );
            preference.setValue(
              prefWeight,
              defaultResponse.responseData[keyWeight],
            );
            preference.setValue(
              prefHeight,
              defaultResponse.responseData[keyHeight],
            );
            preference.setValue(
              prefGender,
              defaultResponse.responseData[keyGender],
            );
            preference.setValue(
              prefDateOfBirth,
              defaultResponse.responseData[keyDateOfBirth],
            );
            preference.setValue(
              prefUserRole,
              defaultResponse.responseData[keyUserRole],
            );
            preference.setValue(
              prefAccountStatus,
              defaultResponse.responseData[keyAccountStatus],
            );
            preference.setValue(
              prefProfile,
              defaultResponse.responseData[keyProfile],
            );
            preference.setValue(
              prefCurrentDate,
              defaultResponse.responseData[keyCurrentDate],
            );
            preference.setValue(prefUserId, (defaultResponse.responseData as QueryDocumentSnapshot).id);
            if (defaultResponse.responseData[keyUserRole] != userRoleAdmin &&
                defaultResponse.responseData[keyUserRole] != userRoleTrainer) {
              preference.setValue(
                prefCreatedBy,
                defaultResponse.responseData[keyCreatedBy],
              );
            }
            notificationInit();
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.login_successfully,
                toastLength: Toast.LENGTH_LONG,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            if (defaultResponse.responseData[keyUserRole] == userRoleAdmin) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen(),
                ),
                ModalRoute.withName("/AdminScreen"),
              );
            } else if (defaultResponse.responseData[keyUserRole] == userRoleTrainer) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrainerDashboardScreen(),
                ),
                ModalRoute.withName("/TrainerScreen"),
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
                ModalRoute.withName("/MemberScreen"),
              );
            }
          } else {
            progressDialog.hide();
            Fluttertoast.showToast(
                msg: "${defaultResponse.message}",
                toastLength: Toast.LENGTH_LONG,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        }).catchError((error, stackTrace) {
          progressDialog.hide();
          debugPrint("Exception : $error");
          Fluttertoast.showToast(
              msg: "$stackTrace",
              toastLength: Toast.LENGTH_LONG,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      },
    ).catchError(
      (error) {
        progressDialog.hide();
        debugPrint('error.message!${error.message!}');
        Fluttertoast.showToast(
            msg: error.message!,
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      },
    );
  }

  Future<DefaultResponse> initialCheck(
      {required String email, required String licenseKey,}) async {
    var uri = Uri.parse('http://license.dasinfomedia.com/index.php');
    DefaultResponse defaultResponse = DefaultResponse();

    try {
      Map<String, dynamic> bodyMap = <String, dynamic>{
        "email": email,
        "licence_key": licenseKey,
        "domain": FirebaseFirestore.instance.app.options.projectId,
        "result": '2',
        "item_name":'hospital',
      };

      debugPrint('bodyMap : $bodyMap');
      await http.post(uri, body: bodyMap).then((response) {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message = "Purchase Key verify Successfully";
        defaultResponse.responseData = response.body.toString();
        debugPrint('line 1022');
      });
    } catch (e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
      debugPrint('line 1028');
      debugPrint(e.toString());
    }
    // debugPrint(jsonEncode(defaultResponse));
    return defaultResponse;
  }
}
